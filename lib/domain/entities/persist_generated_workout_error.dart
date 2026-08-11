/// Errori bloccanti della persistenza di un piano generato (Milestone
/// 5.3): presenti solo quando `PersistGeneratedWorkoutResult.success ==
/// false`. Nessuna eccezione per un normale "non posso salvare questo
/// piano" — stesso principio di `ForgeGenerationError` (Milestone 5.2).
enum PersistGeneratedWorkoutError {
  /// `ForgeGenerationResult.success == false`: la generazione stessa non
  /// è riuscita, nulla da persistere (sezione 26).
  generationFailed('GENERATION_FAILED'),

  /// Caso limite di difesa: `success == true` ma `plan == null` (non
  /// dovrebbe accadere per costruzione del generatore, Milestone 5.2).
  missingPlan('MISSING_PLAN'),

  /// `plan.isComplete == false`: la scelta più sicura per questa
  /// milestone è non salvare mai automaticamente un piano incompleto
  /// (sezione 27) — una futura UI potrà offrire "salva comunque come
  /// bozza".
  incompletePlan('INCOMPLETE_PLAN'),

  /// `GeneratedWorkoutPlanValidator` ha trovato un problema strutturale
  /// nel piano (ordine non valido, esercizio duplicato, parametro non
  /// valido).
  invalidGeneratedPlan('INVALID_GENERATED_PLAN'),

  /// Il `Workout` convertito non supera `WorkoutValidationService.validateReady`.
  invalidWorkout('INVALID_WORKOUT'),

  /// La scrittura sul database è fallita (es. vincolo di integrità
  /// violato): nessuna scrittura parziale, la transazione è stata
  /// annullata.
  persistenceFailed('PERSISTENCE_FAILED');

  const PersistGeneratedWorkoutError(this.code);

  final String code;
}
