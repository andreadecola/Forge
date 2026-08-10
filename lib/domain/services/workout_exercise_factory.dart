import '../entities/exercise.dart';
import '../entities/workout_exercise.dart';

/// Costruisce una [WorkoutExercise] non persistita a partire dai default
/// del catalogo per un [Exercise]. Non inventa valori: se un default del
/// catalogo è `null` (es. `defaultDurationSeconds`), resta `null` — la
/// validazione READY (`WorkoutValidationService`) deciderà poi se
/// l'esercizio è eseguibile così com'è.
class WorkoutExerciseFactory {
  const WorkoutExerciseFactory();

  /// [order] e [workoutId] sono responsabilità del chiamante (tipicamente
  /// il repository, che conosce la scheda e la posizione in coda).
  WorkoutExercise fromExercise({
    required Exercise exercise,
    required int workoutId,
    required int order,
  }) {
    return WorkoutExercise(
      workoutId: workoutId,
      exerciseId: exercise.id,
      order: order,
      sets: exercise.defaultSets,
      repetitions: exercise.defaultReps,
      durationSeconds: exercise.defaultDurationSeconds,
      restSeconds: exercise.defaultRestSeconds,
    );
  }
}
