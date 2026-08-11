import 'forge_decision_reason.dart';
import 'forge_score_component.dart';

/// Punteggio completo di un candidato eleggibile (Milestone 5.1, sezione
/// 34): mai un solo numero — sempre scomposto in [components] e
/// accompagnato da [reasons] spiegabili.
class ForgeScore {
  const ForgeScore({
    required this.total,
    required this.components,
    required this.reasons,
  });

  /// Somma pesata dei [components] (pesi in `ForgeEngineConfig`),
  /// `0.0..1.0`.
  final double total;

  final List<ForgeScoreComponent> components;
  final List<ForgeDecisionReason> reasons;
}
