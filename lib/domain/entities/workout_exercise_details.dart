import 'exercise.dart';
import 'workout_exercise.dart';

/// Riga di scheda con l'esercizio del catalogo già risolto.
class WorkoutExerciseDetails {
  const WorkoutExerciseDetails({
    required this.workoutExercise,
    required this.exercise,
  });

  final WorkoutExercise workoutExercise;
  final Exercise exercise;
}
