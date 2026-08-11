import 'forge_evaluation_result.dart';
import 'forge_generation_error.dart';
import 'forge_generation_warning.dart';
import 'generated_workout_plan.dart';

/// Esito della generazione (Milestone 5.2, sezione 6): mai un'eccezione
/// per un normale "non riesco a comporre" — sempre un risultato
/// spiegabile.
///
/// [plan] può essere non-`null` anche quando [success] è `false`: un
/// piano di miglior tentativo (es. con copertura obbligatoria mancante)
/// resta comunque utile per debug/spiegabilità, stesso principio già
/// seguito per gli esclusi in `ForgeEvaluationResult` (Milestone 5.1,
/// sezione 49). È `null` solo quando non è stato possibile selezionare
/// alcun esercizio (richiesta non valida, nessun eleggibile, o nessun
/// esercizio comunque selezionabile).
class ForgeGenerationResult {
  const ForgeGenerationResult({
    this.plan,
    required this.errors,
    required this.warnings,
    required this.evaluation,
  });

  /// Sempre `errors.isEmpty` — un getter, non un campo indipendente, per
  /// non poter mai divergere dalla lista degli errori.
  bool get success => errors.isEmpty;

  final GeneratedWorkoutPlan? plan;
  final List<ForgeGenerationError> errors;
  final List<ForgeGenerationWarning> warnings;

  /// La valutazione della Milestone 5.1 da cui si è partiti: sempre
  /// presente, anche in caso di fallimento (spiega *perché* non c'erano
  /// candidati, es. tutti esclusi per `missingEquipment`).
  final ForgeEvaluationResult evaluation;
}
