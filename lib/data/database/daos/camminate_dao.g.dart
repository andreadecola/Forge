// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camminate_dao.dart';

// ignore_for_file: type=lint
mixin _$CamminateDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $CamminateTableTable get camminateTable => attachedDatabase.camminateTable;
  CamminateDaoManager get managers => CamminateDaoManager(this);
}

class CamminateDaoManager {
  final _$CamminateDaoMixin _db;
  CamminateDaoManager(this._db);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(
        _db.attachedDatabase,
        _db.userProfilesTable,
      );
  $$CamminateTableTableTableManager get camminateTable =>
      $$CamminateTableTableTableManager(
        _db.attachedDatabase,
        _db.camminateTable,
      );
}
