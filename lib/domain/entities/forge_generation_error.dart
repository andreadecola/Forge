/// Errori bloccanti della generazione (Milestone 5.2, sezione 45):
/// presenti solo quando la generazione non può considerarsi riuscita
/// (`ForgeGenerationResult.success == false`). Un piano di miglior
/// tentativo può comunque essere presente per debug/spiegabilità (sezione
/// 6 — nessuna eccezione lanciata per un normale "non riesco a
/// comporre").
enum ForgeGenerationError {
  /// La richiesta non è valida (sezione 11 della Milestone 5.1: livello
  /// <= 0, durata <= 0).
  invalidRequest('INVALID_REQUEST'),

  /// `WorkoutType.custom` (sezione 24/32): decisione già presa in
  /// Milestone 5.1, non ridiscussa qui.
  unsupportedWorkoutType('UNSUPPORTED_WORKOUT_TYPE'),

  /// Nessun esercizio eleggibile nel catalogo fornito (M5.1
  /// `ForgeEvaluationResult.eligible` vuoto): nulla da comporre.
  insufficientEligibleExercises('INSUFFICIENT_ELIGIBLE_EXERCISES'),

  /// Almeno un requisito di copertura **obbligatoria** non ha alcun
  /// candidato eleggibile che lo soddisfi (a differenza di
  /// `missingPreferredCoverage`, un semplice avviso).
  missingRequiredCoverage('MISSING_REQUIRED_COVERAGE'),

  /// Nessun esercizio è stato selezionabile in alcun modo (caso limite,
  /// es. tutti i candidati eleggibili hanno parametri comunque non
  /// eseguibili — sezione 36): il generatore si difende comunque, anche
  /// se l'eligibility della Milestone 5.1 dovrebbe già averli esclusi.
  cannotBuildExecutablePlan('CANNOT_BUILD_EXECUTABLE_PLAN');

  const ForgeGenerationError(this.code);

  final String code;
}
