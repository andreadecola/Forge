import '../entities/equipment_item.dart';

abstract class EquipmentRepository {
  /// Stato di ogni attrezzo del catalogo per il profilo (owned=false se
  /// non ancora presente in DB).
  Future<List<UserEquipmentState>> getAllEquipmentStates(int profileId);

  Stream<List<UserEquipmentState>> watchAllEquipmentStates(int profileId);

  Future<List<UserEquipmentState>> getOwnedEquipment(int profileId);

  Future<void> updateEquipment({
    required int profileId,
    required EquipmentItem item,
    required bool owned,
  });

  /// Usato in onboarding per salvare lo stato iniziale in un'unica operazione.
  Future<void> saveInitialEquipment({
    required int profileId,
    required Set<EquipmentItem> owned,
  });
}
