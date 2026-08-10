import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class GetExercisesByAvailableEquipment {
  GetExercisesByAvailableEquipment(this._repository);

  final ExerciseRepository _repository;

  /// [ownedEquipmentCodes] sono codici master (già risolti dal mapping M2).
  Future<List<Exercise>> call(Set<String> ownedEquipmentCodes) =>
      _repository.getExercisesByAvailableEquipment(ownedEquipmentCodes);
}
