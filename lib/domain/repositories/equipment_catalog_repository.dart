import '../entities/equipment.dart';

abstract class EquipmentCatalogRepository {
  Future<List<Equipment>> getAllEquipment();

  Future<Equipment?> getEquipmentByCode(String code);

  Future<List<Equipment>> getRequiredEquipmentForExercise(int exerciseId);
}
