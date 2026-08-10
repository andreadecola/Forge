import 'workout_session_exercise_history_item.dart';
import 'workout_session_history_item.dart';

/// Aggregato completo di una sessione storica con gli esercizi risolti, in
/// ordine. Restituito da `getSessionHistoryDetails`.
class WorkoutSessionHistoryDetails {
  const WorkoutSessionHistoryDetails({
    required this.session,
    required this.exercises,
  });

  final WorkoutSessionHistoryItem session;

  /// Ordinati per `ordine` ascendente.
  final List<WorkoutSessionExerciseHistoryItem> exercises;
}
