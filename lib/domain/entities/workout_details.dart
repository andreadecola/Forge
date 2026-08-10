import 'workout.dart';
import 'workout_exercise_details.dart';

/// Aggregato completo di un allenamento con gli esercizi risolti, in
/// ordine. Restituito da `getWorkoutDetails`.
class WorkoutDetails {
  const WorkoutDetails({required this.workout, required this.exercises});

  final Workout workout;

  /// Ordinati per `order` ascendente.
  final List<WorkoutExerciseDetails> exercises;
}
