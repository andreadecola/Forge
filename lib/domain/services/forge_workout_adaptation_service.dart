import 'dart:math' as math;

import '../entities/adapted_generated_workout_plan.dart';
import '../entities/exercise_alternative.dart';
import '../entities/exercise_progression.dart';
import '../entities/forge_adaptation_context.dart';
import '../entities/forge_adaptation_decision.dart';
import '../entities/forge_adaptation_reason.dart';
import '../entities/forge_coverage_requirement.dart';
import '../entities/forge_coverage_state.dart';
import '../entities/forge_engine_config.dart';
import '../entities/forge_evaluation_result.dart';
import '../entities/forge_exercise_adaptation_action.dart';
import '../entities/forge_exercise_adaptation_decision.dart';
import '../entities/forge_exercise_evaluation.dart';
import '../entities/forge_exercise_history.dart';
import '../entities/generated_workout_exercise.dart';
import '../entities/generated_workout_plan.dart';
import 'forge_exercise_adaptation_policy.dart';
import 'forge_exercise_parameter_policy.dart';
import 'forge_parameter_progression_policy.dart';
import 'forge_workout_type_coverage_policy.dart';

/// Applica l'adattamento deciso da `ForgeProgressionAnalyzer` a un
/// [GeneratedWorkoutPlan] già composto (Milestone 5.4, sezione 33):
/// orchestratore delle guardie a livello di **intero piano** (durata,
/// copertura obbligatoria, duplicati, sezione 37-41) — le policy
/// per-esercizio (`ForgeExerciseAdaptationPolicy`/
/// `ForgeParameterProgressionPolicy`) non le conoscono, non hanno la
/// visione dell'intero piano.
///
/// Mai un esercizio inventato: ogni sostituzione proviene da
/// `ForgeEvaluationResult` (Milestone 5.1, l'intero catalogo già
/// valutato per questa richiesta) — leggere l'eleggibilità già decisa lì
/// è l'unico modo per non bypassare mai livello/attrezzatura/attivo
/// (sezione 39, STOP mai duplicato).
class ForgeWorkoutAdaptationService {
  const ForgeWorkoutAdaptationService({
    this.exerciseAdaptationPolicy = const ForgeExerciseAdaptationPolicy(),
    this.parameterProgressionPolicy = const ForgeParameterProgressionPolicy(),
    this.parameterPolicy = const ForgeExerciseParameterPolicy(),
    this.config = const ForgeEngineConfig(),
  });

  final ForgeExerciseAdaptationPolicy exerciseAdaptationPolicy;
  final ForgeParameterProgressionPolicy parameterProgressionPolicy;
  final ForgeExerciseParameterPolicy parameterPolicy;
  final ForgeEngineConfig config;

  AdaptedGeneratedWorkoutPlan adapt({
    required GeneratedWorkoutPlan plan,
    required ForgeAdaptationContext context,
    required ForgeEvaluationResult evaluation,
    required Map<int, List<ExerciseProgression>> progressionsByExerciseId,
    required Map<int, List<ExerciseProgression>> regressionsByExerciseId,
    required Map<int, List<ExerciseAlternative>> alternativesByExerciseId,
  }) {
    if (context.decision == ForgeAdaptationDecision.maintain) {
      // Sezione 46: nessuno storico (o storico insufficiente) -> piano
      // identico a quello prodotto dalla Milestone 5.2, decorato solo con
      // i metadati di adattamento.
      return AdaptedGeneratedWorkoutPlan(
        plan: plan,
        decision: ForgeAdaptationDecision.maintain,
        exerciseDecisions: [
          for (final entry in plan.exercises)
            ForgeExerciseAdaptationDecision(
              action: ForgeExerciseAdaptationAction.keep,
              sourceExerciseId: entry.exercise.id,
              reasons: const [],
            ),
        ],
      );
    }

    final byExerciseId = <int, ForgeExerciseEvaluation>{
      for (final e in evaluation.eligible) e.candidate.exercise.id: e,
      for (final e in evaluation.excluded) e.candidate.exercise.id: e,
    };
    final eligibleIds = evaluation.eligible
        .map((e) => e.candidate.exercise.id)
        .toSet();
    final requirements = ForgeWorkoutTypeCoveragePolicy.requiredCoverageFor(
      plan.workoutType,
    );
    final targetSeconds = plan.targetDurationMinutes * 60;
    final windowMax = (targetSeconds * (1 + config.planDurationTolerance))
        .round();

    final exercises = List<GeneratedWorkoutExercise>.of(plan.exercises);
    final usedIds = exercises.map((e) => e.exercise.id).toSet();
    final decisions = <ForgeExerciseAdaptationDecision>[];

    for (var i = 0; i < exercises.length; i++) {
      final entry = exercises[i];
      final sourceId = entry.exercise.id;
      final history = context.exerciseHistory[sourceId];

      if (context.decision == ForgeAdaptationDecision.progress) {
        decisions.add(
          _adaptForProgress(
            exercises: exercises,
            index: i,
            history: history,
            eligibleIds: eligibleIds,
            usedIds: usedIds,
            byExerciseId: byExerciseId,
            requirements: requirements,
            windowMax: windowMax,
            progressions: progressionsByExerciseId[sourceId] ?? const [],
          ),
        );
      } else {
        decisions.add(
          _adaptForSimplify(
            exercises: exercises,
            index: i,
            history: history,
            eligibleIds: eligibleIds,
            usedIds: usedIds,
            byExerciseId: byExerciseId,
            requirements: requirements,
            windowMax: windowMax,
            regressions: regressionsByExerciseId[sourceId] ?? const [],
            alternatives: alternativesByExerciseId[sourceId] ?? const [],
          ),
        );
      }
    }

    final totalSeconds = _totalSeconds(exercises);
    final coverageState = _coverageState(exercises, byExerciseId, requirements);
    final floor = math.max(config.minimumExercises, requirements.length);
    final isComplete =
        coverageState.isFullyCovered &&
        exercises.length >= floor &&
        totalSeconds <= windowMax;

    final adaptedPlan = GeneratedWorkoutPlan(
      request: plan.request,
      workoutType: plan.workoutType,
      targetDurationMinutes: plan.targetDurationMinutes,
      estimatedDurationSeconds: totalSeconds,
      exercises: exercises,
      warnings: plan.warnings,
      decisionReasons: plan.decisionReasons,
      isComplete: isComplete,
    );

    return AdaptedGeneratedWorkoutPlan(
      plan: adaptedPlan,
      decision: context.decision,
      exerciseDecisions: decisions,
    );
  }

  ForgeExerciseAdaptationDecision _adaptForProgress({
    required List<GeneratedWorkoutExercise> exercises,
    required int index,
    required ForgeExerciseHistory? history,
    required Set<int> eligibleIds,
    required Set<int> usedIds,
    required Map<int, ForgeExerciseEvaluation> byExerciseId,
    required List<ForgeCoverageRequirement> requirements,
    required int windowMax,
    required List<ExerciseProgression> progressions,
  }) {
    final entry = exercises[index];
    final sourceId = entry.exercise.id;

    // Priorità 1 (sezione 26): piccolo aumento di un solo parametro,
    // sullo stesso esercizio. La policy propone più candidate in ordine
    // di preferenza (reps/duration, poi eventualmente le serie) — si
    // applica la prima che rispetta la finestra di durata del piano
    // (sezione 38): se la prima sfora la tolleranza, la seconda offre un
    // adattamento più piccolo invece di rinunciare del tutto.
    final proposals = parameterProgressionPolicy.propose(
      current: entry.workoutExercise,
      history: history,
      config: config,
    );
    final currentTotal = _totalSeconds(exercises);
    for (final proposal in proposals) {
      final projected =
          currentTotal -
          entry.estimatedDurationSeconds +
          proposal.estimatedDurationSeconds;
      if (projected > windowMax) continue;
      exercises[index] = GeneratedWorkoutExercise(
        workoutExercise: proposal.workoutExercise,
        exercise: entry.exercise,
        estimatedDurationSeconds: proposal.estimatedDurationSeconds,
        score: entry.score,
        decisionReasons: entry.decisionReasons,
      );
      return ForgeExerciseAdaptationDecision(
        action: ForgeExerciseAdaptationAction.keep,
        sourceExerciseId: sourceId,
        reasons: const [ForgeAdaptationReason.parameterProgressionApplied],
      );
    }
    // Sezione 38: nessuna candidata rispetta la finestra di durata -> si
    // prova comunque la progressione di esercizio sotto.

    // Priorità 2 (sezione 26): progressione di esercizio esplicita.
    final decision = exerciseAdaptationPolicy.decide(
      sourceExercise: entry.exercise,
      history: history,
      progressions: progressions,
      regressions: const [],
      alternatives: const [],
      eligibleExerciseIds: eligibleIds,
      exerciseIdsAlreadyInPlan: usedIds,
      globalDecision: ForgeAdaptationDecision.progress,
      config: config,
    );

    if (decision.action == ForgeExerciseAdaptationAction.progress &&
        decision.targetExerciseId != null) {
      final applied = _tryApplySwap(
        exercises: exercises,
        index: index,
        targetExerciseId: decision.targetExerciseId!,
        byExerciseId: byExerciseId,
        requirements: requirements,
        windowMax: windowMax,
      );
      if (applied) {
        usedIds.remove(sourceId);
        usedIds.add(decision.targetExerciseId!);
        return decision;
      }
      return _withAction(decision, ForgeExerciseAdaptationAction.keep);
    }
    return decision;
  }

  ForgeExerciseAdaptationDecision _adaptForSimplify({
    required List<GeneratedWorkoutExercise> exercises,
    required int index,
    required ForgeExerciseHistory? history,
    required Set<int> eligibleIds,
    required Set<int> usedIds,
    required Map<int, ForgeExerciseEvaluation> byExerciseId,
    required List<ForgeCoverageRequirement> requirements,
    required int windowMax,
    required List<ExerciseProgression> regressions,
    required List<ExerciseAlternative> alternatives,
  }) {
    final entry = exercises[index];
    final sourceId = entry.exercise.id;

    final decision = exerciseAdaptationPolicy.decide(
      sourceExercise: entry.exercise,
      history: history,
      progressions: const [],
      regressions: regressions,
      alternatives: alternatives,
      eligibleExerciseIds: eligibleIds,
      exerciseIdsAlreadyInPlan: usedIds,
      globalDecision: ForgeAdaptationDecision.simplify,
      config: config,
    );

    final isSwapAction =
        decision.action == ForgeExerciseAdaptationAction.regress ||
        decision.action == ForgeExerciseAdaptationAction.replace;
    if (isSwapAction && decision.targetExerciseId != null) {
      final applied = _tryApplySwap(
        exercises: exercises,
        index: index,
        targetExerciseId: decision.targetExerciseId!,
        byExerciseId: byExerciseId,
        requirements: requirements,
        windowMax: windowMax,
      );
      if (applied) {
        usedIds.remove(sourceId);
        usedIds.add(decision.targetExerciseId!);
        return decision;
      }
      return _withAction(
        decision,
        ForgeExerciseAdaptationAction.avoidTemporarily,
      );
    }
    return decision;
  }

  /// `true` se la sostituzione è stata applicata (sezione 37-41): rifiuta
  /// se il target non è realmente eleggibile per la richiesta corrente,
  /// se sfora la finestra di durata del piano, o se distrugge una
  /// copertura obbligatoria prima soddisfatta. Sostituisce sempre nella
  /// **stessa posizione** (stesso `order`, sezione 41) — non ricompone
  /// mai l'intera scheda.
  bool _tryApplySwap({
    required List<GeneratedWorkoutExercise> exercises,
    required int index,
    required int targetExerciseId,
    required Map<int, ForgeExerciseEvaluation> byExerciseId,
    required List<ForgeCoverageRequirement> requirements,
    required int windowMax,
  }) {
    final targetEval = byExerciseId[targetExerciseId];
    final estimatedDuration = targetEval?.estimatedDurationSeconds;
    final score = targetEval?.score;
    if (targetEval == null ||
        !targetEval.eligibility.eligible ||
        estimatedDuration == null ||
        score == null) {
      return false;
    }

    final original = exercises[index];
    final replacement = GeneratedWorkoutExercise(
      workoutExercise: parameterPolicy.parametersFor(
        exercise: targetEval.candidate.exercise,
        order: original.workoutExercise.order,
      ),
      exercise: targetEval.candidate.exercise,
      estimatedDurationSeconds: estimatedDuration,
      score: score,
      decisionReasons: const [],
    );

    final tentative = List<GeneratedWorkoutExercise>.of(exercises)
      ..[index] = replacement;

    if (_totalSeconds(tentative) > windowMax) return false;

    final missingBefore = _coverageState(
      exercises,
      byExerciseId,
      requirements,
    ).missing;
    final missingAfter = _coverageState(
      tentative,
      byExerciseId,
      requirements,
    ).missing;
    final newlyMissing = missingAfter.where((r) => !missingBefore.contains(r));
    if (newlyMissing.isNotEmpty) return false;

    exercises[index] = replacement;
    return true;
  }

  int _totalSeconds(List<GeneratedWorkoutExercise> exercises) {
    if (exercises.isEmpty) return 0;
    final durations = exercises
        .map((e) => e.estimatedDurationSeconds)
        .fold<int>(0, (a, b) => a + b);
    return durations +
        (exercises.length - 1) * config.transitionSecondsBetweenExercises;
  }

  ForgeCoverageState _coverageState(
    List<GeneratedWorkoutExercise> exercises,
    Map<int, ForgeExerciseEvaluation> byExerciseId,
    List<ForgeCoverageRequirement> requirements,
  ) {
    final categoryCounts = <String, int>{};
    for (final entry in exercises) {
      final categoryCode =
          byExerciseId[entry.exercise.id]?.candidate.categoryCode;
      if (categoryCode == null) continue;
      categoryCounts[categoryCode] = (categoryCounts[categoryCode] ?? 0) + 1;
    }
    final covered = <ForgeCoverageRequirement>[];
    final missing = <ForgeCoverageRequirement>[];
    for (final requirement in requirements) {
      final count = categoryCounts.entries
          .where((entry) => requirement.matchesCategory(entry.key))
          .fold<int>(0, (sum, entry) => sum + entry.value);
      if (count >= requirement.minCount) {
        covered.add(requirement);
      } else {
        missing.add(requirement);
      }
    }
    return ForgeCoverageState(
      covered: covered,
      missing: missing,
      categoryCounts: categoryCounts,
    );
  }

  ForgeExerciseAdaptationDecision _withAction(
    ForgeExerciseAdaptationDecision decision,
    ForgeExerciseAdaptationAction action,
  ) {
    return ForgeExerciseAdaptationDecision(
      action: action,
      sourceExerciseId: decision.sourceExerciseId,
      reasons: decision.reasons,
    );
  }
}
