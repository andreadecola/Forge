import '../entities/pressure_measurement.dart';

/// Determina la misurazione pressione più recente da uno storico
/// (Milestone 7.3). Puro: nessun accesso a DB/clock, testabile con liste in
/// memoria. Un solo valore da riassumere (a differenza di
/// `BodyProgressService`, che segue peso e girovita separatamente): non
/// serve un modello wrapper dedicato, `PressureMeasurement?` è già la
/// risposta completa.
abstract final class PressureProgressService {
  /// Non assume che [measurements] arrivi già ordinato dal chiamante: a
  /// parità di `measuredAt` privilegia l'id più alto (inserito per ultimo).
  static PressureMeasurement? latest(List<PressureMeasurement> measurements) {
    PressureMeasurement? latest;
    for (final m in measurements) {
      if (latest == null || _isMoreRecent(m, latest)) {
        latest = m;
      }
    }
    return latest;
  }

  static bool _isMoreRecent(
    PressureMeasurement candidate,
    PressureMeasurement than,
  ) {
    final byDate = candidate.measuredAt.compareTo(than.measuredAt);
    if (byDate != 0) return byDate > 0;
    return (candidate.id ?? 0) > (than.id ?? 0);
  }
}
