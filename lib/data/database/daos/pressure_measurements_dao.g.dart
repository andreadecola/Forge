// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pressure_measurements_dao.dart';

// ignore_for_file: type=lint
mixin _$PressureMeasurementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $PressureMeasurementsTableTable get pressureMeasurementsTable =>
      attachedDatabase.pressureMeasurementsTable;
  PressureMeasurementsDaoManager get managers =>
      PressureMeasurementsDaoManager(this);
}

class PressureMeasurementsDaoManager {
  final _$PressureMeasurementsDaoMixin _db;
  PressureMeasurementsDaoManager(this._db);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(
        _db.attachedDatabase,
        _db.userProfilesTable,
      );
  $$PressureMeasurementsTableTableTableManager get pressureMeasurementsTable =>
      $$PressureMeasurementsTableTableTableManager(
        _db.attachedDatabase,
        _db.pressureMeasurementsTable,
      );
}
