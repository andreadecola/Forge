import 'equipment.dart';
import 'exercise.dart';
import 'exercise_alternative.dart';
import 'exercise_category.dart';
import 'exercise_image.dart';
import 'exercise_progression.dart';
import 'muscle_group.dart';

/// Aggregato completo di un esercizio con tutte le relazioni risolte.
/// Restituito da `getExerciseDetails`.
class ExerciseDetails {
  const ExerciseDetails({
    required this.exercise,
    required this.category,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.images,
    required this.progressions,
    required this.regressions,
    required this.alternatives,
  });

  final Exercise exercise;
  final ExerciseCategory category;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final List<ExerciseEquipmentRequirement> equipment;
  final List<ExerciseImage> images;
  final List<ExerciseProgression> progressions;
  final List<ExerciseProgression> regressions;
  final List<ExerciseAlternative> alternatives;
}
