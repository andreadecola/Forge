import 'package:drift/drift.dart';

import '../../domain/entities/pressure_measurement.dart';
import '../../domain/repositories/pressure_repository.dart';
import '../database/app_database.dart';
import '../database/daos/pressure_measurements_dao.dart';

class PressureRepositoryImpl implements PressureRepository {
  PressureRepositoryImpl(this._dao);

  final PressureMeasurementsDao _dao;

  @override
  Future<int> addMeasurement(PressureMeasurement measurement) {
    return _dao.insertMeasurement(
      PressureMeasurementsTableCompanion.insert(
        profileId: measurement.profileId,
        measuredAt: measurement.measuredAt,
        systolic: measurement.systolic,
        diastolic: measurement.diastolic,
        heartRate: Value(measurement.heartRate),
        measurementContext: Value(measurement.measurementContext),
        notes: Value(measurement.notes),
      ),
    );
  }

  @override
  Future<void> deleteMeasurement(int id) => _dao.deleteMeasurement(id);

  @override
  Future<List<PressureMeasurement>> getMeasurementsByProfile(
    int profileId,
  ) async {
    final rows = await _dao.getMeasurementsByProfile(profileId);
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<PressureMeasurement>> watchMeasurementsByProfile(int profileId) {
    return _dao
        .watchMeasurementsByProfile(profileId)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<PressureMeasurement?> getLatestPressure(int profileId) async {
    final row = await _dao.getLatestPressure(profileId);
    return row == null ? null : _toEntity(row);
  }

  PressureMeasurement _toEntity(PressureMeasurementsTableData row) {
    return PressureMeasurement(
      id: row.id,
      profileId: row.profileId,
      measuredAt: row.measuredAt,
      systolic: row.systolic,
      diastolic: row.diastolic,
      heartRate: row.heartRate,
      measurementContext: row.measurementContext,
      notes: row.notes,
    );
  }
}
