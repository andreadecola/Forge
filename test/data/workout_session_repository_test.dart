import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/domain/entities/persisted_session_timer.dart';
import 'package:forge/domain/entities/persisted_session_timer_kind.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_details.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/entities/workout_session_persistence_status.dart';
import 'package:forge/domain/repositories/workout_session_repository.dart';

import 'workout_test_helpers.dart';

/// Test di repository per la Milestone 4.4.3: usa un
/// `DriftWorkoutSessionRepository` vero (nessun fake), su un database
/// SQLite in memoria — copre createSession/updateProgress/pause/resume/
/// complete/abort e il comportamento delle FK (`ON DELETE SET NULL`) già
/// verificato a livello di schema in `workout_session_schema_test.dart`,
/// qui passando per l'API di dominio invece delle righe Drift grezze.
void main() {
  late AppDatabase database;
  late DriftWorkoutRepository workoutRepository;
  late DriftWorkoutSessionRepository sessionRepository;
  late int profileId;
  late int workoutId;
  late int workoutExerciseAId;
  late int workoutExerciseBId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    workoutRepository = DriftWorkoutRepository(database);
    sessionRepository = DriftWorkoutSessionRepository(database);

    profileId = await insertProfilo(database);
    final categoryId = await insertCategoria(database);
    final exerciseId = await insertEsercizio(
      database,
      codice: 'SESS-REPO-001',
      idCategoria: categoryId,
    );

    workoutId = await workoutRepository.createWorkout(
      Workout(
        profileId: profileId,
        name: 'Scheda sessione',
        type: WorkoutType.fullBody,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
      ),
    );
    // A: a ripetizioni, sets null -> deve diventare 1 nello snapshot.
    workoutExerciseAId = await workoutRepository.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 1,
        repetitions: 10,
        restSeconds: 15,
      ),
    );
    // B: a tempo.
    workoutExerciseBId = await workoutRepository.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 2,
        sets: 2,
        durationSeconds: 20,
      ),
    );
  });

  tearDown(() => database.close());

  Future<WorkoutDetails?> details() =>
      workoutRepository.getWorkoutDetails(workoutId);

  test('createSession crea la sessione e lo snapshot di ogni riga, con '
      'sets null -> 1 serie', () async {
    final startedAt = DateTime(2026, 1, 1, 10);
    final sessionId = await sessionRepository.createSession(
      profileId: profileId,
      details: (await details())!,
      startedAt: startedAt,
    );

    final session = await sessionRepository.getSessionById(sessionId);
    expect(session, isNotNull);
    expect(session!.workoutId, workoutId);
    expect(session.profileId, profileId);
    expect(session.workoutNameSnapshot, 'Scheda sessione');
    expect(session.status, WorkoutSessionPersistenceStatus.inProgress);
    expect(session.currentExerciseIndex, 0);
    expect(session.startedAt, startedAt);
    expect(session.isPaused, isFalse);
    expect(session.isCompleted, isFalse);
    expect(session.timer, isNull);

    final exercises = await sessionRepository.getSessionExercises(sessionId);
    expect(exercises, hasLength(2));
    final a = exercises.firstWhere(
      (e) => e.workoutExerciseId == workoutExerciseAId,
    );
    expect(
      a.totalSets,
      1,
      reason: 'sets assente nella riga scheda -> 1 nello snapshot',
    );
    expect(a.repetitions, 10);
    expect(a.restSeconds, 15);
    expect(a.completedSets, 0);
    expect(a.isSkipped, isFalse);
    expect(a.isCompleted, isFalse);

    final b = exercises.firstWhere(
      (e) => e.workoutExerciseId == workoutExerciseBId,
    );
    expect(b.totalSets, 2);
    expect(b.durationSeconds, 20);
  });

  test('createSession rifiuta una seconda sessione attiva per lo stesso '
      'profilo', () async {
    await sessionRepository.createSession(
      profileId: profileId,
      details: (await details())!,
      startedAt: DateTime(2026, 1, 1),
    );

    expect(
      () async => sessionRepository.createSession(
        profileId: profileId,
        details: (await details())!,
        startedAt: DateTime(2026, 1, 1, 1),
      ),
      throwsA(isA<ActiveSessionAlreadyExistsException>()),
    );
  });

  test('getActiveSession: nessuna sessione -> null; sessione IN_PROGRESS -> '
      'trovata', () async {
    expect(
      await sessionRepository.getActiveSession(profileId: profileId),
      isNull,
    );

    final sessionId = await sessionRepository.createSession(
      profileId: profileId,
      details: (await details())!,
      startedAt: DateTime(2026, 1, 1),
    );

    final active = await sessionRepository.getActiveSession(
      profileId: profileId,
    );
    expect(active, isNotNull);
    expect(active!.id, sessionId);
  });

  test('updateProgress aggiorna indice, progresso delle righe e timer in '
      'un colpo solo', () async {
    final sessionId = await sessionRepository.createSession(
      profileId: profileId,
      details: (await details())!,
      startedAt: DateTime(2026, 1, 1),
    );

    final timer = PersistedSessionTimer(
      kind: PersistedSessionTimerKind.rest,
      startedAt: DateTime(2026, 1, 1, 10, 5),
      targetSeconds: 15,
    );
    await sessionRepository.updateProgress(
      sessionId: sessionId,
      currentExerciseIndex: 1,
      exercises: [
        SessionExerciseProgressUpdate(
          workoutExerciseId: workoutExerciseAId,
          completedSets: 1,
          isSkipped: false,
          isCompleted: true,
        ),
      ],
      timer: () => timer,
      updatedAt: DateTime(2026, 1, 1, 10, 5),
    );

    final session = await sessionRepository.getSessionById(sessionId);
    expect(session!.currentExerciseIndex, 1);
    expect(session.timer!.kind, PersistedSessionTimerKind.rest);
    expect(session.timer!.targetSeconds, 15);

    final exercises = await sessionRepository.getSessionExercises(sessionId);
    final a = exercises.firstWhere(
      (e) => e.workoutExerciseId == workoutExerciseAId,
    );
    expect(a.completedSets, 1);
    expect(a.isCompleted, isTrue);
    final b = exercises.firstWhere(
      (e) => e.workoutExerciseId == workoutExerciseBId,
    );
    expect(
      b.completedSets,
      0,
      reason: 'non incluso nell\'aggiornamento -> invariato',
    );
  });

  test('pauseSession e resumeSession aggiornano stato/timer', () async {
    final sessionId = await sessionRepository.createSession(
      profileId: profileId,
      details: (await details())!,
      startedAt: DateTime(2026, 1, 1),
    );

    final frozen = PersistedSessionTimer(
      kind: PersistedSessionTimerKind.exercise,
      startedAt: DateTime(2026, 1, 1, 10),
      targetSeconds: 20,
      remainingPaused: 12,
    );
    await sessionRepository.pauseSession(
      sessionId: sessionId,
      frozenTimer: frozen,
      updatedAt: DateTime(2026, 1, 1, 10, 1),
    );
    var session = await sessionRepository.getSessionById(sessionId);
    expect(session!.status, WorkoutSessionPersistenceStatus.paused);
    expect(session.isPaused, isTrue);
    expect(session.timer!.remainingPaused, 12);

    final resumed = PersistedSessionTimer(
      kind: PersistedSessionTimerKind.exercise,
      startedAt: DateTime(2026, 1, 1, 10, 2),
      targetSeconds: 12,
    );
    await sessionRepository.resumeSession(
      sessionId: sessionId,
      resumedTimer: resumed,
      updatedAt: DateTime(2026, 1, 1, 10, 2),
    );
    session = await sessionRepository.getSessionById(sessionId);
    expect(session!.status, WorkoutSessionPersistenceStatus.inProgress);
    expect(session.isPaused, isFalse);
    expect(session.timer!.remainingPaused, isNull);
  });

  test(
    'completeSession marca COMPLETED con data_fine e non è più "attiva"',
    () async {
      final sessionId = await sessionRepository.createSession(
        profileId: profileId,
        details: (await details())!,
        startedAt: DateTime(2026, 1, 1),
      );
      final endedAt = DateTime(2026, 1, 1, 10, 30);

      await sessionRepository.completeSession(
        sessionId: sessionId,
        endedAt: endedAt,
      );

      final session = await sessionRepository.getSessionById(sessionId);
      expect(session!.status, WorkoutSessionPersistenceStatus.completed);
      expect(session.isCompleted, isTrue);
      expect(session.endedAt, endedAt);
      expect(
        await sessionRepository.getActiveSession(profileId: profileId),
        isNull,
      );
    },
  );

  test(
    'abortSession marca ABORTED con data_fine, non elimina il record',
    () async {
      final sessionId = await sessionRepository.createSession(
        profileId: profileId,
        details: (await details())!,
        startedAt: DateTime(2026, 1, 1),
      );
      final endedAt = DateTime(2026, 1, 1, 10, 5);

      await sessionRepository.abortSession(
        sessionId: sessionId,
        endedAt: endedAt,
      );

      final session = await sessionRepository.getSessionById(sessionId);
      expect(session, isNotNull, reason: 'il record non viene eliminato');
      expect(session!.status, WorkoutSessionPersistenceStatus.aborted);
      expect(session.endedAt, endedAt);
      expect(
        await sessionRepository.getActiveSession(profileId: profileId),
        isNull,
      );
    },
  );

  test('eliminare la scheda mentre una sessione esiste: la sessione sopravvive '
      'orfana (id_allenamento null), lo snapshot resta leggibile', () async {
    final sessionId = await sessionRepository.createSession(
      profileId: profileId,
      details: (await details())!,
      startedAt: DateTime(2026, 1, 1),
    );

    await workoutRepository.deleteWorkout(workoutId);

    final session = await sessionRepository.getSessionById(sessionId);
    expect(session, isNotNull);
    expect(session!.workoutId, isNull);
    expect(session.workoutNameSnapshot, 'Scheda sessione');

    final exercises = await sessionRepository.getSessionExercises(sessionId);
    expect(exercises, hasLength(2));
    expect(exercises.every((e) => e.workoutExerciseId == null), isTrue);
    final a = exercises.firstWhere((e) => e.repetitions == 10);
    expect(a.totalSets, 1, reason: 'lo snapshot dei parametri resta intatto');
  });
}
