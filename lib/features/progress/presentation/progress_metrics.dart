// Pure formatting helpers for manually entered weight/waist (Milestone 7.2)
// and blood pressure (Milestone 7.3). The shared decimal parser lives in the
// core utilities so profile editing can reuse the exact same semantics.
export '../../../core/utils/decimal_parser.dart';

/// "145 kg" per un valore intero, "145,2 kg" altrimenti — mai più di una
/// cifra decimale, virgola come separatore.
String formatWeightKg(double weightKg) => '${_formatOneDecimal(weightKg)} kg';

/// Speculare a [formatWeightKg] per il girovita.
String formatWaistCm(double waistCm) => '${_formatOneDecimal(waistCm)} cm';

/// Variazione di peso rispetto alla baseline, con segno esplicito (eccetto
/// zero esatto): "+2,5 kg", "−1,5 kg", "0 kg". Nessun giudizio di valore:
/// solo il numero con il segno, mai testo come "ottimo" o "peggiorato".
String formatWeightDeltaKg(double deltaKg) {
  if (deltaKg == 0) return '0 kg';
  final sign = deltaKg > 0 ? '+' : '−';
  return '$sign${_formatOneDecimal(deltaKg.abs())} kg';
}

/// "120 / 80 mmHg" — solo i numeri, nessun colore o giudizio clinico
/// (Milestone 7.3, sezione 20).
String formatBloodPressure(int systolic, int diastolic) {
  return '$systolic / $diastolic mmHg';
}

/// "72 bpm" — solo se la frequenza cardiaca è presente (Milestone 7.3,
/// sezione 21); nessuna classificazione del battito.
String formatHeartRate(int heartRate) => '$heartRate bpm';

String _formatOneDecimal(double value) {
  final fixed = value.toStringAsFixed(1);
  final trimmed = fixed.endsWith('.0')
      ? fixed.substring(0, fixed.length - 2)
      : fixed;
  return trimmed.replaceAll('.', ',');
}
