import 'forge_exclusion_reason.dart';

/// Esito della valutazione di eleggibilità di un esercizio (Milestone 5.1,
/// sezione 16): anche un esercizio escluso conserva i motivi, per essere
/// spiegabile (sezione 49) — non viene mai scartato in silenzio.
class ForgeEligibilityResult {
  const ForgeEligibilityResult({required this.eligible, required this.reasons});

  final bool eligible;

  /// Vuoto se [eligible] è `true`. Può contenere più di un motivo (un
  /// esercizio può violare più vincoli HARD contemporaneamente, es.
  /// inattivo *e* senza attrezzatura): tutti vengono riportati, non solo
  /// il primo trovato.
  final List<ForgeExclusionReason> reasons;

  const ForgeEligibilityResult.eligible() : eligible = true, reasons = const [];
}
