import '../entities/exercise.dart';
import '../entities/exercise_alternative.dart';
import '../entities/exercise_progression.dart';
import '../entities/forge_adaptation_decision.dart';
import '../entities/forge_adaptation_reason.dart';
import '../entities/forge_engine_config.dart';
import '../entities/forge_exercise_adaptation_action.dart';
import '../entities/forge_exercise_adaptation_decision.dart';
import '../entities/forge_exercise_history.dart';

/// Decide l'azione per un singolo esercizio del piano (Milestone 5.4,
/// sezione 15): puro, nessuna guardia a livello di piano intero (durata
/// complessiva, copertura obbligatoria, duplicati — quelle vivono in
/// `ForgeWorkoutAdaptationService`, sezione 37-41, perché richiedono la
/// visione dell'intero piano che questa policy non ha). Riceve
/// progressioni/regressioni/alternative già risolte dal chiamante
/// (`ExerciseRepository`, sezione 18/19/20): non inventa mai una
/// relazione che il catalogo non ha (STOP 2).
class ForgeExerciseAdaptationPolicy {
  const ForgeExerciseAdaptationPolicy();

  /// [eligibleExerciseIds] sono gli id già risultati eleggibili per la
  /// richiesta corrente in `ForgeEvaluationResult` (Milestone 5.1): mai
  /// una nuova valutazione di eleggibilità qui, sarebbe una seconda
  /// interpretazione (STOP 3/sezione 39) — si legge solo la decisione già
  /// presa dallo stesso motore per la stessa richiesta.
  ForgeExerciseAdaptationDecision decide({
    required Exercise sourceExercise,
    required ForgeExerciseHistory? history,
    required List<ExerciseProgression> progressions,
    required List<ExerciseProgression> regressions,
    required List<ExerciseAlternative> alternatives,
    required Set<int> eligibleExerciseIds,
    required Set<int> exerciseIdsAlreadyInPlan,
    required ForgeAdaptationDecision globalDecision,
    required ForgeEngineConfig config,
  }) {
    switch (globalDecision) {
      case ForgeAdaptationDecision.maintain:
        return _keep(sourceExercise.id, const []);
      case ForgeAdaptationDecision.progress:
        return _decideProgress(
          sourceExercise,
          history,
          progressions,
          eligibleExerciseIds,
          exerciseIdsAlreadyInPlan,
          config,
        );
      case ForgeAdaptationDecision.simplify:
        return _decideSimplify(
          sourceExercise,
          history,
          regressions,
          alternatives,
          eligibleExerciseIds,
          exerciseIdsAlreadyInPlan,
          config,
        );
    }
  }

  ForgeExerciseAdaptationDecision _decideProgress(
    Exercise source,
    ForgeExerciseHistory? history,
    List<ExerciseProgression> progressions,
    Set<int> eligibleExerciseIds,
    Set<int> exerciseIdsAlreadyInPlan,
    ForgeEngineConfig config,
  ) {
    // Sezione 21: eseguito sufficientemente + completion sufficientemente
    // alta, altrimenti KEEP indipendentemente da quante progressioni
    // esistano nel catalogo.
    if (!_hasSufficientEvidence(history, config)) {
      return _keep(source.id, const []);
    }
    if (progressions.isEmpty) {
      return _keep(source.id, const []);
    }
    for (final progression in progressions) {
      final targetId = progression.target.id;
      if (exerciseIdsAlreadyInPlan.contains(targetId)) continue;
      if (!eligibleExerciseIds.contains(targetId)) continue;
      return ForgeExerciseAdaptationDecision(
        action: ForgeExerciseAdaptationAction.progress,
        sourceExerciseId: source.id,
        targetExerciseId: targetId,
        reasons: const [
          ForgeAdaptationReason.explicitProgressionAvailable,
          ForgeAdaptationReason.repeatedExerciseCompletion,
        ],
      );
    }
    // Nessuna progressione eleggibile/non duplicata trovata (sezione 39/60).
    return _keep(source.id, const []);
  }

  ForgeExerciseAdaptationDecision _decideSimplify(
    Exercise source,
    ForgeExerciseHistory? history,
    List<ExerciseProgression> regressions,
    List<ExerciseAlternative> alternatives,
    Set<int> eligibleExerciseIds,
    Set<int> exerciseIdsAlreadyInPlan,
    ForgeEngineConfig config,
  ) {
    final repeatedSkip =
        history != null && history.timesSkipped >= config.repeatedSkipThreshold;
    final lowSetCompletion =
        history?.setCompletionRate != null &&
        history!.setCompletionRate! < config.regressSetCompletionRateThreshold;

    // Sezione 22: mai un singolo skip da solo — serve skip ripetuto o
    // completamento serie basso.
    if (!repeatedSkip && !lowSetCompletion) {
      return _keep(source.id, const []);
    }

    final signalReasons = [
      if (repeatedSkip) ForgeAdaptationReason.repeatedExerciseSkip,
      if (lowSetCompletion) ForgeAdaptationReason.lowSetCompletion,
    ];

    for (final regression in regressions) {
      final targetId = regression.target.id;
      if (exerciseIdsAlreadyInPlan.contains(targetId)) continue;
      if (!eligibleExerciseIds.contains(targetId)) continue;
      return ForgeExerciseAdaptationDecision(
        action: ForgeExerciseAdaptationAction.regress,
        sourceExerciseId: source.id,
        targetExerciseId: targetId,
        reasons: [
          ...signalReasons,
          ForgeAdaptationReason.explicitRegressionAvailable,
        ],
      );
    }

    // Sezione 23: alternativa considerata solo quando la regressione non
    // è disponibile/appropriata (già filtrata sopra).
    for (final alternative in alternatives) {
      final targetId = alternative.target.id;
      if (exerciseIdsAlreadyInPlan.contains(targetId)) continue;
      if (!eligibleExerciseIds.contains(targetId)) continue;
      return ForgeExerciseAdaptationDecision(
        action: ForgeExerciseAdaptationAction.replace,
        sourceExerciseId: source.id,
        targetExerciseId: targetId,
        reasons: [...signalReasons, ForgeAdaptationReason.alternativeSelected],
      );
    }

    // Sezione 50: segnale presente, nessun target valido -> mai inventare
    // un esercizio, solo segnalarlo.
    return ForgeExerciseAdaptationDecision(
      action: ForgeExerciseAdaptationAction.avoidTemporarily,
      sourceExerciseId: source.id,
      reasons: signalReasons,
    );
  }

  bool _hasSufficientEvidence(
    ForgeExerciseHistory? history,
    ForgeEngineConfig config,
  ) {
    if (history == null) return false;
    if (history.timesCompleted <
        config.minimumExerciseOccurrencesForProgression) {
      return false;
    }
    final rate = history.completionRate;
    return rate != null &&
        rate >= config.progressExerciseCompletionRateThreshold;
  }

  ForgeExerciseAdaptationDecision _keep(
    int sourceExerciseId,
    List<ForgeAdaptationReason> reasons,
  ) {
    return ForgeExerciseAdaptationDecision(
      action: ForgeExerciseAdaptationAction.keep,
      sourceExerciseId: sourceExerciseId,
      reasons: reasons,
    );
  }
}
