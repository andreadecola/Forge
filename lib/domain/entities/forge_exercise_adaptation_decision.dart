import 'forge_adaptation_reason.dart';
import 'forge_exercise_adaptation_action.dart';

/// Decisione di adattamento per un singolo esercizio del piano (Milestone
/// 5.4, sezione 16).
class ForgeExerciseAdaptationDecision {
  const ForgeExerciseAdaptationDecision({
    required this.action,
    required this.sourceExerciseId,
    this.targetExerciseId,
    required this.reasons,
  });

  final ForgeExerciseAdaptationAction action;

  final int sourceExerciseId;

  /// Non nullo solo per `progress` (progressione di esercizio, non di
  /// parametro), `regress`, `replace`.
  final int? targetExerciseId;

  /// Più di un motivo può coesistere (es. `repeatedExerciseSkip` +
  /// `explicitRegressionAvailable`) — mai una singola stringa pronta,
  /// stesso principio di `ForgeScore.reasons`/`ForgeCompositionReason`.
  final List<ForgeAdaptationReason> reasons;
}
