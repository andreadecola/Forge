import '../entities/pressure_measurement.dart';

abstract class PressureRepository {
  Future<int> addMeasurement(PressureMeasurement measurement);

  /// Aggiunto in Milestone 7.1 (sezione 17): il DAO lo supportava già, non
  /// era solo esposto a questo livello — nessuna correzione/modifica di una
  /// misurazione pressione era ancora possibile prima di questa milestone.
  Future<void> updateMeasurement(PressureMeasurement measurement);

  Future<void> deleteMeasurement(int id);

  /// Singola misurazione per id (Milestone 7.1, sezione 17), `null` se non
  /// esiste.
  Future<PressureMeasurement?> getById(int id);

  Future<List<PressureMeasurement>> getMeasurementsByProfile(int profileId);

  Stream<List<PressureMeasurement>> watchMeasurementsByProfile(int profileId);

  Future<PressureMeasurement?> getLatestPressure(int profileId);
}
