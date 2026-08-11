/// Motivi di adattamento (Milestone 5.4, sezione 35): codici domain
/// stabili, mai una frase italiana pronta (stesso principio di
/// `ForgeExclusionReason`/`ForgeCompositionReasonCode`) — usati sia a
/// livello globale (`ForgeAdaptationContext.reasons`) sia per-esercizio
/// (`ForgeExerciseAdaptationDecision.reasons`).
enum ForgeAdaptationReason {
  insufficientHistory('INSUFFICIENT_HISTORY'),
  stablePerformance('STABLE_PERFORMANCE'),
  highRecentCompletion('HIGH_RECENT_COMPLETION'),
  repeatedExerciseCompletion('REPEATED_EXERCISE_COMPLETION'),
  repeatedExerciseSkip('REPEATED_EXERCISE_SKIP'),
  lowSetCompletion('LOW_SET_COMPLETION'),
  explicitProgressionAvailable('EXPLICIT_PROGRESSION_AVAILABLE'),
  explicitRegressionAvailable('EXPLICIT_REGRESSION_AVAILABLE'),
  alternativeSelected('ALTERNATIVE_SELECTED'),
  parameterProgressionApplied('PARAMETER_PROGRESSION_APPLIED');

  const ForgeAdaptationReason(this.code);

  final String code;
}
