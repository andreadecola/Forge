/// Errori specifici dell'orchestrazione settimanale (Milestone 8.4), non del
/// Forge Engine (quelli restano `ForgeGenerationError`, mai duplicati né
/// reinterpretati qui — vedi `WeeklyPlanGenerationResult.forgeErrors`).
enum WeeklyPlanGenerationError {
  /// La settimana target è interamente nel passato rispetto a "oggi"
  /// (sezione 11): nessuna generazione automatica consentita.
  weekEntirelyInPast,

  /// La settimana target contiene già almeno una `PlannedActivity` con
  /// `origin == FORGE_ENGINE` (sezione 32/33, strategia A — bloccare):
  /// l'utente deve eliminarle manualmente prima di generarne di nuove.
  weekAlreadyHasForgeActivities,

  /// Il numero di allenamenti richiesto non è positivo.
  invalidRequestedCount,
}
