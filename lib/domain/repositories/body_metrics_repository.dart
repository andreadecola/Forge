import '../entities/body_measurement.dart';

abstract class BodyMetricsRepository {
  Future<int> addMeasurement(BodyMeasurement measurement);

  Future<void> updateMeasurement(BodyMeasurement measurement);

  Future<void> deleteMeasurement(int id);

  Future<List<BodyMeasurement>> getMeasurementsByProfile(int profileId);

  Stream<List<BodyMeasurement>> watchMeasurementsByProfile(int profileId);

  Future<BodyMeasurement?> getLatestWeight(int profileId);
}
