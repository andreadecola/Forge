import '../../../domain/entities/workout_exercise.dart';
import '../../../domain/entities/workout_exercise_details.dart';
import 'session_timer.dart';
import 'workout_session_phase.dart';

/// Numero di serie da eseguire per [exercise] a runtime. `sets == null`
/// nel catalogo/scheda viene trattato come **1 serie** solo per la
/// sessione: è un fallback esclusivamente runtime, non scrive né
/// modifica mai [WorkoutExercise] (Milestone 4.4.2, sezione 18).
int totalSetsFor(WorkoutExercise exercise) => exercise.sets ?? 1;

/// Un esercizio è "a tempo" se ha una durata impostata. Se per qualche
/// motivo (errore di composizione, evoluzione futura) fossero presenti
/// sia `durationSeconds` sia `repetitions`, **`durationSeconds` prevale**:
/// un esercizio temporizzato richiede comunque un timer, mentre le
/// ripetizioni restano solo un'informazione testuale in quel caso
/// (Milestone 4.4.2, sezione 19).
bool isTimedExercise(WorkoutExercise exercise) =>
    exercise.durationSeconds != null;

/// Stato runtime di una sessione di allenamento: vive solo in memoria,
/// non viene mai persistito (Milestone 4.4.1, estesa con serie/timer in
/// Milestone 4.4.2). Se l'app termina, la sessione viene persa —
/// accettabile per queste milestone (nessuna tabella/storico
/// allenamenti).
///
/// [exercises] è l'istantanea, presa all'avvio, delle righe scheda già
/// risolte con l'esercizio del catalogo (stesso ordine di
/// [WorkoutDetails.exercises]): la sessione non rilegge la scheda dal
/// repository mentre è in corso.
///
/// Tutte le voci indicizzate per esercizio ([completedWorkoutExerciseIds],
/// [skippedWorkoutExerciseIds], [completedSetsByWorkoutExerciseId]) usano
/// **[WorkoutExercise.id]**, mai `exerciseId`: lo stesso esercizio del
/// catalogo può comparire più volte nella stessa scheda con righe
/// distinte, e le loro serie sono indipendenti.
class WorkoutSessionState {
  const WorkoutSessionState({
    required this.sessionId,
    required this.workoutId,
    required this.workoutName,
    required this.exercises,
    required this.startedAt,
    this.currentExerciseIndex = 0,
    this.isPaused = false,
    this.isCompleted = false,
    this.completedWorkoutExerciseIds = const {},
    this.skippedWorkoutExerciseIds = const {},
    this.completedSetsByWorkoutExerciseId = const {},
    this.exerciseTimer,
    this.restTimer,
  });

  /// Id di `sessioni_allenamento` (Milestone 4.4.3): permette al
  /// controller di persistere il progresso sulla riga giusta. Assegnato da
  /// `WorkoutSessionRepository.createSession` prima che questo stato venga
  /// mai creato — non è mai null a runtime (a differenza di
  /// `Workout.id`/`WorkoutExercise.id`, nulli solo prima del primo salvataggio).
  final int sessionId;
  final int workoutId;
  final String workoutName;
  final List<WorkoutExerciseDetails> exercises;
  final DateTime startedAt;
  final int currentExerciseIndex;
  final bool isPaused;
  final bool isCompleted;
  final Set<int> completedWorkoutExerciseIds;
  final Set<int> skippedWorkoutExerciseIds;

  /// Serie già completate per ogni riga scheda (conteggio, non indici):
  /// assente/0 significa "nessuna serie fatta ancora". Conservato anche
  /// quando ci si allontana dall'esercizio (es. con "Indietro") — vedi
  /// sezione 26/27 della milestone.
  final Map<int, int> completedSetsByWorkoutExerciseId;

  /// Countdown della serie a tempo dell'esercizio corrente, se in corso.
  final SessionTimer? exerciseTimer;

  /// Countdown del recupero tra due serie dell'esercizio corrente, se in
  /// corso.
  final SessionTimer? restTimer;

  int get totalExercises => exercises.length;

  WorkoutExerciseDetails get currentExercise => exercises[currentExerciseIndex];

  int get currentWorkoutExerciseId => currentExercise.workoutExercise.id!;

  bool get isLastExercise => currentExerciseIndex == exercises.length - 1;

  int get currentTotalSets => totalSetsFor(currentExercise.workoutExercise);

  /// Serie già completate dell'esercizio corrente (0-based: coincide con
  /// l'indice della prossima serie da fare).
  int get currentCompletedSets =>
      completedSetsByWorkoutExerciseId[currentWorkoutExerciseId] ?? 0;

  bool get currentExerciseIsTimed =>
      isTimedExercise(currentExercise.workoutExercise);

  /// Fase corrente, derivata dal resto dello stato — non un flag
  /// indipendente, nessuno stato duplicato.
  WorkoutSessionPhase get phase {
    if (isCompleted) return WorkoutSessionPhase.completed;
    if (isPaused) return WorkoutSessionPhase.paused;
    if (restTimer != null) return WorkoutSessionPhase.resting;
    if (exerciseTimer != null) return WorkoutSessionPhase.timedSetRunning;
    return WorkoutSessionPhase.readySet;
  }

  WorkoutSessionState copyWith({
    int? currentExerciseIndex,
    bool? isPaused,
    bool? isCompleted,
    Set<int>? completedWorkoutExerciseIds,
    Set<int>? skippedWorkoutExerciseIds,
    Map<int, int>? completedSetsByWorkoutExerciseId,
    SessionTimer? Function()? exerciseTimer,
    SessionTimer? Function()? restTimer,
  }) {
    return WorkoutSessionState(
      sessionId: sessionId,
      workoutId: workoutId,
      workoutName: workoutName,
      exercises: exercises,
      startedAt: startedAt,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      completedWorkoutExerciseIds:
          completedWorkoutExerciseIds ?? this.completedWorkoutExerciseIds,
      skippedWorkoutExerciseIds:
          skippedWorkoutExerciseIds ?? this.skippedWorkoutExerciseIds,
      completedSetsByWorkoutExerciseId:
          completedSetsByWorkoutExerciseId ??
          this.completedSetsByWorkoutExerciseId,
      exerciseTimer: exerciseTimer != null
          ? exerciseTimer()
          : this.exerciseTimer,
      restTimer: restTimer != null ? restTimer() : this.restTimer,
    );
  }
}
