import 'exercise.dart';
import 'exercise_catalog_enums.dart';

class ExerciseAlternative {
  const ExerciseAlternative({
    required this.id,
    required this.reason,
    required this.priority,
    this.notes,
    required this.target,
  });

  final int id;
  final ExerciseAlternativeReason reason;
  final int priority;
  final String? notes;

  /// Esercizio alternativo proposto.
  final Exercise target;
}
