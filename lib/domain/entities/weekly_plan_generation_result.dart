import 'forge_generation_error.dart';
import 'forge_generation_warning.dart';
import 'weekly_plan_generation_error.dart';
import 'weekly_plan_generation_proposal.dart';

/// Esito di [WeeklyPlanGenerationService.buildProposal] (Milestone 8.4):
/// stesso principio dei risultati Forge Engine (M5) — `success` è sempre un
/// getter derivato, mai un campo indipendente che possa divergere dagli
/// errori.
class WeeklyPlanGenerationResult {
  const WeeklyPlanGenerationResult({
    this.proposal,
    this.errors = const [],
    this.forgeErrors = const [],
    this.forgeWarnings = const [],
  });

  bool get success => errors.isEmpty && forgeErrors.isEmpty;

  final WeeklyPlanGenerationProposal? proposal;

  /// Errori dell'orchestrazione settimanale (settimana passata, settimana
  /// già generata, conteggio non valido) — non del Forge Engine.
  final List<WeeklyPlanGenerationError> errors;

  /// Propagati identici dal Forge Engine (Milestone 5), mai reinterpretati:
  /// traducibili in UI con `ForgeLabels.generationErrorMessage`.
  final List<ForgeGenerationError> forgeErrors;
  final List<ForgeGenerationWarning> forgeWarnings;
}
