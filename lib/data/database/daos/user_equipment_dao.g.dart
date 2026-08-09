// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_equipment_dao.dart';

// ignore_for_file: type=lint
mixin _$UserEquipmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $UserEquipmentTableTable get userEquipmentTable =>
      attachedDatabase.userEquipmentTable;
  UserEquipmentDaoManager get managers => UserEquipmentDaoManager(this);
}

class UserEquipmentDaoManager {
  final _$UserEquipmentDaoMixin _db;
  UserEquipmentDaoManager(this._db);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(
        _db.attachedDatabase,
        _db.userProfilesTable,
      );
  $$UserEquipmentTableTableTableManager get userEquipmentTable =>
      $$UserEquipmentTableTableTableManager(
        _db.attachedDatabase,
        _db.userEquipmentTable,
      );
}
