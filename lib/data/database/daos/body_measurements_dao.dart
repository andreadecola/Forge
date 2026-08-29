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

  /// Ordinate per `measuredAt` decrescente, con tie-break su `id`
  /// decrescente a parità di timestamp (Milestone 7.7): stesso principio già
  /// applicato a `PressureMeasurementsDao` e alle query "latest" qui sotto —
  /// determinismo anche con più misurazioni nello stesso istante, senza
  /// assumere l'ordine fisico delle righe su disco.
  Future<List<BodyMeasurementsTableData>> getMeasurementsByProfile(
    int profileId,
  ) {
    return (select(bodyMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.measuredAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Stream<List<BodyMeasurementsTableData>> watchMeasurementsByProfile(
    int profileId,
  ) {
    return (select(bodyMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.measuredAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  /// Solo righe con peso presente (Milestone 7.2: da quando `weightKg` può
  /// essere `null` per una misurazione "solo girovita", la più recente in
  /// assoluto non è necessariamente la più recente con un peso).
  Future<BodyMeasurementsTableData?> getLatestWeight(int profileId) {
    return (select(bodyMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId) & t.weightKg.isNotNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.measuredAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Speculare a [getLatestWeight] per il girovita (Milestone 7.2).
  Future<BodyMeasurementsTableData?> getLatestWaist(int profileId) {
    return (select(bodyMeasurementsTable)
          ..where((t) => t.profileId.equals(profileId) & t.waistCm.isNotNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.measuredAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(1))
        .getSingleOrNull();
  }
}
