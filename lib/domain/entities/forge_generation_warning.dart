/// Avvisi non bloccanti sul piano generato (Milestone 5.2, sezione 44):
/// un piano con warning viene comunque restituito — non è un errore, che
/// invece impedisce l'esito positivo (vedi [ForgeGenerationError]).
enum ForgeGenerationWarning {
  durationBelowTarget('DURATION_BELOW_TARGET'),
  durationAboveTarget('DURATION_ABOVE_TARGET'),
  missingPreferredCoverage('MISSING_PREFERRED_COVERAGE'),
  limitedExercisePool('LIMITED_EXERCISE_POOL'),
  minimumExerciseFallback('MINIMUM_EXERCISE_FALLBACK');

  const ForgeGenerationWarning(this.code);

  final String code;
}
