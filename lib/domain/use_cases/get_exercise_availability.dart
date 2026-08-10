import '../entities/exercise.dart';
import '../entities/exercise_availability_status.dart';
import '../repositories/equipment_catalog_repository.dart';
import '../services/exercise_availability_service.dart';

class GetExerciseAvailability {
  GetExerciseAvailability(this._equipmentRepository, this._service);

  final EquipmentCatalogRepository _equipmentRepository;
  final ExerciseAvailabilityService _service;

  Future<ExerciseAvailabilityStatus> call({
    required Exercise exercise,
    required int userLevel,
    required Set<String> ownedEquipmentCodes,
  }) async {
    final required = await _equipmentRepository.getRequiredEquipmentForExercise(
      exercise.id,
    );
    return _service.evaluate(
      exercise: exercise,
      userLevel: userLevel,
      ownedEquipmentCodes: ownedEquipmentCodes,
      requiredEquipmentCodes: required.map((e) => e.code),
    );
  }
}
