import '../../domain/entities/equipment_item.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../database/app_database.dart';
import '../database/daos/user_equipment_dao.dart';

class EquipmentRepositoryImpl implements EquipmentRepository {
  EquipmentRepositoryImpl(this._dao);

  final UserEquipmentDao _dao;

  @override
  Future<List<UserEquipmentState>> getAllEquipmentStates(int profileId) async {
    final rows = await _dao.getEquipmentByProfile(profileId);
    return _mergeWithCatalog(profileId, rows);
  }

  @override
  Stream<List<UserEquipmentState>> watchAllEquipmentStates(int profileId) {
    return _dao
        .watchEquipmentByProfile(profileId)
        .map((rows) => _mergeWithCatalog(profileId, rows));
  }

  @override
  Future<List<UserEquipmentState>> getOwnedEquipment(int profileId) async {
    final states = await getAllEquipmentStates(profileId);
    return states.where((s) => s.owned).toList();
  }

  @override
  Future<void> updateEquipment({
    required int profileId,
    required EquipmentItem item,
    required bool owned,
  }) {
    return _dao.setOwned(profileId, item.code, owned);
  }

  @override
  Future<void> saveInitialEquipment({
    required int profileId,
    required Set<EquipmentItem> owned,
  }) async {
    for (final item in EquipmentItem.values) {
      await _dao.setOwned(profileId, item.code, owned.contains(item));
    }
  }

  List<UserEquipmentState> _mergeWithCatalog(
    int profileId,
    List<UserEquipmentTableData> rows,
  ) {
    final byCode = {for (final row in rows) row.equipmentCode: row};
    return EquipmentItem.values.map((item) {
      final row = byCode[item.code];
      return UserEquipmentState(
        id: row?.id,
        profileId: profileId,
        item: item,
        owned: row?.owned ?? false,
        acquiredAt: row?.acquiredAt,
        notes: row?.notes,
      );
    }).toList();
  }
}
