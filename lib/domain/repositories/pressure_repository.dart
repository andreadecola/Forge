import '../entities/pressure_measurement.dart';

abstract class PressureRepository {
  Future<int> addMeasurement(PressureMeasurement measurement);

  Future<void> deleteMeasurement(int id);

  Future<List<PressureMeasurement>> getMeasurementsByProfile(int profileId);

  Stream<List<PressureMeasurement>> watchMeasurementsByProfile(int profileId);

  Future<PressureMeasurement?> getLatestPressure(int profileId);
}
