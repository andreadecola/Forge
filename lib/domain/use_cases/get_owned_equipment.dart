import '../entities/equipment_item.dart';
import '../repositories/equipment_repository.dart';

class GetOwnedEquipment {
  GetOwnedEquipment(this._repository);

  final EquipmentRepository _repository;

  Future<List<UserEquipmentState>> call(int profileId) =>
      _repository.getOwnedEquipment(profileId);
}
