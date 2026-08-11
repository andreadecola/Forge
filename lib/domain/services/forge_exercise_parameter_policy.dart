import '../entities/exercise.dart';
import '../entities/generated_workout_exercise.dart';
import '../entities/workout_exercise.dart';
import 'workout_exercise_factory.dart';

/// Parametri (`sets`/`repetitions`/`durationSeconds`/`restSeconds`) per un
/// esercizio selezionato dal Forge Engine (Milestone 5.2, sezione 33).
///
/// Riusa [WorkoutExerciseFactory] senza modifiche: **nessun adattamento al
/// livello utente in questa milestone** — è la stessa scelta già presa in
/// Milestone 5.1 per la stima durata (M5.4 introdurrà l'adattamento).
class ForgeExerciseParameterPolicy {
  const ForgeExerciseParameterPolicy({
    this.factory = const WorkoutExerciseFactory(),
  });

  final WorkoutExerciseFactory factory;

  /// [order] è responsabilità del chiamante (`ForgeWorkoutComposer`, dopo
  /// l'ordinamento finale) — mai calcolato qui.
  WorkoutExercise parametersFor({
    required Exercise exercise,
    required int order,
  }) {
    return factory.fromExercise(
      exercise: exercise,
      workoutId: GeneratedWorkoutExercise.placeholderWorkoutId,
      order: order,
    );
  }
}
