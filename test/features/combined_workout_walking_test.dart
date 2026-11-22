import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:forge/app.dart';
import 'package:forge/core/routing/app_router.dart';
import 'package:forge/core/routing/app_routes.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/backup/backup_providers.dart';
import 'package:forge/data/backup/backup_restore_service.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_walking_block.dart';
import 'package:forge/domain/entities/workout_session_persistence_status.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/features/training_plan/application/workout_session_clock.dart';
import 'package:forge/features/training_plan/application/workout_session_controller.dart';
import 'package:forge/features/training_plan/application/workout_session_phase.dart';
import 'package:forge/features/training_plan/application/workout_session_restore_service.dart';
import 'package:forge/features/walking/application/walking_session_controller.dart';
import 'exercise_test_fixtures.dart';

class _Clock implements Clock, SessionClock {
  DateTime value = DateTime(2026, 11, 23, 10);
  @override
  DateTime now() => value;
  void advance(int seconds) => value = value.add(Duration(seconds: seconds));
}

void main() {
  late AppDatabase db;
  late int profileId, exerciseId;
  late DriftWorkoutRepository workouts;
  late DriftWorkoutSessionRepository sessions;
  late _Clock clock;
  final containers = <ProviderContainer>{};
  setUp(() async {
    db = memoryDatabase();
    await seedAppWith(db);
    clock = _Clock();
    profileId = (await ProfileRepositoryImpl(
      db.userProfileDao,
    ).getCurrentProfile())!.id!;
    exerciseId = (await db.select(db.eserciziTable).get()).first.id;
    workouts = DriftWorkoutRepository(db);
    sessions = DriftWorkoutSessionRepository(db);
  });
  tearDown(() async {
    for (final c in containers) {
      c.dispose();
    }
    containers.clear();
    await db.close();
  });
  ProviderContainer scope() {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        sessionClockProvider.overrideWithValue(clock),
      ],
    );
    containers.add(c);
    return c;
  }

  Future<int> create(WalkingPlacement placement) =>
      workouts.createWorkoutWithExercises(
        workout: Workout(
          profileId: profileId,
          name: 'Scheda unica',
          type: WorkoutType.fullBody,
          status: WorkoutDefinitionStatus.ready,
          origin: WorkoutOrigin.user,
          walkingBlock: WorkoutWalkingBlock(minutes: 1, placement: placement),
        ),
        exercises: [
          WorkoutExercise(
            workoutId: 0,
            exerciseId: exerciseId,
            order: 1,
            sets: 1,
            repetitions: 10,
            restSeconds: 0,
          ),
        ],
      );
  Future<void> flush() => Future<void>.delayed(Duration.zero);
  WorkoutSessionRestoreService restore() => WorkoutSessionRestoreService(
    sessionRepository: sessions,
    exerciseRepository: DriftExerciseRepository(db),
    clock: clock,
  );

  for (final placement in WalkingPlacement.values) {
    test(
      'scheda unica ${placement.name}: ordine, blocco completamento e doppio avvio camminata',
      () async {
        final id = await create(placement);
        final c = scope();
        final controller = c.read(workoutSessionControllerProvider.notifier);
        await controller.startSession((await workouts.getWorkoutDetails(id))!);
        final sessionId = c.read(workoutSessionControllerProvider)!.sessionId;
        if (placement == WalkingPlacement.afterExercises) {
          expect(
            c.read(workoutSessionControllerProvider)!.phase,
            WorkoutSessionPhase.readySet,
          );
          controller.completeCurrentSet();
        } else {
          controller.completeCurrentSet();
          expect(
            c.read(workoutSessionControllerProvider)!.currentCompletedSets,
            0,
          );
        }
        expect(
          c.read(workoutSessionControllerProvider)!.isWalkingPhase,
          isTrue,
        );
        expect(c.read(workoutSessionControllerProvider)!.isCompleted, isFalse);
        await expectLater(
          sessions.completeSession(sessionId: sessionId, endedAt: clock.now()),
          throwsStateError,
        );
        await Future.wait([
          controller.startWalkingBlock(),
          controller.startWalkingBlock(),
        ]);
        expect(await db.select(db.camminateTable).get(), hasLength(1));
        final walkingId = c
            .read(workoutSessionControllerProvider)!
            .walkingSessionId!;
        clock.advance(10);
        controller.pause();
        await flush();
        expect(c.read(walkingSessionControllerProvider)!.isPaused, isTrue);
        clock.advance(40);
        expect(
          c.read(walkingSessionControllerProvider)!.activeSeconds(clock),
          10,
        );
        controller.resume();
        await flush();
        clock.advance(5);
        expect(
          c.read(walkingSessionControllerProvider)!.activeSeconds(clock),
          15,
        );
        await controller.completeWalkingBlock();
        if (placement == WalkingPlacement.beforeExercises) {
          expect(
            c.read(workoutSessionControllerProvider)!.phase,
            WorkoutSessionPhase.readySet,
          );
          expect(
            c.read(workoutSessionControllerProvider)!.isCompleted,
            isFalse,
          );
          controller.completeCurrentSet();
          await flush();
        }
        expect(c.read(workoutSessionControllerProvider)!.isCompleted, isTrue);
        expect(
          (await sessions.getSessionById(sessionId))!.status,
          WorkoutSessionPersistenceStatus.completed,
        );
        expect(
          (await sessions.getSessionById(sessionId))!.walkingSessionId,
          walkingId,
        );
        final walk = (await DriftWalkingSessionRepository(
          db,
        ).getWalkingSession(walkingId))!;
        expect(walk.status, WalkingSessionStatus.completed);
        expect(walk.activeDuration(walk.endedAt!).inSeconds, 15);
        expect(
          (await sessions.getSessionExercises(sessionId)).single.repetitions,
          10,
        );
      },
    );
  }

  test(
    'completamento camminata da un altro ingresso aggiorna anche la scheda attiva',
    () async {
      final id = await create(WalkingPlacement.afterExercises);
      final c = scope();
      final controller = c.read(workoutSessionControllerProvider.notifier);
      await controller.startSession((await workouts.getWorkoutDetails(id))!);
      controller.completeCurrentSet();
      await controller.startWalkingBlock();
      final current = c.read(workoutSessionControllerProvider)!;
      clock.advance(60);
      await DriftWalkingSessionRepository(db).completeWalkingSession(
        sessionId: current.walkingSessionId!,
        endedAt: clock.now(),
      );
      await flush();
      expect(
        (await sessions.getSessionById(current.sessionId))!.isCompleted,
        isTrue,
      );
      expect(c.read(workoutSessionControllerProvider)!.isCompleted, isTrue);
    },
  );

  test(
    'ripresa dopo chiusura tra esercizi e camminata, poi pausa persistita',
    () async {
      final id = await create(WalkingPlacement.afterExercises);
      var c = scope();
      var controller = c.read(workoutSessionControllerProvider.notifier);
      await controller.startSession((await workouts.getWorkoutDetails(id))!);
      final sessionId = c.read(workoutSessionControllerProvider)!.sessionId;
      controller.completeCurrentSet();
      await flush();
      c.dispose();
      containers.remove(c);
      var restored = (await restore().restore(sessionId))!;
      expect(restored.isWalkingPhase, isTrue);
      expect(restored.isCompleted, isFalse);
      c = scope();
      controller = c.read(workoutSessionControllerProvider.notifier);
      controller.adoptRestoredSession(restored);
      await controller.startWalkingBlock();
      clock.advance(12);
      controller.pause();
      await flush();
      final walkingId = c
          .read(workoutSessionControllerProvider)!
          .walkingSessionId!;
      c.dispose();
      containers.remove(c);
      clock.advance(600);
      restored = (await restore().restore(sessionId))!;
      expect(restored.isPaused, isTrue);
      c = scope();
      controller = c.read(workoutSessionControllerProvider.notifier);
      controller.adoptRestoredSession(restored);
      controller.resume();
      await flush();
      clock.advance(8);
      await controller.completeWalkingBlock();
      expect((await sessions.getSessionById(sessionId))!.isCompleted, isTrue);
      final walk = (await DriftWalkingSessionRepository(
        db,
      ).getWalkingSession(walkingId))!;
      expect(walk.activeDuration(walk.endedAt!).inSeconds, 20);
    },
  );

  test(
    'interruzione scheda interrompe anche la sua camminata, senza eliminare storico',
    () async {
      final id = await create(WalkingPlacement.beforeExercises);
      final c = scope();
      final controller = c.read(workoutSessionControllerProvider.notifier);
      await controller.startSession((await workouts.getWorkoutDetails(id))!);
      await controller.startWalkingBlock();
      final state = c.read(workoutSessionControllerProvider)!;
      controller.abort();
      await flush();
      expect(
        (await sessions.getSessionById(state.sessionId))!.status,
        WorkoutSessionPersistenceStatus.aborted,
      );
      expect(
        (await DriftWalkingSessionRepository(
          db,
        ).getWalkingSession(state.walkingSessionId!))!.status,
        WalkingSessionStatus.aborted,
      );
      expect(await db.select(db.sessioniEserciziTable).get(), hasLength(1));
    },
  );

  test('snapshot camminata indipendente dalla modifica della scheda', () async {
    final id = await create(WalkingPlacement.beforeExercises);
    final sessionId = await sessions.createSession(
      profileId: profileId,
      details: (await workouts.getWorkoutDetails(id))!,
      startedAt: clock.now(),
    );
    final workout = (await workouts.getWorkoutById(id))!;
    await workouts.updateWorkout(
      workout.copyWith(
        walkingBlock: () => const WorkoutWalkingBlock(
          minutes: 50,
          placement: WalkingPlacement.afterExercises,
        ),
      ),
    );
    final state = (await restore().restore(sessionId))!;
    expect(state.walkingBlock!.minutes, 1);
    expect(state.walkingBlock!.placement, WalkingPlacement.beforeExercises);
  });

  test(
    'backup conserva e rimappa scheda, snapshot e camminata collegata; vecchio backup senza blocco',
    () async {
      final id = await create(WalkingPlacement.beforeExercises);
      final c = scope();
      final controller = c.read(workoutSessionControllerProvider.notifier);
      await controller.startSession((await workouts.getWorkoutDetails(id))!);
      await controller.startWalkingBlock();
      controller.pause();
      await flush();
      final export = await c.read(backupExportServiceProvider).export();
      expect(export.isSuccess, isTrue, reason: '${export.errors}');
      final service = BackupRestoreService(
        database: db,
        exerciseRepository: DriftExerciseRepository(db),
        exportService: c.read(backupExportServiceProvider),
      );
      final result = await service.restore(export.json!);
      expect(result.isSuccess, isTrue, reason: result.errorMessage);
      final profile = (await ProfileRepositoryImpl(
        db.userProfileDao,
      ).getCurrentProfile())!;
      final parent = (await sessions.getAllSessions(
        profileId: profile.id!,
      )).single;
      expect(parent.walkingBlock!.placement, WalkingPlacement.beforeExercises);
      expect(
        (await sessions.getWalkingBlockSession(parent.id!))!.profileId,
        parent.profileId,
      );
      expect(
        parent.walkingSessionId,
        (await db.select(db.camminateTable).get()).single.id,
      );
      final json = jsonDecode(export.json!) as Map<String, dynamic>;
      for (final row in json['data']['workouts'] as List) {
        (row as Map).remove('walkingBlock');
      }
      for (final row in json['data']['workoutSessions'] as List) {
        (row as Map)
          ..remove('walkingBlock')
          ..remove('walkingSessionLocalId');
      }
      json['metadata']['databaseVersion'] = 13;
      final legacy = await service.restore(jsonEncode(json));
      expect(legacy.isSuccess, isTrue, reason: legacy.errorMessage);
      expect(
        (await db.select(db.allenamentiTable).get()).single.camminata,
        isNull,
      );
    },
  );

  test(
    'migrazione 13 → 14 conserva schede e aggiunge configurazione e collegamento',
    () async {
      final directory = Directory.systemTemp.createTempSync(
        'forge_combined_migration_',
      );
      final file = File('${directory.path}/forge.sqlite');
      var database = AppDatabase(NativeDatabase(file));
      await seedAppWith(database);
      final profile = (await ProfileRepositoryImpl(
        database.userProfileDao,
      ).getCurrentProfile())!;
      final id = await DriftWorkoutRepository(database).createWorkout(
        Workout(
          profileId: profile.id!,
          name: 'Scheda preesistente',
          type: WorkoutType.fullBody,
          status: WorkoutDefinitionStatus.draft,
          origin: WorkoutOrigin.user,
          selectedLevels: {1, 3},
          level: 3,
        ),
      );
      await database.close();
      final raw = sqlite.sqlite3.open(file.path);
      raw.execute('ALTER TABLE allenamenti DROP COLUMN camminata');
      raw.execute(
        'ALTER TABLE sessioni_allenamento DROP COLUMN camminata_snapshot',
      );
      raw.execute('ALTER TABLE sessioni_allenamento DROP COLUMN id_camminata');
      raw.execute('PRAGMA user_version=13');
      raw.close();
      database = AppDatabase(NativeDatabase(file));
      try {
        final workout = (await DriftWorkoutRepository(
          database,
        ).getWorkoutById(id))!;
        expect(workout.name, 'Scheda preesistente');
        expect(workout.effectiveSelectedLevels, {1, 3});
        expect(workout.walkingBlock, isNull);
        expect(
          await database.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await database.close();
        final root = Directory.systemTemp.resolveSymbolicLinksSync();
        final target = directory.resolveSymbolicLinksSync();
        expect(
          target.startsWith(
            '$root${Platform.pathSeparator}forge_combined_migration_',
          ),
          isTrue,
        );
        directory.deleteSync(recursive: true);
      }
    },
  );

  testWidgets('Home: pulsante Pianifica allenamento distinto e raggiungibile', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(
            clock..value = DateTime(2026, 11, 22, 19),
          ),
        ],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.widgetWithText(OutlinedButton, 'Pianifica allenamento');
    await tester.scrollUntilVisible(button, 180);
    expect(button, findsOneWidget);
    expect(
      tester.getTopLeft(button).dy,
      greaterThan(tester.getTopLeft(find.text('Inizia allenamento').first).dy),
    );
    await Scrollable.ensureVisible(tester.element(button), alignment: 0.1);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Piano settimanale'), findsOneWidget);
    expect(find.text('23 – 29 novembre 2026'), findsOneWidget);
    await disposeCleanly(tester);
  });

  for (final placement in WalkingPlacement.values) {
    testWidgets('UI sessione completa con camminata ${placement.name}', (
      tester,
    ) async {
      final id = await create(placement);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(clock),
            sessionClockProvider.overrideWithValue(clock),
          ],
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      c.read(appRouterProvider).go(AppRoutes.workoutDetailPath(id));
      await tester.pumpAndSettle();
      expect(find.text('Camminata · 1 min'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Inizia allenamento'));
      await tester.pumpAndSettle();
      if (placement == WalkingPlacement.afterExercises) {
        await tester.tap(find.widgetWithText(FilledButton, 'Completa serie'));
        await tester.pumpAndSettle();
      }
      expect(find.textContaining('Camminata · 1 min'), findsOneWidget);
      await tester.tap(find.text('Avvia camminata'));
      await tester.pumpAndSettle();
      expect(find.text('Durata prevista: 1 min'), findsOneWidget);
      final complete = find.widgetWithText(OutlinedButton, 'Completa');
      await tester.ensureVisible(complete);
      await tester.tap(complete);
      await tester.pumpAndSettle();
      if (placement == WalkingPlacement.beforeExercises) {
        await tester.tap(find.widgetWithText(FilledButton, 'Completa serie'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Allenamento completato'), findsOneWidget);
      expect(await db.select(db.camminateTable).get(), hasLength(1));
      await disposeCleanly(tester);
    });
  }
}
