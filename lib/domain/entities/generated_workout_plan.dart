import 'forge_composition_reason.dart';
import 'forge_generation_warning.dart';
import 'forge_request.dart';
import 'generated_workout_exercise.dart';
import 'workout_enums.dart';

/// Piano generato dal Forge Engine (Milestone 5.2, sezione 4). **Non è un
/// `Workout` persistito**: nessuna riga scritta nel database, nessun
/// `Workout.id` — solo un'anteprima spiegabile. Il salvataggio, se
/// deciso, arriverà con una milestone successiva.
class GeneratedWorkoutPlan {
  const GeneratedWorkoutPlan({
    required this.request,
    required this.workoutType,
    required this.targetDurationMinutes,
    required this.estimatedDurationSeconds,
    required this.exercises,
    required this.warnings,
    required this.decisionReasons,
    required this.isComplete,
  });

  /// La [ForgeRequest] già normalizzata (Milestone 5.1) usata per questo
  /// piano.
  final ForgeRequest request;

  final WorkoutType workoutType;
  final int targetDurationMinutes;

  /// Somma delle stime dei singoli esercizi **più** le transizioni tra di
  /// essi (`(N-1) * transitionSecondsBetweenExercises`), ricalcolata sul
  /// piano finale già ordinato (sezione 41/42) — non deve dipendere
  /// dall'ordine, ma viene comunque calcolata a valle per sicurezza.
  final int estimatedDurationSeconds;

  int get estimatedDurationMinutes => (estimatedDurationSeconds / 60).round();

  /// In ordine di esecuzione (`ForgeExerciseOrderingPolicy`), mai in
  /// ordine di punteggio grezzo.
  final List<GeneratedWorkoutExercise> exercises;

  final List<ForgeGenerationWarning> warnings;

  final List<ForgeCompositionReason> decisionReasons;

  /// `true` se copertura obbligatoria soddisfatta, almeno
  /// `minimumExercises` esercizi presenti e durata entro
  /// `planDurationTolerance` (sezione 43) — vedi
  /// `ForgeWorkoutComposer._isComplete` per la regola esatta.
  final bool isComplete;
}
