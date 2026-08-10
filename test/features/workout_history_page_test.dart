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

Future<void> _openHistory(WidgetTester tester) async {
  await tester.tap(find.text('Programma'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Storico allenamenti'));
  await tester.pumpAndSettle();
}

/// Semina una sessione conclusa con [exercises] righe (ognuna già nello
/// stato finale voluto), senza passare dal controller/UI: qui interessa
/// solo cosa mostra la pagina storico dato un certo stato persistito.
Future<int> _seedHistorySession(
  AppDatabase database, {
  required String workoutName,
  required bool completed,
  required List<
    ({
      int sets,
      int? repetitions,
      int? durationSeconds,
      int completedSets,
      bool isCompleted,
      bool isSkipped,
    })
  >
  exercises,
  required DateTime startedAt,
  required DateTime endedAt,
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
      name: workoutName,
      type: WorkoutType.fullBody,
      status: WorkoutDefinitionStatus.ready,
      origin: WorkoutOrigin.user,
    ),
  );
  final workoutExerciseIds = <int>[];
  for (var i = 0; i < exercises.length; i++) {
    final e = exercises[i];
    final id = await workoutRepository.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseRow!.id,
        order: i + 1,
        sets: e.sets,
        repetitions: e.repetitions,
        durationSeconds: e.durationSeconds,
      ),
    );
    workoutExerciseIds.add(id);
  }

  final details = (await workoutRepository.getWorkoutDetails(workoutId))!;
  final sessionId = await sessionRepository.createSession(
    profileId: profile.id!,
    details: details,
    startedAt: startedAt,
  );

  await sessionRepository.updateProgress(
    sessionId: sessionId,
    exercises: [
      for (var i = 0; i < exercises.length; i++)
        SessionExerciseProgressUpdate(
          workoutExerciseId: workoutExerciseIds[i],
          completedSets: exercises[i].completedSets,
          isSkipped: exercises[i].isSkipped,
          isCompleted: exercises[i].isCompleted,
        ),
    ],
    updatedAt: startedAt,
  );

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
  return sessionId;
}

ProviderContainer container(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return ProviderScope.containerOf(context);
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets('nessuna sessione storica -> empty state', (tester) async {
    await _pumpApp(tester, database);
    await _openHistory(tester);

    expect(find.text('Nessun allenamento registrato.'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'navigazione: Programma -> Storico -> sessione -> dettaglio -> back '
    '(sezione 45)',
    (tester) async {
      await _seedHistorySession(
        database,
        workoutName: 'Total Body Base',
        completed: true,
        exercises: [
          (
            sets: 2,
            repetitions: 10,
            durationSeconds: null,
            completedSets: 2,
            isCompleted: true,
            isSkipped: false,
          ),
        ],
        startedAt: DateTime(2026, 8, 10, 18, 0),
        endedAt: DateTime(2026, 8, 10, 18, 42),
      );

      await _pumpApp(tester, database);
      await _openHistory(tester);

      expect(find.text('Total Body Base'), findsOneWidget);
      expect(find.text('1 allenamento'), findsOneWidget);

      await tester.tap(find.text('Total Body Base'));
      await tester.pumpAndSettle();

      expect(find.text('Dettaglio allenamento'), findsOneWidget);
      expect(find.text('Total Body Base'), findsWidgets);
      expect(find.text('42 min'), findsOneWidget);

      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();
      expect(find.text('Storico allenamenti'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'card completata/interrotta con badge e conteggi corretti; i filtri '
    'funzionano (sezioni 9/10/40/41/44)',
    (tester) async {
      await _seedHistorySession(
        database,
        workoutName: 'Scheda completata',
        completed: true,
        exercises: [
          (
            sets: 1,
            repetitions: 10,
            durationSeconds: null,
            completedSets: 1,
            isCompleted: true,
            isSkipped: false,
          ),
          (
            sets: 1,
            repetitions: 10,
            durationSeconds: null,
            completedSets: 0,
            isCompleted: false,
            isSkipped: true,
          ),
        ],
        startedAt: DateTime(2026, 8, 10, 18, 0),
        endedAt: DateTime(2026, 8, 10, 18, 20),
      );
      await _seedHistorySession(
        database,
        workoutName: 'Scheda interrotta',
        completed: false,
        exercises: [
          (
            sets: 2,
            repetitions: 10,
            durationSeconds: null,
            completedSets: 1,
            isCompleted: false,
            isSkipped: false,
          ),
        ],
        startedAt: DateTime(2026, 8, 9, 8, 0),
        endedAt: DateTime(2026, 8, 9, 8, 5),
      );

      await _pumpApp(tester, database);
      await _openHistory(tester);

      expect(find.text('2 allenamenti'), findsOneWidget);
      expect(find.text('Scheda completata'), findsOneWidget);
      expect(find.text('Scheda interrotta'), findsOneWidget);
      expect(find.text('Completato'), findsOneWidget);
      expect(find.text('Interrotto'), findsOneWidget);
      expect(find.textContaining('1 esercizio completato'), findsOneWidget);
      expect(find.textContaining('1 saltato'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Completati'));
      await tester.pumpAndSettle();
      expect(find.text('Scheda completata'), findsOneWidget);
      expect(find.text('Scheda interrotta'), findsNothing);
      expect(find.text('1 allenamento'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Interrotti'));
      await tester.pumpAndSettle();
      expect(find.text('Scheda completata'), findsNothing);
      expect(find.text('Scheda interrotta'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Tutti'));
      await tester.pumpAndSettle();
      expect(find.text('Scheda completata'), findsOneWidget);
      expect(find.text('Scheda interrotta'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'dettaglio: stato per esercizio Completato/Saltato/Parziale (sezione '
    '42)',
    (tester) async {
      await _seedHistorySession(
        database,
        workoutName: 'Scheda mista',
        completed: false,
        exercises: [
          (
            sets: 1,
            repetitions: 10,
            durationSeconds: null,
            completedSets: 1,
            isCompleted: true,
            isSkipped: false,
          ),
          (
            sets: 1,
            repetitions: 10,
            durationSeconds: null,
            completedSets: 0,
            isCompleted: false,
            isSkipped: true,
          ),
          (
            sets: 3,
            repetitions: 10,
            durationSeconds: null,
            completedSets: 2,
            isCompleted: false,
            isSkipped: false,
          ),
        ],
        startedAt: DateTime(2026, 8, 10, 18, 0),
        endedAt: DateTime(2026, 8, 10, 18, 15),
      );

      await _pumpApp(tester, database);
      await _openHistory(tester);
      await tester.tap(find.text('Scheda mista'));
      await tester.pumpAndSettle();

      expect(find.text('Completato'), findsOneWidget);
      expect(find.text('Saltato'), findsOneWidget);
      expect(find.text('Parziale'), findsOneWidget);
      expect(find.text('2 di 3 serie · 3 × 10 rip.'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );
}
