import '../entities/forge_composition_reason.dart';
import '../entities/forge_evaluation_result.dart';
import '../entities/forge_generation_error.dart';
import '../entities/forge_generation_result.dart';
import 'forge_workout_composer.dart';
import 'forge_workout_type_policy.dart';

/// Orchestratore della generazione (Milestone 5.2, sezioni 46-51): domain
/// puro come [ForgeEngine] della Milestone 5.1, nessuna dipendenza da
/// repository/DB — riceve un [ForgeEvaluationResult] già calcolato dal
/// chiamante (l'use case applicativo). **Non salva alcun `Workout`**.
///
/// Non lancia eccezioni per un normale "non riesco a comporre" (sezione
/// 6): ogni esito, anche negativo, è un [ForgeGenerationResult] spiegabile.
class ForgeWorkoutGenerator {
  const ForgeWorkoutGenerator({this.composer = const ForgeWorkoutComposer()});

  final ForgeWorkoutComposer composer;

  ForgeGenerationResult generate(ForgeEvaluationResult evaluation) {
    final request = evaluation.normalizedRequest;

    // Stesso esito vuoto-e-spiegato di `ForgeEngine` (Milestone 5.1,
    // sezione 11) quando la richiesta non ha superato `ForgeRequestValidator`
    // — nessun candidato è mai stato valutato.
    final wasInvalidRequest =
        evaluation.eligible.isEmpty &&
        evaluation.excluded.isEmpty &&
        evaluation.warnings.isNotEmpty;
    if (wasInvalidRequest) {
      final error = ForgeWorkoutTypePolicy.isSupported(request.workoutType)
          ? ForgeGenerationError.invalidRequest
          : ForgeGenerationError.unsupportedWorkoutType;
      return ForgeGenerationResult(
        errors: [error],
        warnings: const [],
        evaluation: evaluation,
      );
    }

    if (evaluation.eligible.isEmpty) {
      return ForgeGenerationResult(
        errors: const [ForgeGenerationError.insufficientEligibleExercises],
        warnings: const [],
        evaluation: evaluation,
      );
    }

    final plan = composer.compose(evaluation);

    if (plan.exercises.isEmpty) {
      // Caso limite di difesa (sezione 45): l'eligibility della Milestone
      // 5.1 dovrebbe già garantire almeno un candidato eleggibile qui.
      return ForgeGenerationResult(
        errors: const [ForgeGenerationError.cannotBuildExecutablePlan],
        warnings: const [],
        evaluation: evaluation,
      );
    }

    final hasPartialCoverage = plan.decisionReasons.any(
      (reason) => reason.code == ForgeCompositionReasonCode.partialCoverage,
    );

    return ForgeGenerationResult(
      plan: plan,
      errors: hasPartialCoverage
          ? const [ForgeGenerationError.missingRequiredCoverage]
          : const [],
      warnings: plan.warnings,
      evaluation: evaluation,
    );
  }
}
