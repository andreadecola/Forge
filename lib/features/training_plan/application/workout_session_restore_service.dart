import '../../../domain/entities/persisted_session_exercise.dart';
import '../../../domain/entities/persisted_session_timer.dart';
import '../../../domain/entities/persisted_session_timer_kind.dart';
import '../../../domain/entities/persisted_workout_session.dart';
import '../../../domain/entities/workout_exercise.dart';
import '../../../domain/entities/workout_exercise_details.dart';
import '../../../domain/repositories/exercise_repository.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import 'session_timer.dart';
import 'workout_session_clock.dart';
import 'workout_session_state.dart';

/// Ricostruisce un [WorkoutSessionState] da ciò che è persistito su
/// `sessioni_allenamento`/`sessioni_esercizi` (Milestone 4.4.3), per
/// riprendere una sessione dopo la chiusura dell'app.
///
/// Se un timer era in corso (non in pausa) ed è scaduto mentre l'app era
/// chiusa, applica **un solo** passaggio della stessa transizione che il
/// controller applicherebbe in tempo reale al tick che rileva lo zero
/// (sezioni 27/28): serie completata -> recupero o serie successiva,
/// oppure recupero terminato -> serie successiva pronta. Non incatena più
/// passaggi (es. un recupero che sarebbe *a sua volta* già scaduto): nei
/// casi d'uso previsti da questa milestone l'app viene chiusa per minuti,
/// non per un tempo tale da attraversare più fasi in sequenza — uno scope
/// più ampio non è richiesto e avrebbe complicato la logica senza un
/// bisogno reale.
///
/// Se una transizione viene applicata, la correzione viene anche scritta
/// nel DB (altrimenti un ripristino successivo, senza altri eventi nel
/// mezzo, la ricalcolerebbe daccapo con un orologio diverso — sezione 14
/// non si applica qui: questo *è* un evento significativo).
class WorkoutSessionRestoreService {
  const WorkoutSessionRestoreService({
    required this.sessionRepository,
    required this.exerciseRepository,
    required this.clock,
  });

  final WorkoutSessionRepository sessionRepository;
  final ExerciseRepository exerciseRepository;
  final SessionClock clock;

  /// `null` se la sessione non esiste più, non ha più righe scheda
  /// leggibili, o la scheda originale è stata eliminata (`workoutId`
  /// diventato null via `ON DELETE SET NULL`): in quel caso la sessione
  /// resta comunque terminabile con "Termina" (non richiede il
  /// ripristino), solo non "Riprendibile" verso `/workouts/:id/session`.
  Future<WorkoutSessionState?> restore(int sessionId) async {
    final persisted = await sessionRepository.getSessionById(sessionId);
    if (persisted == null || persisted.workoutId == null) return null;

    final rows = await sessionRepository.getSessionExercises(sessionId);
    final exercises = await _resolveExercises(rows, persisted.workoutId!);
    if (exercises.isEmpty) return null;

    var state = _buildState(persisted, rows, exercises);

    if (!state.isPaused && !state.isCompleted) {
      final transitioned = _applyExpiredTimerTransition(state);
      if (transitioned != null) {
        state = transitioned;
        await _persistCorrection(state);
      }
    }

    return state;
  }

  Future<List<WorkoutExerciseDetails>> _resolveExercises(
    List<PersistedSessionExercise> rows,
    int workoutId,
  ) async {
    final result = <WorkoutExerciseDetails>[];
    for (final row in rows) {
      final exercise = await exerciseRepository.getExerciseById(row.exerciseId);
      // Il catalogo esercizi non viene mai eliminato dall'app: guardia
      // difensiva, non un caso d'uso reale.
      if (exercise == null) continue;
      result.add(
        WorkoutExerciseDetails(
          workoutExercise: WorkoutExercise(
            // Fallback all'id della riga snapshot stessa (sempre presente)
            // se `id_allenamento_esercizio` è già stato azzerato da un
            // `ON DELETE SET NULL` (scheda eliminata mentre la sessione
            // era attiva): serve solo una chiave stabile e unica per
            // questa sessione ripristinata, non deve necessariamente
            // coincidere con l'id originale di una sessione runtime che
            // non esiste più.
            id: row.workoutExerciseId ?? row.id,
            workoutId: workoutId,
            exerciseId: row.exerciseId,
            order: row.order,
            sets: row.totalSets,
            repetitions: row.repetitions,
            durationSeconds: row.durationSeconds,
            restSeconds: row.restSeconds,
          ),
          exercise: exercise,
        ),
      );
    }
    return result;
  }

  WorkoutSessionState _buildState(
    PersistedWorkoutSession persisted,
    List<PersistedSessionExercise> rows,
    List<WorkoutExerciseDetails> exercises,
  ) {
    final completedIds = <int>{};
    final skippedIds = <int>{};
    final completedSets = <int, int>{};
    for (var i = 0; i < exercises.length; i++) {
      final row = rows[i];
      final id = exercises[i].workoutExercise.id!;
      if (row.completedSets > 0) completedSets[id] = row.completedSets;
      if (row.isCompleted) completedIds.add(id);
      if (row.isSkipped) skippedIds.add(id);
    }

    return WorkoutSessionState(
      sessionId: persisted.id!,
      workoutId: persisted.workoutId!,
      workoutName: persisted.workoutNameSnapshot,
      exercises: exercises,
      startedAt: persisted.startedAt,
      currentExerciseIndex: persisted.currentExerciseIndex,
      isPaused: persisted.isPaused,
      isCompleted: persisted.isCompleted,
      completedWorkoutExerciseIds: completedIds,
      skippedWorkoutExerciseIds: skippedIds,
      completedSetsByWorkoutExerciseId: completedSets,
      exerciseTimer: _timerFor(
        persisted.timer,
        PersistedSessionTimerKind.exercise,
      ),
      restTimer: _timerFor(persisted.timer, PersistedSessionTimerKind.rest),
    );
  }

  SessionTimer? _timerFor(
    PersistedSessionTimer? timer,
    PersistedSessionTimerKind kind,
  ) {
    if (timer == null || timer.kind != kind) return null;
    return SessionTimer(
      targetSeconds: timer.targetSeconds,
      startedAt: timer.startedAt,
      pausedRemainingSeconds: timer.remainingPaused,
    );
  }

  WorkoutSessionState? _applyExpiredTimerTransition(WorkoutSessionState state) {
    final exerciseTimer = state.exerciseTimer;
    if (exerciseTimer != null && exerciseTimer.isFinished(clock)) {
      return _finishSet(state.copyWith(exerciseTimer: () => null));
    }
    final restTimer = state.restTimer;
    if (restTimer != null && restTimer.isFinished(clock)) {
      return state.copyWith(restTimer: () => null);
    }
    return null;
  }

  // Duplica deliberatamente `WorkoutSessionController._finishSet`/
  // `_advanceExercise` (Milestone 4.4.2): il ripristino non passa dal
  // controller/ticker vivo (l'app era chiusa quando il timer è arrivato a
  // zero), ma la decisione "cosa succede dopo una serie" deve restare
  // identica.
  WorkoutSessionState _finishSet(WorkoutSessionState current) {
    final id = current.currentWorkoutExerciseId;
    final we = current.currentExercise.workoutExercise;
    final totalSets = totalSetsFor(we);
    final doneSets = current.currentCompletedSets + 1;
    final updatedSets = {
      ...current.completedSetsByWorkoutExerciseId,
      id: doneSets,
    };

    if (doneSets >= totalSets) {
      final completed = {...current.completedWorkoutExerciseIds, id};
      final skipped = {...current.skippedWorkoutExerciseIds}..remove(id);
      return _advanceExercise(
        current.copyWith(completedSetsByWorkoutExerciseId: updatedSets),
        completedWorkoutExerciseIds: completed,
        skippedWorkoutExerciseIds: skipped,
      );
    }

    final rest = we.restSeconds;
    if (rest != null && rest > 0) {
      return current.copyWith(
        completedSetsByWorkoutExerciseId: updatedSets,
        restTimer: () =>
            SessionTimer(targetSeconds: rest, startedAt: clock.now()),
      );
    }
    return current.copyWith(completedSetsByWorkoutExerciseId: updatedSets);
  }

  WorkoutSessionState _advanceExercise(
    WorkoutSessionState current, {
    required Set<int> completedWorkoutExerciseIds,
    required Set<int> skippedWorkoutExerciseIds,
  }) {
    final cleared = current.copyWith(
      completedWorkoutExerciseIds: completedWorkoutExerciseIds,
      skippedWorkoutExerciseIds: skippedWorkoutExerciseIds,
      exerciseTimer: () => null,
      restTimer: () => null,
    );
    if (cleared.isLastExercise) {
      return cleared.copyWith(isCompleted: true);
    }
    return cleared.copyWith(
      currentExerciseIndex: cleared.currentExerciseIndex + 1,
    );
  }

  Future<void> _persistCorrection(WorkoutSessionState state) async {
    final now = clock.now();
    final exerciseTimer = state.exerciseTimer;
    final restTimer = state.restTimer;
    final timer = exerciseTimer != null
        ? PersistedSessionTimer(
            kind: PersistedSessionTimerKind.exercise,
            startedAt: exerciseTimer.startedAt,
            targetSeconds: exerciseTimer.targetSeconds,
            remainingPaused: exerciseTimer.pausedRemainingSeconds,
          )
        : restTimer != null
        ? PersistedSessionTimer(
            kind: PersistedSessionTimerKind.rest,
            startedAt: restTimer.startedAt,
            targetSeconds: restTimer.targetSeconds,
            remainingPaused: restTimer.pausedRemainingSeconds,
          )
        : null;

    await sessionRepository.updateProgress(
      sessionId: state.sessionId,
      currentExerciseIndex: state.currentExerciseIndex,
      exercises: state.exercises
          .map(
            (e) => SessionExerciseProgressUpdate(
              workoutExerciseId: e.workoutExercise.id!,
              completedSets:
                  state.completedSetsByWorkoutExerciseId[e
                      .workoutExercise
                      .id] ??
                  0,
              isSkipped: state.skippedWorkoutExerciseIds.contains(
                e.workoutExercise.id,
              ),
              isCompleted: state.completedWorkoutExerciseIds.contains(
                e.workoutExercise.id,
              ),
            ),
          )
          .toList(),
      timer: () => timer,
      updatedAt: now,
    );

    if (state.isCompleted) {
      await sessionRepository.completeSession(
        sessionId: state.sessionId,
        endedAt: now,
      );
    }
  }
}
