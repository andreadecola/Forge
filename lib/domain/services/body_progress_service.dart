import '../entities/body_measurement.dart';
import '../entities/body_progress_summary.dart';
import '../entities/user_profile.dart';

/// Calcola [BodyProgressSummary] da profilo e storico misurazioni
/// (Milestone 7.2). Puro: nessun accesso a DB/clock, testabile con liste in
/// memoria.
abstract final class BodyProgressService {
  /// Non assume che [measurements] arrivi già ordinato dal chiamante: sceglie
  /// esplicitamente la riga più recente per peso e per girovita, a parità di
  /// `measuredAt` privilegia l'id più alto (inserito per ultimo).
  static BodyProgressSummary summarize({
    required UserProfile profile,
    required List<BodyMeasurement> measurements,
  }) {
    final latestWeight = _latestWithMetric(measurements, (m) => m.weightKg);
    final latestWaist = _latestWithMetric(measurements, (m) => m.waistCm);

    final latestWeightKg = latestWeight?.weightKg;

    return BodyProgressSummary(
      initialWeightKg: profile.initialWeightKg,
      latestWeightKg: latestWeightKg,
      latestWeightMeasuredAt: latestWeight?.measuredAt,
      weightDeltaKg: latestWeightKg == null
          ? null
          : latestWeightKg - profile.initialWeightKg,
      latestWaistCm: latestWaist?.waistCm,
      latestWaistMeasuredAt: latestWaist?.measuredAt,
    );
  }

  static BodyMeasurement? _latestWithMetric(
    List<BodyMeasurement> measurements,
    double? Function(BodyMeasurement) metric,
  ) {
    BodyMeasurement? latest;
    for (final m in measurements) {
      if (metric(m) == null) continue;
      if (latest == null || _isMoreRecent(m, latest)) {
        latest = m;
      }
    }
    return latest;
  }

  static bool _isMoreRecent(BodyMeasurement candidate, BodyMeasurement than) {
    final byDate = candidate.measuredAt.compareTo(than.measuredAt);
    if (byDate != 0) return byDate > 0;
    return (candidate.id ?? 0) > (than.id ?? 0);
  }
}
