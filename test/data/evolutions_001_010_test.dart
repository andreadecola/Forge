import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/backup/backup_providers.dart';
import 'package:forge/data/backup/backup_restore_service.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/performance_repository.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/set_performance.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import '../features/exercise_test_fixtures.dart';

void main() {
  late AppDatabase db;
  late int profileId, exerciseId;
  late DriftWorkoutRepository workouts;
  late DriftWorkoutSessionRepository sessions;
  late DriftPlannedActivityRepository activities;
  final start = DateTime(2026, 11, 23, 10);

  Future<int> createWorkout({
    WorkoutOrigin origin = WorkoutOrigin.user,
    bool timed = false,
  }) async {
    return workouts.createWorkoutWithExercises(
      workout: Workout(
        profileId: profileId,
        name: 'Prova',
        type: WorkoutType.fullBody,
        level: 5,
        selectedLevels: {1, 3, 5},
        status: WorkoutDefinitionStatus.ready,
        origin: origin,
      ),
      exercises: [
        WorkoutExercise(
          workoutId: 0,
          exerciseId: exerciseId,
          order: 1,
          sets: 3,
          repetitions: timed ? null : 10,
          durationSeconds: timed ? 15 : null,
          restSeconds: 30,
        ),
      ],
    );
  }

  Future<int> createSession(int workoutId) async {
    final details = (await workouts.getWorkoutDetails(workoutId))!;
    return sessions.createSession(
      profileId: profileId,
      details: details,
      startedAt: start,
    );
  }

  setUp(() async {
    db = memoryDatabase();
    await seedAppWith(db);
    profileId = (await ProfileRepositoryImpl(
      db.userProfileDao,
    ).getCurrentProfile())!.id!;
    exerciseId = (await db.select(db.eserciziTable).get()).first.id;
    workouts = DriftWorkoutRepository(db);
    sessions = DriftWorkoutSessionRepository(db);
    activities = DriftPlannedActivityRepository(db.attivitaPianificateDao);
  });
  tearDown(() => db.close());

  test(
    'EVO-001 elimina solo camminate concluse e aggiorna collegamenti e stream',
    () async {
      final repo = DriftWalkingSessionRepository(db);
      final id = await repo.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: start,
          endedAt: start.add(const Duration(minutes: 20)),
          status: WalkingSessionStatus.completed,
          steps: 1000,
          distanceMeters: 800,
        ),
      );
      final activityId = await activities.addPlannedActivity(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 11, 23),
          type: PlannedActivityType.walk,
          origin: PlannedActivityOrigin.user,
          walkingSessionId: id,
        ),
      );
      final active = await repo.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: start,
          status: WalkingSessionStatus.inProgress,
        ),
      );
      final changes = <List<WalkingSession>>[];
      final sub = repo
          .watchWalkingHistory(profileId: profileId)
          .listen(changes.add);
      await Future<void>.delayed(Duration.zero);
      await expectLater(repo.deleteWalkingSession(active), throwsStateError);
      await repo.deleteWalkingSession(id);
      expect(await repo.getWalkingHistory(profileId: profileId), isEmpty);
      expect(await repo.getWalkingSession(active), isNotNull);
      expect((await activities.getById(activityId))!.walkingSessionId, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(changes.last, isEmpty);
      await sub.cancel();
    },
  );

  for (final origin in WorkoutOrigin.values) {
    test(
      'EVO-002 protegge sessione attiva e conserva storico per ${origin.name}',
      () async {
        final id = await createWorkout(origin: origin);
        final sessionId = await createSession(id);
        await expectLater(workouts.deleteWorkout(id), throwsStateError);
        expect(await workouts.getWorkoutById(id), isNotNull);
        await sessions.completeSession(
          sessionId: sessionId,
          endedAt: start.add(const Duration(minutes: 10)),
        );
        final before = await sessions.getSessionExercises(sessionId);
        await workouts.deleteWorkout(id);
        expect(await workouts.getWorkoutById(id), isNull);
        final after = await sessions.getSessionExercises(sessionId);
        expect(after.length, before.length);
        expect(after.single.repetitions, before.single.repetitions);
        expect(after.single.workoutExerciseId, isNull);
        expect((await sessions.getSessionById(sessionId))!.workoutId, isNull);
        expect(
          (await sessions.getSessionHistoryDetails(
            sessionId,
          ))!.session.workoutName,
          'Prova',
        );
        expect(
          await db.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );
  }

  test(
    'EVO-009 diario persistente, aggiornamento stessa serie e prescrizioni intatte',
    () async {
      final id = await createWorkout();
      final sessionId = await createSession(id);
      final repo = PerformanceRepository(db);
      await repo.saveSet(
        sessionId: sessionId,
        order: 1,
        performance: const SetPerformance(
          setNumber: 1,
          repetitions: 8,
          loadKg: 5,
          effort: 6,
        ),
      );
      await repo.saveSet(
        sessionId: sessionId,
        order: 1,
        performance: const SetPerformance(
          setNumber: 1,
          repetitions: 9,
          loadKg: 6,
          effort: 7,
        ),
      );
      await repo.saveSet(
        sessionId: sessionId,
        order: 1,
        performance: const SetPerformance(setNumber: 3, repetitions: 6),
      );
      final values = await PerformanceRepository(
        db,
      ).watchSets(sessionId, 1).first;
      expect(values.map((p) => p.setNumber), [1, 3]);
      expect(values.first.repetitions, 9);
      final snapshot = (await sessions.getSessionExercises(sessionId)).single;
      expect(snapshot.repetitions, 10);
      expect(snapshot.completedSets, 0);
      expect(snapshot.restSeconds, 30);
      expect(snapshot.performedSets.length, 2);
      await sessions.completeSession(
        sessionId: sessionId,
        endedAt: start.add(const Duration(minutes: 5)),
      );
      expect(
        (await repo.watchHistory(profileId, exerciseId).first)
            .single
            .sets
            .length,
        2,
      );
      await workouts.deleteWorkout(id);
      expect((await repo.watchSets(sessionId, 1).first).length, 2);
    },
  );

  test('EVO-009 valida dati e distingue secondi da ripetizioni', () async {
    final sessionId = await createSession(await createWorkout(timed: true));
    final repo = PerformanceRepository(db);
    for (final p in [
      const SetPerformance(setNumber: 0, durationSeconds: 15),
      const SetPerformance(setNumber: 4, durationSeconds: 15),
      const SetPerformance(setNumber: 1, repetitions: 10),
      const SetPerformance(setNumber: 1, loadKg: -1),
      const SetPerformance(setNumber: 1, effort: 11),
      const SetPerformance(setNumber: 1),
    ]) {
      await expectLater(
        repo.saveSet(sessionId: sessionId, order: 1, performance: p),
        throwsFormatException,
      );
    }
    await repo.saveSet(
      sessionId: sessionId,
      order: 1,
      performance: const SetPerformance(setNumber: 1, durationSeconds: 12),
    );
    expect(
      (await sessions.getSessionExercises(sessionId)).single.durationSeconds,
      15,
    );
    expect(
      (await repo.watchSets(sessionId, 1).first).single.durationSeconds,
      12,
    );
  });

  test(
    'schema 12 -> 13 conserva dati e aggiunge solo diario e rinvio promemoria',
    () async {
      final dir = Directory.systemTemp.createTempSync('forge_migration13_');
      final file = File('${dir.path}/test.sqlite');
      var database = AppDatabase(NativeDatabase(file));
      await seedAppWith(database);
      final before = await database.select(database.userProfilesTable).get();
      await database.close();
      final raw = sqlite.sqlite3.open(file.path);
      raw.execute('ALTER TABLE sessioni_esercizi DROP COLUMN prestazioni');
      raw.execute(
        'ALTER TABLE attivita_pianificate DROP COLUMN promemoria_rinviato_al',
      );
      raw.execute('PRAGMA user_version = 12');
      raw.close();
      database = AppDatabase(NativeDatabase(file));
      try {
        expect(
          (await database.select(database.userProfilesTable).get()).single.name,
          before.single.name,
        );
        expect(
          (await database
                  .customSelect('PRAGMA table_info(sessioni_esercizi)')
                  .get())
              .map((r) => r.read<String>('name')),
          contains('prestazioni'),
        );
        expect(
          (await database
                  .customSelect('PRAGMA table_info(attivita_pianificate)')
                  .get())
              .map((r) => r.read<String>('name')),
          contains('promemoria_rinviato_al'),
        );
        expect(
          await database.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await database.close();
        dir.deleteSync(recursive: true);
      }
    },
  );

  test(
    'EVO-003/009 round-trip backup conserva diario, rinvio e livelli; corrotto non cancella dati',
    () async {
      final id = await createWorkout();
      final sessionId = await createSession(id);
      await PerformanceRepository(db).saveSet(
        sessionId: sessionId,
        order: 1,
        performance: const SetPerformance(
          setNumber: 2,
          repetitions: 7,
          loadKg: 2.5,
          effort: 8,
        ),
      );
      final reminder = DateTime(2026, 11, 23, 17, 25);
      await activities.addPlannedActivity(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 11, 23),
          type: PlannedActivityType.walk,
          origin: PlannedActivityOrigin.user,
          reminderAt: reminder,
        ),
      );
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final exporter = container.read(backupExportServiceProvider);
      final exported = await exporter.export();
      expect(exported.isSuccess, isTrue, reason: '${exported.errors}');
      final restore = BackupRestoreService(
        database: db,
        exerciseRepository: DriftExerciseRepository(db),
        exportService: exporter,
      );
      final result = await restore.restore(exported.json!);
      expect(result.isSuccess, isTrue, reason: result.errorMessage);
      final restored = (await db.select(db.sessioniEserciziTable).get()).single;
      expect(jsonDecode(restored.prestazioni), [
        {
          'setNumber': 2,
          'repetitions': 7,
          'durationSeconds': null,
          'loadKg': 2.5,
          'effort': 8,
        },
      ]);
      expect(
        (await db.select(db.attivitaPianificateTable).get())
            .single
            .promemoriaRinviatoAl,
        reminder,
      );
      final restoredProfile = (await ProfileRepositoryImpl(
        db.userProfileDao,
      ).getCurrentProfile())!.id!;
      expect(
        (await workouts.getAllWorkouts(
          profileId: restoredProfile,
        )).single.effectiveSelectedLevels,
        {1, 3, 5},
      );
      final corrupt = jsonDecode(exported.json!) as Map<String, dynamic>;
      corrupt['data']['workoutSessionExercises'][0]['performedSets'][0]['effort'] =
          11;
      final rejected = await restore.restore(jsonEncode(corrupt));
      expect(rejected.isSuccess, isFalse);
      expect(
        (await db.select(db.sessioniEserciziTable).get()).single.id,
        restored.id,
      );
    },
  );
}
