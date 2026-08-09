import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pressure_measurements_table.dart';

part 'pressure_measurements_dao.g.dart';

@DriftAccessor(tables: [PressureMeasurementsTable])
class PressureMeasurementsDao extends DatabaseAccessor<AppDatabase>
    with _$PressureMeasurementsDaoMixin {
  PressureMeasurementsDao(super.db);

  Future<int> insertMeasurement(
    PressureMeasurementsTableCompanion measurement,
  ) => into(pressureMeasurementsTable).insert(measurement);

  Future<bool> updateMeasurement(
    PressureMeasurementsTableCompanion measurement,
  ) => update(pressureMeasurementsTable).replace(measurement);

  Future<int> deleteMeasurement(int id) =>
      (delete(pressureMeasurementsTable)..where((t) => t.id.equals(id))).go();

  Future<PressureMeasurementsTableData?> getById(int id) => (select(
    pressureMeasurementsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<PressureMeasurementsTableData>> getMeasurementsByProfile(
    int profileId,
  ) {
    return (select(pressureMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]))
        .get();
  }

  Stream<List<PressureMeasurementsTableData>> watchMeasurementsByProfile(
    int profileId,
  ) {
    return (select(pressureMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]))
        .watch();
  }

  Future<PressureMeasurementsTableData?> getLatestPressure(int profileId) {
    return (select(pressureMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(1))
        .getSingleOrNull();
  }
}
