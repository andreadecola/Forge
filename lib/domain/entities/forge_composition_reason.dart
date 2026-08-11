/// Codici domain per spiegare una decisione di **composizione**
/// (Milestone 5.2, sezione 46/47) — distinti dai
/// `ForgeDecisionReasonCode` della Milestone 5.1 (che spiegano i singoli
/// componenti dello score di un esercizio isolato): questi spiegano
/// invece scelte che riguardano l'intero piano (perché un esercizio è
/// entrato nella selezione, perché il piano è nello stato in cui è).
///
/// Codici generici, non specifici a un WorkoutType (es. `coverageSatisfied`
/// invece di `fullBodyCoverageSatisfied`): il tipo interessato, se serve,
/// va nel [ForgeCompositionReason.detail], non nel nome del codice — stesso
/// principio già seguito in Milestone 5.1. Mai una frase italiana pronta
/// per la UI (sezione 48).
enum ForgeCompositionReasonCode {
  // Esercizio
  selectedForCoverage('SELECTED_FOR_COVERAGE'),
  highBaseScore('HIGH_BASE_SCORE'),
  goodDurationFit('GOOD_DURATION_FIT'),
  reducedRedundancy('REDUCED_REDUNDANCY'),
  minimumExerciseFallback('MINIMUM_EXERCISE_FALLBACK'),

  // Piano
  coverageSatisfied('COVERAGE_SATISFIED'),
  partialCoverage('PARTIAL_COVERAGE'),
  withinDurationTarget('WITHIN_DURATION_TARGET'),
  belowDurationTarget('BELOW_DURATION_TARGET'),
  aboveDurationTarget('ABOVE_DURATION_TARGET'),
  usedOnlyAvailableEquipment('USED_ONLY_AVAILABLE_EQUIPMENT');

  const ForgeCompositionReasonCode(this.code);

  final String code;
}

/// Spiegazione di una decisione di composizione: [detail] è un dato
/// domain opzionale a supporto (es. il codice categoria coperta), mai una
/// frase pronta per l'utente.
class ForgeCompositionReason {
  const ForgeCompositionReason({required this.code, this.detail});

  final ForgeCompositionReasonCode code;
  final String? detail;
}
