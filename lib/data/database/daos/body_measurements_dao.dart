import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/body_measurements_table.dart';

part 'body_measurements_dao.g.dart';

@DriftAccessor(tables: [BodyMeasurementsTable])
class BodyMeasurementsDao extends DatabaseAccessor<AppDatabase>
    with _$BodyMeasurementsDaoMixin {
  BodyMeasurementsDao(super.db);

  Future<int> insertMeasurement(BodyMeasurementsTableCompanion measurement) =>
      into(bodyMeasurementsTable).insert(measurement);

  Future<bool> updateMeasurement(BodyMeasurementsTableCompanion measurement) =>
      update(bodyMeasurementsTable).replace(measurement);

  Future<int> deleteMeasurement(int id) =>
      (delete(bodyMeasurementsTable)..where((t) => t.id.equals(id))).go();

  Future<BodyMeasurementsTableData?> getById(int id) => (select(
    bodyMeasurementsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<BodyMeasurementsTableData>> getMeasurementsByProfile(
    int profileId,
  ) {
    return (select(bodyMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]))
        .get();
  }

  Stream<List<BodyMeasurementsTableData>> watchMeasurementsByProfile(
    int profileId,
  ) {
    return (select(bodyMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]))
        .watch();
  }

  Future<BodyMeasurementsTableData?> getLatestWeight(int profileId) {
    return (select(bodyMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(1))
        .getSingleOrNull();
  }
}
