import 'package:drift/drift.dart';

import '../../domain/entities/body_measurement.dart';
import '../../domain/repositories/body_metrics_repository.dart';
import '../database/app_database.dart';
import '../database/daos/body_measurements_dao.dart';

class BodyMetricsRepositoryImpl implements BodyMetricsRepository {
  BodyMetricsRepositoryImpl(this._dao);

  final BodyMeasurementsDao _dao;

  @override
  Future<int> addMeasurement(BodyMeasurement measurement) {
    return _dao.insertMeasurement(_toCompanion(measurement));
  }

  @override
  Future<void> updateMeasurement(BodyMeasurement measurement) {
    return _dao.updateMeasurement(_toCompanion(measurement, includeId: true));
  }

  @override
  Future<void> deleteMeasurement(int id) => _dao.deleteMeasurement(id);

  @override
  Future<BodyMeasurement?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<List<BodyMeasurement>> getMeasurementsByProfile(int profileId) async {
    final rows = await _dao.getMeasurementsByProfile(profileId);
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<BodyMeasurement>> watchMeasurementsByProfile(int profileId) {
    return _dao
        .watchMeasurementsByProfile(profileId)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<BodyMeasurement?> getLatestWeight(int profileId) async {
    final row = await _dao.getLatestWeight(profileId);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<BodyMeasurement?> getLatestWaist(int profileId) async {
    final row = await _dao.getLatestWaist(profileId);
    return row == null ? null : _toEntity(row);
  }

  BodyMeasurementsTableCompanion _toCompanion(
    BodyMeasurement m, {
    bool includeId = false,
  }) {
    return BodyMeasurementsTableCompanion(
      id: includeId ? Value(m.id!) : const Value.absent(),
      profileId: Value(m.profileId),
      measuredAt: Value(m.measuredAt),
      weightKg: Value(m.weightKg),
      neckCm: Value(m.neckCm),
      chestCm: Value(m.chestCm),
      waistCm: Value(m.waistCm),
      abdomenCm: Value(m.abdomenCm),
      hipsCm: Value(m.hipsCm),
      leftArmCm: Value(m.leftArmCm),
      rightArmCm: Value(m.rightArmCm),
      leftThighCm: Value(m.leftThighCm),
      rightThighCm: Value(m.rightThighCm),
      leftCalfCm: Value(m.leftCalfCm),
      rightCalfCm: Value(m.rightCalfCm),
      notes: Value(m.notes),
    );
  }

  BodyMeasurement _toEntity(BodyMeasurementsTableData row) {
    return BodyMeasurement(
      id: row.id,
      profileId: row.profileId,
      measuredAt: row.measuredAt,
      weightKg: row.weightKg,
      neckCm: row.neckCm,
      chestCm: row.chestCm,
      waistCm: row.waistCm,
      abdomenCm: row.abdomenCm,
      hipsCm: row.hipsCm,
      leftArmCm: row.leftArmCm,
      rightArmCm: row.rightArmCm,
      leftThighCm: row.leftThighCm,
      rightThighCm: row.rightThighCm,
      leftCalfCm: row.leftCalfCm,
      rightCalfCm: row.rightCalfCm,
      notes: row.notes,
    );
  }
}
