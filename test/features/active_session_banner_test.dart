import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/entities/workout_session_persistence_status.dart';
import 'package:forge/features/training_plan/application/workout_session_controller.dart';

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

Future<int> _seedActiveSession(
  AppDatabase database, {
  required String workoutName,
}) async {
  final profile = await ProfileRepositoryImpl(
    database.userProfileDao,
  ).getCurrentProfile();
  final workoutRepository = DriftWorkoutRepository(database);
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
  await workoutRepository.addExercise(
    workoutId: workoutId,
    exercise: WorkoutExercise(
      workoutId: workoutId,
      exerciseId: exerciseRow!.id,
      order: 1,
      sets: 1,
      repetitions: 10,
    ),
  );

  final details = (await workoutRepository.getWorkoutDetails(workoutId))!;
  return DriftWorkoutSessionRepository(database).createSession(
    profileId: profile.id!,
    details: details,
    startedAt: DateTime(2026, 1, 1, 9),
  );
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

  testWidgets('nessuna sessione persistita -> nessun banner in Dashboard', (
    tester,
  ) async {
    await _pumpApp(tester, database);

    expect(find.text('Allenamento in corso'), findsNothing);

    await disposeCleanly(tester);
  });

  testWidgets(
    'sessione persistita ancora attiva -> banner "Allenamento in corso" con '
    'nome scheda in Dashboard e in Programma, senza navigare da sola',
    (tester) async {
      await _seedActiveSession(database, workoutName: 'Scheda da riprendere');
      await _pumpApp(tester, database);

      expect(find.text('Allenamento in corso'), findsOneWidget);
      expect(find.text('Scheda da riprendere'), findsOneWidget);
      // Non ha navigato da sola alla sessione (sezione 32): siamo ancora
      // in Dashboard, nessuna sessione runtime attiva.
      expect(find.text('FORGE'), findsOneWidget);
      expect(container(tester).read(workoutSessionControllerProvider), isNull);

      await tester.tap(find.text('Programma'));
      await tester.pumpAndSettle();
      // `StatefulShellRoute.indexedStack` mantiene montata anche la
      // Dashboard (fuori schermo): il testo del banner compare quindi due
      // volte nell'albero, non una sola.
      expect(find.text('Allenamento in corso'), findsWidgets);
      expect(find.text('Scheda da riprendere'), findsWidgets);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    '"Termina" chiede conferma, poi marca ABORTED e il banner scompare',
    (tester) async {
      final sessionId = await _seedActiveSession(
        database,
        workoutName: 'Scheda da terminare',
      );
      await _pumpApp(tester, database);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Termina'));
      await tester.pumpAndSettle();
      expect(find.text('Terminare l\'allenamento in corso?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Termina'));
      await tester.pumpAndSettle();

      expect(find.text('Allenamento in corso'), findsNothing);

      final session = await DriftWorkoutSessionRepository(
        database,
      ).getSessionById(sessionId);
      expect(session!.status, WorkoutSessionPersistenceStatus.aborted);
      expect(session.endedAt, isNotNull);

      await disposeCleanly(tester);
    },
  );

  testWidgets('"Riprendi" ricostruisce lo stato ed entra nella sessione', (
    tester,
  ) async {
    final sessionId = await _seedActiveSession(
      database,
      workoutName: 'Scheda da riprendere',
    );
    await _pumpApp(tester, database);

    await tester.tap(find.widgetWithText(FilledButton, 'Riprendi'));
    await tester.pumpAndSettle();

    expect(find.text('Scheda da riprendere'), findsWidgets);
    expect(find.text('Esercizio 1 di 1'), findsOneWidget);
    final session = container(tester).read(workoutSessionControllerProvider);
    expect(session, isNotNull);
    expect(session!.sessionId, sessionId);

    await disposeCleanly(tester);
  });
}
