import '../entities/body_measurement.dart';

abstract class BodyMetricsRepository {
  Future<int> addMeasurement(BodyMeasurement measurement);

  Future<void> updateMeasurement(BodyMeasurement measurement);

  Future<void> deleteMeasurement(int id);

  /// Singola misurazione per id (Milestone 7.1, sezione 17), `null` se non
  /// esiste (es. già eliminata).
  Future<BodyMeasurement?> getById(int id);

  Future<List<BodyMeasurement>> getMeasurementsByProfile(int profileId);

  Stream<List<BodyMeasurement>> watchMeasurementsByProfile(int profileId);

  Future<BodyMeasurement?> getLatestWeight(int profileId);

  /// Speculare a [getLatestWeight] per il girovita (Milestone 7.2).
  Future<BodyMeasurement?> getLatestWaist(int profileId);
}
