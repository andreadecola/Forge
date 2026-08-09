import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_equipment_table.dart';

part 'user_equipment_dao.g.dart';

@DriftAccessor(tables: [UserEquipmentTable])
class UserEquipmentDao extends DatabaseAccessor<AppDatabase>
    with _$UserEquipmentDaoMixin {
  UserEquipmentDao(super.db);

  Future<int> insertEquipment(UserEquipmentTableCompanion equipment) =>
      into(userEquipmentTable).insert(equipment);

  Future<UserEquipmentTableData?> _getRow(int profileId, String equipmentCode) {
    return (select(userEquipmentTable)..where(
          (t) =>
              t.profileId.equals(profileId) &
              t.equipmentCode.equals(equipmentCode),
        ))
        .getSingleOrNull();
  }

  /// Aggiorna lo stato di possesso se la riga esiste già, altrimenti la crea.
  Future<void> setOwned(int profileId, String equipmentCode, bool owned) async {
    final existing = await _getRow(profileId, equipmentCode);
    if (existing == null) {
      await into(userEquipmentTable).insert(
        UserEquipmentTableCompanion.insert(
          profileId: profileId,
          equipmentCode: equipmentCode,
          owned: Value(owned),
        ),
      );
    } else {
      await (update(userEquipmentTable)..where((t) => t.id.equals(existing.id)))
          .write(UserEquipmentTableCompanion(owned: Value(owned)));
    }
  }

  Future<List<UserEquipmentTableData>> getEquipmentByProfile(int profileId) =>
      (select(
        userEquipmentTable,
      )..where((t) => t.profileId.equals(profileId))).get();

  Stream<List<UserEquipmentTableData>> watchEquipmentByProfile(int profileId) {
    return (select(
      userEquipmentTable,
    )..where((t) => t.profileId.equals(profileId))).watch();
  }

  Future<List<UserEquipmentTableData>> getOwnedEquipment(int profileId) {
    return (select(userEquipmentTable)
          ..where((t) => t.profileId.equals(profileId) & t.owned.equals(true)))
        .get();
  }
}
