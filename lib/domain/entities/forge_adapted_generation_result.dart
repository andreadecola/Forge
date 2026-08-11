import 'adapted_generated_workout_plan.dart';
import 'forge_evaluation_result.dart';
import 'forge_generation_error.dart';
import 'forge_generation_warning.dart';

/// Esito di `GenerateAdaptedForgeWorkout` (Milestone 5.4, sezione 44):
/// stesso principio di `ForgeGenerationResult` (Milestone 5.2) — mai
/// un'eccezione per un normale "non riesco ad adattare", sempre un
/// risultato spiegabile. Riusa [ForgeGenerationError]: l'adattamento non
/// introduce nuove categorie di fallimento a monte della generazione
/// base (richiesta non valida, nessun eleggibile, copertura mancante),
/// e a valle usa `cannotBuildExecutablePlan` per il caso limite in cui
/// l'adattamento produce un piano che non supera la rivalidazione
/// (sezione 37) — non un errore concettualmente diverso, la stessa
/// difesa "il piano finale non è eseguibile".
class ForgeAdaptedGenerationResult {
  const ForgeAdaptedGenerationResult({
    this.plan,
    required this.errors,
    required this.warnings,
    required this.evaluation,
  });

  bool get success => errors.isEmpty;

  final AdaptedGeneratedWorkoutPlan? plan;
  final List<ForgeGenerationError> errors;
  final List<ForgeGenerationWarning> warnings;
  final ForgeEvaluationResult evaluation;
}
