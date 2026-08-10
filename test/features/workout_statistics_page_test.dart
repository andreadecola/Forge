import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/features/training_plan/presentation/widgets/workout_activity_chart.dart';

import 'exercise_test_fixtures.dart';

Future<void> _pumpApp(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const ForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openStatistics(WidgetTester tester) async {
  await tester.tap(find.text('Programma'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Statistiche'));
  await tester.pumpAndSettle();
}

/// Semina una sessione conclusa con un solo esercizio, con serie e durata
/// controllate — qui interessano i totali, non i dettagli per esercizio
/// (già coperti da `workout_history_page_test.dart`).
Future<void> _seedSession(
  AppDatabase database, {
  required bool completed,
  required int plannedSets,
  required int completedSets,
  required DateTime startedAt,
  required Duration duration,
}) async {
  final profile = await ProfileRepositoryImpl(
    database.userProfileDao,
  ).getCurrentProfile();
  final workoutRepository = DriftWorkoutRepository(database);
  final sessionRepository = DriftWorkoutSessionRepository(database);
  final exerciseRow = await database.eserciziDao.getByCode('EX-AVAILABLE');

  final workoutId = await workoutRepository.createWorkout(
    Workout(
      profileId: profile!.id!,
      name: 'Scheda statistiche',
      type: WorkoutType.fullBody,
      status: WorkoutDefinitionStatus.ready,
      origin: WorkoutOrigin.user,
    ),
  );
  final workoutExerciseId = await workoutRepository.addExercise(
    workoutId: workoutId,
    exercise: WorkoutExercise(
      workoutId: workoutId,
      exerciseId: exerciseRow!.id,
      order: 1,
      sets: plannedSets,
      repetitions: 10,
    ),
  );

  final details = (await workoutRepository.getWorkoutDetails(workoutId))!;
  final sessionId = await sessionRepository.createSession(
    profileId: profile.id!,
    details: details,
    startedAt: startedAt,
  );
  await sessionRepository.updateProgress(
    sessionId: sessionId,
    exercises: [
      SessionExerciseProgressUpdate(
        workoutExerciseId: workoutExerciseId,
        completedSets: completedSets,
        isSkipped: false,
        isCompleted: completedSets >= plannedSets,
      ),
    ],
    updatedAt: startedAt,
  );

  final endedAt = startedAt.add(duration);
  if (completed) {
    await sessionRepository.completeSession(
      sessionId: sessionId,
      endedAt: endedAt,
    );
  } else {
    await sessionRepository.abortSession(
      sessionId: sessionId,
      endedAt: endedAt,
    );
  }
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets('nessuna sessione -> empty state (sezione 35)', (tester) async {
    await _pumpApp(tester, database);
    await _openStatistics(tester);

    expect(
      find.text('Nessun allenamento nel periodo selezionato.'),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'KPI, riepilogo, tempo, frequenza e grafico coerenti con le sessioni '
    'seminate; cambio periodo e navigazione funzionano (sezioni 56/57)',
    (tester) async {
      final now = DateTime.now();
      await _seedSession(
        database,
        completed: true,
        plannedSets: 2,
        completedSets: 2,
        startedAt: now.subtract(const Duration(days: 1)),
        duration: const Duration(minutes: 20),
      );
      await _seedSession(
        database,
        completed: false,
        plannedSets: 3,
        completedSets: 1,
        startedAt: now.subtract(const Duration(days: 2)),
        duration: const Duration(minutes: 10),
      );

      await _pumpApp(tester, database);
      await _openStatistics(tester);

      expect(find.text('Statistiche allenamenti'), findsOneWidget);
      // Tasso di completamento: 1 completata su 2 totali -> 50%.
      expect(find.text('50%'), findsOneWidget);

      // Le sezioni "Tempo"/"Frequenza"/"Attività" sono sotto la piega
      // (ListView, resa pigra): serve scorrere prima di poterle trovare.
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Durata totale (20+10) e media (15) — sotto l'ora, "N min".
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('15 min'), findsOneWidget);
      expect(find.byType(WorkoutActivityChart), findsOneWidget);

      // Cambio periodo: "7 giorni" continua a includerle entrambe (1 e 2
      // giorni fa), il contenuto resta coerente senza errori.
      await tester.tap(find.widgetWithText(ChoiceChip, '7 giorni'));
      await tester.pumpAndSettle();
      expect(find.text('50%'), findsOneWidget);

      // Navigazione: Statistiche -> Back -> Programma.
      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();
      expect(find.text('I tuoi allenamenti'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );
}
