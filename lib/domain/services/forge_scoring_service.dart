import '../entities/equipment.dart';
import '../entities/forge_candidate.dart';
import '../entities/forge_category_tier.dart';
import '../entities/forge_decision_reason.dart';
import '../entities/forge_engine_config.dart';
import '../entities/forge_score.dart';
import '../entities/forge_score_component.dart';
import '../entities/workout_enums.dart';
import 'forge_workout_type_policy.dart';

/// Assegna un punteggio a un candidato già eleggibile (Milestone 5.1,
/// sezione 33): non scegliere ancora l'intero workout, solo valutare il
/// singolo esercizio. Ogni componente è deterministico e documentato qui
/// sotto — nessun numero non spiegato (sezione 64).
class ForgeScoringService {
  const ForgeScoringService();

  ForgeScore score({
    required ForgeCandidate candidate,
    required WorkoutType workoutType,
    required int userLevel,
    required int estimatedDurationSeconds,
    required int targetDurationMinutes,
    required ForgeEngineConfig config,
  }) {
    final workoutTypeMatch = _workoutTypeMatch(candidate, workoutType);
    final levelFit = _levelFit(candidate, userLevel);
    final equipmentSimplicity = _equipmentSimplicity(candidate);
    final durationFit = _durationFit(
      estimatedDurationSeconds,
      targetDurationMinutes,
      config,
    );

    final components = [
      workoutTypeMatch.component,
      levelFit.component,
      equipmentSimplicity.component,
      durationFit.component,
    ];
    final reasons = [
      workoutTypeMatch.reason,
      levelFit.reason,
      equipmentSimplicity.reason,
      durationFit.reason,
    ];

    final total = components.fold<double>(
      0.0,
      (sum, c) => sum + c.value * (config.componentWeights[c.type] ?? 0.0),
    );

    return ForgeScore(total: total, components: components, reasons: reasons);
  }

  /// `required`/`preferred` -> punteggio massimo (sezione 36; `required`
  /// si comporta come `preferred` in questa milestone, vedi
  /// `ForgeCategoryTier`), `neutral` -> metà, `discouraged`/`excluded` ->
  /// vicino allo zero — **soft**: non esclude mai il candidato, che è già
  /// eleggibile a monte.
  ({ForgeScoreComponent component, ForgeDecisionReason reason})
  _workoutTypeMatch(ForgeCandidate candidate, WorkoutType workoutType) {
    final tier = ForgeWorkoutTypePolicy.tierFor(
      workoutType: workoutType,
      categoryCode: candidate.categoryCode,
    );
    final (value, reasonCode) = switch (tier) {
      ForgeCategoryTier.required || ForgeCategoryTier.preferred => (
        1.0,
        ForgeDecisionReasonCode.workoutTypePreferred,
      ),
      ForgeCategoryTier.neutral => (
        0.5,
        ForgeDecisionReasonCode.workoutTypeNeutral,
      ),
      ForgeCategoryTier.discouraged || ForgeCategoryTier.excluded => (
        0.2,
        ForgeDecisionReasonCode.workoutTypeDiscouraged,
      ),
    };
    return (
      component: ForgeScoreComponent(
        type: ForgeScoreComponentType.workoutTypeMatch,
        value: value,
      ),
      reason: ForgeDecisionReason(
        component: ForgeScoreComponentType.workoutTypeMatch,
        reasonCode: reasonCode,
        detail: candidate.categoryCode,
      ),
    );
  }

  /// `1 / (1 + gap)`, con `gap = userLevel - exercise.minimumLevel` (>= 0:
  /// il candidato è già eleggibile, quindi `minimumLevel <= userLevel` è
  /// garantito). Un esercizio con livello minimo pari a quello
  /// dell'utente (`gap = 0`) riceve il punteggio massimo (sezione 37); più
  /// l'esercizio è "sotto" il livello dell'utente, più il punteggio
  /// decresce verso 0 senza mai escludere il candidato.
  ({ForgeScoreComponent component, ForgeDecisionReason reason}) _levelFit(
    ForgeCandidate candidate,
    int userLevel,
  ) {
    final gap = userLevel - candidate.exercise.minimumLevel;
    final value = 1 / (1 + gap);
    return (
      component: ForgeScoreComponent(
        type: ForgeScoreComponentType.levelFit,
        value: value,
      ),
      reason: ForgeDecisionReason(
        component: ForgeScoreComponentType.levelFit,
        reasonCode: gap == 0
            ? ForgeDecisionReasonCode.levelCloseToUser
            : ForgeDecisionReasonCode.levelBelowUser,
        detail: '$gap',
      ),
    );
  }

  /// `1 / (1 + N)`, con N = numero di attrezzature obbligatorie diverse da
  /// `NONE` (sezione 38): un piccolo bonus per la semplicità, mai
  /// dominante (il peso in [ForgeEngineConfig] resta il più basso tra i
  /// quattro componenti di default).
  ({ForgeScoreComponent component, ForgeDecisionReason reason})
  _equipmentSimplicity(ForgeCandidate candidate) {
    final count = candidate.requiredEquipmentCodes
        .where((code) => code != Equipment.noneCode)
        .length;
    final value = 1 / (1 + count);
    return (
      component: ForgeScoreComponent(
        type: ForgeScoreComponentType.equipmentSimplicity,
        value: value,
      ),
      reason: ForgeDecisionReason(
        component: ForgeScoreComponentType.equipmentSimplicity,
        reasonCode: count == 0
            ? ForgeDecisionReasonCode.equipmentFree
            : ForgeDecisionReasonCode.equipmentRequired,
        detail: '$count',
      ),
    );
  }

  /// Solo un controllo di ragionevolezza contro la durata target
  /// dell'intera richiesta (sezione 39 — **non** ancora un fit contro il
  /// resto della scheda, rimandato alla Milestone 5.2): se la stima
  /// dell'esercizio resta entro `durationTolerance` della durata target,
  /// punteggio massimo; oltre, decresce linearmente fino a 0 quando da
  /// solo occuperebbe l'intera durata target.
  ({ForgeScoreComponent component, ForgeDecisionReason reason}) _durationFit(
    int estimatedDurationSeconds,
    int targetDurationMinutes,
    ForgeEngineConfig config,
  ) {
    final targetSeconds = targetDurationMinutes * 60;
    final ratio = targetSeconds == 0
        ? 1.0
        : estimatedDurationSeconds / targetSeconds;
    final tolerance = config.durationTolerance;

    double value;
    ForgeDecisionReasonCode reasonCode;
    if (ratio <= tolerance) {
      value = 1.0;
      reasonCode = ForgeDecisionReasonCode.durationWithinBudget;
    } else {
      final span = 1 - tolerance;
      value = span <= 0
          ? 0.0
          : (1 - (ratio - tolerance) / span).clamp(0.0, 1.0);
      reasonCode = ForgeDecisionReasonCode.durationOverBudget;
    }

    return (
      component: ForgeScoreComponent(
        type: ForgeScoreComponentType.durationFit,
        value: value,
      ),
      reason: ForgeDecisionReason(
        component: ForgeScoreComponentType.durationFit,
        reasonCode: reasonCode,
        detail: ratio.toStringAsFixed(2),
      ),
    );
  }
}
