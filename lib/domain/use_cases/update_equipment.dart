import '../entities/equipment_item.dart';
import '../repositories/equipment_repository.dart';

class UpdateEquipment {
  UpdateEquipment(this._repository);

  final EquipmentRepository _repository;

  Future<void> call({
    required int profileId,
    required EquipmentItem item,
    required bool owned,
  }) {
    return _repository.updateEquipment(
      profileId: profileId,
      item: item,
      owned: owned,
    );
  }
}
