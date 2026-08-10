import '../entities/exercise.dart';
import '../entities/exercise_alternative.dart';
import '../entities/exercise_details.dart';
import '../entities/exercise_progression.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises();

  Stream<List<Exercise>> watchExercises();

  Future<Exercise?> getExerciseById(int id);

  Future<Exercise?> getExerciseByCode(String code);

  Future<List<Exercise>> getExercisesByCategory(String categoryCode);

  Future<List<Exercise>> getExercisesByLevel(int userLevel);

  Future<List<Exercise>> searchExercises(String query);

  /// Esercizi le cui attrezzature obbligatorie sono tutte possedute
  /// (`NONE` escluso). [ownedEquipmentCodes] sono codici master.
  Future<List<Exercise>> getExercisesByAvailableEquipment(
    Set<String> ownedEquipmentCodes,
  );

  Future<ExerciseDetails?> getExerciseDetails(int exerciseId);

  Future<List<ExerciseProgression>> getProgressions(int exerciseId);

  Future<List<ExerciseProgression>> getRegressions(int exerciseId);

  Future<List<ExerciseAlternative>> getAlternatives(int exerciseId);
}
