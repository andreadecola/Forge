// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurements_dao.dart';

// ignore_for_file: type=lint
mixin _$BodyMeasurementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $BodyMeasurementsTableTable get bodyMeasurementsTable =>
      attachedDatabase.bodyMeasurementsTable;
  BodyMeasurementsDaoManager get managers => BodyMeasurementsDaoManager(this);
}

class BodyMeasurementsDaoManager {
  final _$BodyMeasurementsDaoMixin _db;
  BodyMeasurementsDaoManager(this._db);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(
        _db.attachedDatabase,
        _db.userProfilesTable,
      );
  $$BodyMeasurementsTableTableTableManager get bodyMeasurementsTable =>
      $$BodyMeasurementsTableTableTableManager(
        _db.attachedDatabase,
        _db.bodyMeasurementsTable,
      );
}
