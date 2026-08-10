import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/persisted_session_timer.dart';
import 'package:forge/domain/entities/persisted_session_timer_kind.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/features/training_plan/application/workout_session_phase.dart';
import 'package:forge/features/training_plan/application/workout_session_restore_service.dart';

import '../data/workout_test_helpers.dart';
import 'fake_session_clock.dart';

/// Test per la Milestone 4.4.3: ricostruzione di [WorkoutSessionState] da
/// ciò che è persistito, incluso il caso "timer scaduto mentre l'app era
/// chiusa" (sezioni 50/51). Usa un `FakeSessionClock` manuale — nessuna
/// attesa reale — e un DB SQLite vero in memoria (nessun fake per
/// repository/DAO: qui interessa che la ricostruzione funzioni davvero
/// sopra la persistenza reale).
SessionExerciseProgressUpdate _progress(
  int workoutExerciseId,
  int completedSets, {
  bool isSkipped = false,
  bool isCompleted = false,
}) {
  return SessionExerciseProgressUpdate(
    workoutExerciseId: workoutExerciseId,
    completedSets: completedSets,
    isSkipped: isSkipped,
    isCompleted: isCompleted,
  );
}

void main() {
  late AppDatabase database;
  late DriftWorkoutRepository workoutRepository;
  late DriftWorkoutSessionRepository sessionRepository;
  late WorkoutSessionRestoreService restoreService;
  late FakeSessionClock clock;
  late int profileId;
  late int workoutId;
  late int workoutExerciseAId; // ripetizioni, sets 2, rest 10
  late int workoutExerciseBId; // a tempo, sets 2, durata 20, rest 5

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    workoutRepository = DriftWorkoutRepository(database);
    sessionRepository = DriftWorkoutSessionRepository(database);
    clock = FakeSessionClock(DateTime(2026, 1, 1, 9));
    restoreService = WorkoutSessionRestoreService(
      sessionRepository: sessionRepository,
      exerciseRepository: DriftExerciseRepository(database),
      clock: clock,
    );

    profileId = await insertProfilo(database);
    final categoryId = await insertCategoria(database);
    final exerciseId = await insertEsercizio(
      database,
      codice: 'RESTORE-001',
      idCategoria: categoryId,
    );

    workoutId = await workoutRepository.createWorkout(
      Workout(
        profileId: profileId,
        name: 'Scheda da ripristinare',
        type: WorkoutType.fullBody,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
      ),
    );
    workoutExerciseAId = await workoutRepository.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 1,
        sets: 2,
        repetitions: 8,
        restSeconds: 10,
      ),
    );
    workoutExerciseBId = await workoutRepository.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 2,
        sets: 2,
        durationSeconds: 20,
        restSeconds: 5,
      ),
    );
  });

  tearDown(() => database.close());

  Future<int> createSession() async {
    final details = (await workoutRepository.getWorkoutDetails(workoutId))!;
    return sessionRepository.createSession(
      profileId: profileId,
      details: details,
      startedAt: clock.now(),
    );
  }

  test(
    'ripristino normale (nessun timer): ricostruisce progresso e indice',
    () async {
      final sessionId = await createSession();
      await sessionRepository.updateProgress(
        sessionId: sessionId,
        currentExerciseIndex: 1,
        exercises: [
          _progress(workoutExerciseAId, 2, isCompleted: true),
          _progress(workoutExerciseBId, 1),
        ],
        updatedAt: clock.now(),
      );

      final state = await restoreService.restore(sessionId);

      expect(state, isNotNull);
      expect(state!.sessionId, sessionId);
      expect(state.workoutId, workoutId);
      expect(state.workoutName, 'Scheda da ripristinare');
      expect(state.currentExerciseIndex, 1);
      expect(state.completedWorkoutExerciseIds, {workoutExerciseAId});
      expect(state.completedSetsByWorkoutExerciseId[workoutExerciseBId], 1);
      expect(state.phase, WorkoutSessionPhase.readySet);
    },
  );

  test(
    'timer in corso non ancora scaduto: residuo ricostruito dal timestamp',
    () async {
      final sessionId = await createSession();
      final startedAt = clock.now();
      await sessionRepository.updateTimerState(
        sessionId: sessionId,
        timer: PersistedSessionTimer(
          kind: PersistedSessionTimerKind.exercise,
          startedAt: startedAt,
          targetSeconds: 20,
        ),
        updatedAt: startedAt,
      );

      clock.advance(const Duration(seconds: 12));
      final state = await restoreService.restore(sessionId);

      expect(state!.phase, WorkoutSessionPhase.timedSetRunning);
      expect(state.exerciseTimer!.remainingSeconds(clock), 8);
    },
  );

  test(
    'timer della serie scaduto mentre l\'app era chiusa: serie completata, '
    'passa al recupero con countdown ripartito da ora (sezione 27)',
    () async {
      final sessionId = await createSession();
      // Va su B (indice 1), avvia la sua prima serie a tempo.
      await sessionRepository.updateProgress(
        sessionId: sessionId,
        currentExerciseIndex: 1,
        exercises: [_progress(workoutExerciseAId, 2, isCompleted: true)],
        updatedAt: clock.now(),
      );
      final startedAt = clock.now();
      await sessionRepository.updateTimerState(
        sessionId: sessionId,
        timer: PersistedSessionTimer(
          kind: PersistedSessionTimerKind.exercise,
          startedAt: startedAt,
          targetSeconds: 20,
        ),
        updatedAt: startedAt,
      );

      // L'app "resta chiusa" per 50 secondi: il countdown di 20 sec è
      // scaduto da tempo.
      clock.advance(const Duration(seconds: 50));
      final state = await restoreService.restore(sessionId);

      expect(state!.currentWorkoutExerciseId, workoutExerciseBId);
      expect(
        state.completedSetsByWorkoutExerciseId[workoutExerciseBId],
        1,
        reason: 'la serie scaduta viene contata come completata',
      );
      expect(state.phase, WorkoutSessionPhase.resting);
      expect(
        state.restTimer!.remainingSeconds(clock),
        5,
        reason:
            'il countdown di recupero riparte da ora (istante del '
            'ripristino), non da quando sarebbe scattato mentre l\'app era '
            'chiusa',
      );

      // La correzione deve essere persistita: un secondo ripristino,
      // senza altri eventi nel mezzo, deve ritrovare lo stesso stato (non
      // ricalcolare la transizione una seconda volta con un orologio
      // diverso).
      clock.advance(const Duration(seconds: 1));
      final state2 = await restoreService.restore(sessionId);
      expect(state2!.phase, WorkoutSessionPhase.resting);
      expect(state2.restTimer!.remainingSeconds(clock), 4);
    },
  );

  test('recupero scaduto mentre l\'app era chiusa: torna pronta per la serie '
      'successiva, il timer non riparte da solo (sezione 28)', () async {
    final sessionId = await createSession();
    final startedAt = clock.now();
    await sessionRepository.updateProgress(
      sessionId: sessionId,
      exercises: [_progress(workoutExerciseAId, 1)],
      timer: () => PersistedSessionTimer(
        kind: PersistedSessionTimerKind.rest,
        startedAt: startedAt,
        targetSeconds: 10,
      ),
      updatedAt: startedAt,
    );

    clock.advance(const Duration(seconds: 40));
    final state = await restoreService.restore(sessionId);

    expect(state!.phase, WorkoutSessionPhase.readySet);
    expect(state.restTimer, isNull);
    expect(state.exerciseTimer, isNull);
    expect(
      state.completedSetsByWorkoutExerciseId[workoutExerciseAId],
      1,
      reason:
          'invariato: la serie era già stata contata prima del '
          'recupero',
    );
  });

  test(
    'ultima serie dell\'ultimo esercizio scaduta mentre l\'app era chiusa: '
    'la sessione risulta completata, il record viene marcato COMPLETED',
    () async {
      final sessionId = await createSession();
      await sessionRepository.updateProgress(
        sessionId: sessionId,
        currentExerciseIndex: 1,
        exercises: [
          _progress(workoutExerciseAId, 2, isCompleted: true),
          _progress(workoutExerciseBId, 1),
        ],
        updatedAt: clock.now(),
      );
      final startedAt = clock.now();
      await sessionRepository.updateTimerState(
        sessionId: sessionId,
        timer: PersistedSessionTimer(
          kind: PersistedSessionTimerKind.exercise,
          startedAt: startedAt,
          targetSeconds: 20,
        ),
        updatedAt: startedAt,
      );

      clock.advance(const Duration(minutes: 5));
      final state = await restoreService.restore(sessionId);

      expect(state!.isCompleted, isTrue);
      expect(state.completedWorkoutExerciseIds, {
        workoutExerciseAId,
        workoutExerciseBId,
      });

      final persisted = await sessionRepository.getSessionById(sessionId);
      expect(persisted!.isCompleted, isTrue);
      expect(persisted.endedAt, isNotNull);
    },
  );

  test(
    'sessione in pausa: il residuo congelato non cambia, nessuna '
    'transizione anche se il tempo passato supera il target (sezione 29)',
    () async {
      final sessionId = await createSession();
      final startedAt = clock.now();
      await sessionRepository.pauseSession(
        sessionId: sessionId,
        frozenTimer: PersistedSessionTimer(
          kind: PersistedSessionTimerKind.exercise,
          startedAt: startedAt,
          targetSeconds: 20,
          remainingPaused: 3,
        ),
        updatedAt: startedAt,
      );

      clock.advance(const Duration(hours: 2));
      final state = await restoreService.restore(sessionId);

      expect(state!.isPaused, isTrue);
      expect(state.phase, WorkoutSessionPhase.paused);
      expect(state.exerciseTimer!.remainingSeconds(clock), 3);
    },
  );

  test(
    'scheda originale eliminata: il ripristino non è possibile (null)',
    () async {
      final sessionId = await createSession();
      await workoutRepository.deleteWorkout(workoutId);

      expect(await restoreService.restore(sessionId), isNull);
    },
  );
}
