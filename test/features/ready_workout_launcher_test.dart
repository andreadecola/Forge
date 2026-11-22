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
import 'package:forge/domain/entities/persisted_session_timer.dart';
import 'package:forge/domain/entities/persisted_session_timer_kind.dart';
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
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('ready-workout-launcher')),
    140,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<int> _seedWorkout(
  AppDatabase database, {
  required String name,
  WorkoutDefinitionStatus status = WorkoutDefinitionStatus.ready,
  Set<int>? selectedLevels,
}) async {
  final profile = await ProfileRepositoryImpl(
    database.userProfileDao,
  ).getCurrentProfile();
  final repo = DriftWorkoutRepository(database);
  final workoutId = await repo.createWorkout(
    Workout(
      profileId: profile!.id!,
      name: name,
      type: WorkoutType.fullBody,
      selectedLevels: selectedLevels,
      status: status,
      origin: WorkoutOrigin.user,
    ),
  );
  final exercise = await database.eserciziDao.getByCode('EX-AVAILABLE');
  await repo.addExercise(
    workoutId: workoutId,
    exercise: WorkoutExercise(
      workoutId: workoutId,
      exerciseId: exercise!.id,
      order: 1,
      sets: 1,
      repetitions: 10,
    ),
  );
  return workoutId;
}

Future<void> tapVisible(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      target,
      140,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.1);
  await tester.pumpAndSettle();
  await tester.tap(target);
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  for (final entry in ['Home', 'Dettaglio', 'Salvataggio']) {
    testWidgets(
      '$entry: sessione persistita preservata e ripresa dopo riavvio',
      (tester) async {
        final repo = DriftWorkoutRepository(database);
        final sessions = DriftWorkoutSessionRepository(database);
        final activeId = await _seedWorkout(database, name: 'Scheda in corso');
        final initial = (await repo.getWorkoutDetails(activeId))!;
        await repo.updateExercise(
          initial.exercises.single.workoutExercise.copyWith(
            sets: () => 3,
            repetitions: () => null,
            durationSeconds: () => 15,
            restSeconds: () => 30,
          ),
        );
        final activeDetails = (await repo.getWorkoutDetails(activeId))!;
        final sessionId = await sessions.createSession(
          profileId: activeDetails.workout.profileId,
          details: activeDetails,
          startedAt: DateTime.now(),
        );
        await sessions.pauseSession(
          sessionId: sessionId,
          updatedAt: DateTime.now(),
          frozenTimer: PersistedSessionTimer(
            kind: PersistedSessionTimerKind.exercise,
            targetSeconds: 15,
            startedAt: DateTime.now(),
            remainingPaused: 12,
          ),
        );
        await _seedWorkout(database, name: 'Scheda nuova');
        await _pumpApp(tester, database);
        if (entry != 'Home') {
          await tapVisible(tester, find.text('Programma'));
          await tester.pumpAndSettle();
          await tapVisible(tester, find.text('Scheda nuova'));
          await tester.pumpAndSettle();
          if (entry == 'Salvataggio') {
            await tapVisible(
              tester,
              find.widgetWithText(FilledButton, 'Modifica'),
            );
            await tester.pumpAndSettle();
            await tapVisible(tester, find.text('Segna come pronta'));
            await tester.pumpAndSettle();
          }
        }
        final context = tester.element(find.byType(Scaffold).first);
        final container = ProviderScope.containerOf(context);
        expect(container.read(workoutSessionControllerProvider), isNull);
        await tapVisible(
          tester,
          find.widgetWithText(FilledButton, 'Inizia allenamento'),
        );
        await tester.pumpAndSettle();
        expect(find.text('Allenamento già in corso'), findsOneWidget);
        await tapVisible(tester, find.text('Vai alla sessione attiva'));
        await tester.pumpAndSettle();
        final restored = container.read(workoutSessionControllerProvider)!;
        expect(restored.sessionId, sessionId);
        expect(restored.workoutId, activeId);
        expect(restored.isPaused, isTrue);
        expect(restored.exerciseTimer!.pausedRemainingSeconds, 12);
        expect(
          (await sessions.getAllSessions(
            profileId: activeDetails.workout.profileId,
          )),
          hasLength(1),
        );
        container.read(workoutSessionControllerProvider.notifier).abort();
        await disposeCleanly(tester);
      },
    );
  }

  testWidgets(
    'Home mostra solo le schede pronte e collega la CTA alla creazione',
    (tester) async {
      await _seedWorkout(
        database,
        name: 'Scheda bozza',
        status: WorkoutDefinitionStatus.draft,
      );
      final archivedId = await _seedWorkout(
        database,
        name: 'Scheda archiviata',
      );
      await DriftWorkoutRepository(database).archiveWorkout(archivedId);

      await _pumpApp(tester, database);

      expect(find.text('Inizia allenamento'), findsOneWidget);
      expect(
        find.text('Non hai ancora schede pronte da avviare.'),
        findsOneWidget,
      );
      expect(find.text('Scheda bozza'), findsNothing);
      expect(find.text('Scheda archiviata'), findsNothing);

      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, 'Crea una scheda'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nuovo allenamento'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('Home preseleziona una scheda pronta e avvia la sessione', (
    tester,
  ) async {
    final workoutId = await _seedWorkout(
      database,
      name: 'Scheda pronta',
      selectedLevels: {1, 3},
    );
    final saved = await DriftWorkoutRepository(
      database,
    ).getWorkoutById(workoutId);
    expect(saved!.effectiveSelectedLevels, {1, 3});

    await _pumpApp(tester, database);

    expect(find.text('Scheda pronta'), findsOneWidget);
    expect(find.textContaining('Livelli 1, 3'), findsOneWidget);
    await tapVisible(
      tester,
      find.widgetWithText(FilledButton, 'Inizia allenamento'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Esercizio 1 di 1'), findsOneWidget);
    final context = tester.element(find.byType(Scaffold).first);
    final container = ProviderScope.containerOf(context);
    expect(
      container.read(workoutSessionControllerProvider)!.workoutId,
      workoutId,
    );

    container.read(workoutSessionControllerProvider.notifier).abort();
    await disposeCleanly(tester);
  });

  testWidgets('Home permette di scegliere tra più schede pronte', (
    tester,
  ) async {
    await _seedWorkout(database, name: 'Scheda A');
    final workoutB = await _seedWorkout(
      database,
      name: 'Scheda B',
      selectedLevels: {2, 5},
    );

    await _pumpApp(tester, database);
    await tapVisible(tester, find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Scheda B').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Livelli 2, 5'), findsOneWidget);
    await tapVisible(
      tester,
      find.widgetWithText(FilledButton, 'Inizia allenamento'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Esercizio 1 di 1'), findsOneWidget);
    final context = tester.element(find.byType(Scaffold).first);
    final container = ProviderScope.containerOf(context);
    expect(
      container.read(workoutSessionControllerProvider)!.workoutId,
      workoutB,
    );

    container.read(workoutSessionControllerProvider.notifier).abort();
    await disposeCleanly(tester);
  });
}
