/// Fotografia derivata (non persistita) dello stato di peso/girovita di un
/// profilo, calcolata da [BodyProgressService] a partire dal profilo e dallo
/// storico misurazioni già esistenti (Milestone 7.2).
class BodyProgressSummary {
  const BodyProgressSummary({
    required this.initialWeightKg,
    this.latestWeightKg,
    this.latestWeightMeasuredAt,
    this.weightDeltaKg,
    this.latestWaistCm,
    this.latestWaistMeasuredAt,
  });

  /// Baseline immutabile del profilo (Milestone 2), indipendente dallo
  /// storico misurazioni: non cambia se una misurazione viene modificata o
  /// eliminata.
  final double initialWeightKg;

  /// `null` se non è mai stata registrata una misurazione con un peso.
  final double? latestWeightKg;
  final DateTime? latestWeightMeasuredAt;

  /// `latestWeightKg - initialWeightKg`; `null` se [latestWeightKg] è `null`.
  final double? weightDeltaKg;

  /// `null` se non è mai stata registrata una misurazione con un girovita.
  final double? latestWaistCm;
  final DateTime? latestWaistMeasuredAt;
}
