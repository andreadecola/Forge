import 'forge_score_component.dart';

/// Codice domain stabile per una motivazione di punteggio (sezione 44):
/// **non** una frase italiana pronta per la UI — la traduzione arriverà
/// quando il Forge Engine avrà un'interfaccia (non in questa milestone).
enum ForgeDecisionReasonCode {
  workoutTypePreferred('WORKOUT_TYPE_PREFERRED'),
  workoutTypeNeutral('WORKOUT_TYPE_NEUTRAL'),
  workoutTypeDiscouraged('WORKOUT_TYPE_DISCOURAGED'),
  levelCloseToUser('LEVEL_CLOSE_TO_USER'),
  levelBelowUser('LEVEL_BELOW_USER'),
  equipmentFree('EQUIPMENT_FREE'),
  equipmentRequired('EQUIPMENT_REQUIRED'),
  durationWithinBudget('DURATION_WITHIN_BUDGET'),
  durationOverBudget('DURATION_OVER_BUDGET');

  const ForgeDecisionReasonCode(this.code);

  final String code;
}

/// Spiegazione di un [ForgeScoreComponent] (sezione 44): [detail] è un
/// dato domain opzionale a supporto (es. il codice categoria valutato),
/// mai una frase pronta per l'utente.
class ForgeDecisionReason {
  const ForgeDecisionReason({
    required this.component,
    required this.reasonCode,
    this.detail,
  });

  final ForgeScoreComponentType component;
  final ForgeDecisionReasonCode reasonCode;
  final String? detail;
}
