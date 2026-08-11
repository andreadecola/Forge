import 'dart:math' as math;

import '../entities/forge_composition_reason.dart';
import '../entities/forge_coverage_requirement.dart';
import '../entities/forge_coverage_state.dart';
import '../entities/forge_engine_config.dart';
import '../entities/forge_evaluation_result.dart';
import '../entities/forge_exercise_evaluation.dart';
import '../entities/forge_generation_warning.dart';
import '../entities/forge_selection_score.dart';
import '../entities/generated_workout_exercise.dart';
import '../entities/generated_workout_plan.dart';
import '../entities/workout_enums.dart';
import 'forge_exercise_ordering_policy.dart';
import 'forge_exercise_parameter_policy.dart';
import 'forge_workout_type_coverage_policy.dart';

class _Selection {
  _Selection(this.evaluation, this.reasons);

  final ForgeExerciseEvaluation evaluation;
  final List<ForgeCompositionReason> reasons;
}

/// Compone un [GeneratedWorkoutPlan] a partire da un [ForgeEvaluationResult]
/// già calcolato dalla Milestone 5.1 (Milestone 5.2, sezioni 17-31).
///
/// Selezione greedy deterministica in tre fasi, mai backtracking
/// esponenziale (sezione 31):
///
/// - **Fase A — copertura obbligatoria**: per ogni
///   [ForgeCoverageRequirement] di [ForgeWorkoutTypeCoveragePolicy], sceglie
///   i migliori candidati non ancora selezionati finché il requisito non è
///   soddisfatto (o il pool per quella categoria si esaurisce — il
///   requisito resta "missing", mai un'eccezione).
/// - **Fase B — riempimento**: aggiunge il miglior candidato rimanente per
///   [ForgeSelectionScore], rispettando [ForgeEngineConfig.maxExercisesPerCategory]
///   (soft: filtro reale qui, ma non nella Fase C) e la finestra di durata
///   `targetSeconds * (1 + planDurationTolerance)`, finché non si raggiunge
///   [ForgeEngineConfig.maximumExercises] o non restano candidati validi.
/// - **Fase C — fallback limitato**: se restano sotto
///   `max(minimumExercises, numero requisiti)`, rilassa il vincolo di
///   categoria e la finestra di durata e aggiunge i migliori candidati
///   rimanenti finché il minimo non è raggiunto o il pool si esaurisce
///   davvero.
///
/// Non duplica mai un esercizio (ogni candidato lascia il pool non appena
/// selezionato) e non modifica mai [ForgeScore] (Milestone 5.1): la
/// selezione contestuale usa solo [ForgeSelectionScore], che lo racchiude
/// senza sostituirlo (sezione 29).
class ForgeWorkoutComposer {
  const ForgeWorkoutComposer({
    this.parameterPolicy = const ForgeExerciseParameterPolicy(),
    this.config = const ForgeEngineConfig(),
  });

  final ForgeExerciseParameterPolicy parameterPolicy;
  final ForgeEngineConfig config;

  /// Pesi di aggiustamento della [ForgeSelectionScore] — costanti
  /// dell'algoritmo di composizione, non dati di catalogo: non violano il
  /// divieto di inventare dati del catalogo (STOP condition), sono solo la
  /// forza relativa di bonus/penalità di selezione.
  static const double _coverageBonusWeight = 0.1;
  static const double _redundancyPenaltyPerSharedMuscle = 0.05;
  static const double _maxRemainingBudgetPenalty = 0.3;

  GeneratedWorkoutPlan compose(ForgeEvaluationResult evaluation) {
    final request = evaluation.normalizedRequest;
    final workoutType = request.workoutType;
    final targetSeconds = request.targetDurationMinutes * 60;
    final windowMaxSeconds =
        (targetSeconds * (1 + config.planDurationTolerance)).round();
    final windowMinSeconds =
        (targetSeconds * (1 - config.planDurationTolerance)).round();

    final pool = List<ForgeExerciseEvaluation>.of(evaluation.eligible);
    final selected = <_Selection>[];

    final requirements = ForgeWorkoutTypeCoveragePolicy.requiredCoverageFor(
      workoutType,
    );
    final covered = <ForgeCoverageRequirement>[];
    final missing = <ForgeCoverageRequirement>[];

    // Fase A — copertura obbligatoria, priorità sulla durata.
    for (final requirement in requirements) {
      while (_countMatching(requirement, selected) < requirement.minCount) {
        final matching = pool
            .where((e) => requirement.matchesCategory(e.candidate.categoryCode))
            .toList();
        if (matching.isEmpty) break;
        final chosen = _pickBest(
          matching,
          selected,
          remainingBudgetSeconds: null,
        );
        pool.remove(chosen);
        selected.add(
          _Selection(chosen, [
            ForgeCompositionReason(
              code: ForgeCompositionReasonCode.selectedForCoverage,
              detail: requirement.categoryCodes.join('/'),
            ),
          ]),
        );
      }
      if (_countMatching(requirement, selected) >= requirement.minCount) {
        covered.add(requirement);
      } else {
        missing.add(requirement);
      }
    }

    // Fase B — riempimento entro la finestra di durata e il tetto per
    // categoria.
    while (selected.length < config.maximumExercises) {
      final remainingBudget =
          windowMaxSeconds -
          _totalSeconds(selected) -
          _transitionCostForNext(selected);
      final survivors = pool.where((e) {
        final categoryCount = selected
            .where(
              (s) =>
                  s.evaluation.candidate.categoryCode ==
                  e.candidate.categoryCode,
            )
            .length;
        if (categoryCount >= config.maxExercisesPerCategory) return false;
        return e.estimatedDurationSeconds! <= remainingBudget;
      }).toList();
      if (survivors.isEmpty) break;
      final chosen = _pickBest(
        survivors,
        selected,
        remainingBudgetSeconds: remainingBudget,
      );
      pool.remove(chosen);
      selected.add(
        _Selection(chosen, _fillReasons(chosen, selected, remainingBudget)),
      );
    }

    // Fase C — fallback limitato e deterministico (mai esponenziale): solo
    // per raggiungere il minimo, nessun altro obiettivo.
    final floor = math.max(config.minimumExercises, requirements.length);
    var usedFallback = false;
    while (selected.length < floor && pool.isNotEmpty) {
      final chosen = _pickBest(pool, selected, remainingBudgetSeconds: null);
      pool.remove(chosen);
      selected.add(
        _Selection(chosen, [
          const ForgeCompositionReason(
            code: ForgeCompositionReasonCode.minimumExerciseFallback,
          ),
        ]),
      );
      usedFallback = true;
    }

    final ordered = ForgeExerciseOrderingPolicy.order(
      evaluations: selected.map((s) => s.evaluation).toList(),
      workoutType: workoutType,
    );
    final reasonsByEvaluation = {
      for (final s in selected) s.evaluation: s.reasons,
    };

    final exercises = <GeneratedWorkoutExercise>[];
    for (var i = 0; i < ordered.length; i++) {
      final evaluationEntry = ordered[i];
      exercises.add(
        GeneratedWorkoutExercise(
          workoutExercise: parameterPolicy.parametersFor(
            exercise: evaluationEntry.candidate.exercise,
            order: i + 1,
          ),
          exercise: evaluationEntry.candidate.exercise,
          estimatedDurationSeconds: evaluationEntry.estimatedDurationSeconds!,
          score: evaluationEntry.score!,
          decisionReasons: reasonsByEvaluation[evaluationEntry] ?? const [],
        ),
      );
    }

    final totalSeconds = _totalDurationOf(exercises);
    final categoryCounts = <String, int>{};
    for (final s in selected) {
      final code = s.evaluation.candidate.categoryCode;
      categoryCounts[code] = (categoryCounts[code] ?? 0) + 1;
    }
    final coverageState = ForgeCoverageState(
      covered: covered,
      missing: missing,
      categoryCounts: categoryCounts,
    );

    final warnings = <ForgeGenerationWarning>[
      if (totalSeconds < windowMinSeconds)
        ForgeGenerationWarning.durationBelowTarget,
      if (totalSeconds > windowMaxSeconds)
        ForgeGenerationWarning.durationAboveTarget,
      if (_hasUncoveredPreferredCategory(workoutType, categoryCounts))
        ForgeGenerationWarning.missingPreferredCoverage,
      if (pool.isEmpty && selected.length < config.maximumExercises)
        ForgeGenerationWarning.limitedExercisePool,
      if (usedFallback) ForgeGenerationWarning.minimumExerciseFallback,
    ];

    final decisionReasons = <ForgeCompositionReason>[
      missing.isEmpty
          ? const ForgeCompositionReason(
              code: ForgeCompositionReasonCode.coverageSatisfied,
            )
          : ForgeCompositionReason(
              code: ForgeCompositionReasonCode.partialCoverage,
              detail: missing.map((r) => r.categoryCodes.join('/')).join('; '),
            ),
      if (totalSeconds < windowMinSeconds)
        const ForgeCompositionReason(
          code: ForgeCompositionReasonCode.belowDurationTarget,
        )
      else if (totalSeconds > windowMaxSeconds)
        const ForgeCompositionReason(
          code: ForgeCompositionReasonCode.aboveDurationTarget,
        )
      else
        const ForgeCompositionReason(
          code: ForgeCompositionReasonCode.withinDurationTarget,
        ),
      const ForgeCompositionReason(
        code: ForgeCompositionReasonCode.usedOnlyAvailableEquipment,
      ),
    ];

    final isComplete =
        coverageState.isFullyCovered &&
        exercises.length >= floor &&
        totalSeconds <= windowMaxSeconds;

    return GeneratedWorkoutPlan(
      request: request,
      workoutType: workoutType,
      targetDurationMinutes: request.targetDurationMinutes,
      estimatedDurationSeconds: totalSeconds,
      exercises: exercises,
      warnings: warnings,
      decisionReasons: decisionReasons,
      isComplete: isComplete,
    );
  }

  int _countMatching(
    ForgeCoverageRequirement requirement,
    List<_Selection> selected,
  ) => selected
      .where(
        (s) => requirement.matchesCategory(s.evaluation.candidate.categoryCode),
      )
      .length;

  int _totalSeconds(List<_Selection> selected) {
    if (selected.isEmpty) return 0;
    final durations = selected
        .map((s) => s.evaluation.estimatedDurationSeconds!)
        .fold<int>(0, (a, b) => a + b);
    return durations +
        (selected.length - 1) * config.transitionSecondsBetweenExercises;
  }

  int _transitionCostForNext(List<_Selection> selected) =>
      selected.isEmpty ? 0 : config.transitionSecondsBetweenExercises;

  int _totalDurationOf(List<GeneratedWorkoutExercise> exercises) {
    if (exercises.isEmpty) return 0;
    final durations = exercises
        .map((e) => e.estimatedDurationSeconds)
        .fold<int>(0, (a, b) => a + b);
    return durations +
        (exercises.length - 1) * config.transitionSecondsBetweenExercises;
  }

  bool _hasUncoveredPreferredCategory(
    WorkoutType workoutType,
    Map<String, int> categoryCounts,
  ) {
    final preferred = ForgeWorkoutTypeCoveragePolicy.preferredCategoriesFor(
      workoutType,
    );
    return preferred.any((code) => (categoryCounts[code] ?? 0) == 0);
  }

  List<ForgeCompositionReason> _fillReasons(
    ForgeExerciseEvaluation chosen,
    List<_Selection> selectedSoFar,
    int remainingBudget,
  ) {
    final score = _selectionScoreFor(chosen, selectedSoFar, remainingBudget);
    final reasons = <ForgeCompositionReason>[
      const ForgeCompositionReason(
        code: ForgeCompositionReasonCode.highBaseScore,
      ),
    ];
    if (score.remainingBudgetPenalty == 0) {
      reasons.add(
        const ForgeCompositionReason(
          code: ForgeCompositionReasonCode.goodDurationFit,
        ),
      );
    }
    if (score.redundancyPenalty == 0 && selectedSoFar.isNotEmpty) {
      reasons.add(
        const ForgeCompositionReason(
          code: ForgeCompositionReasonCode.reducedRedundancy,
        ),
      );
    }
    return reasons;
  }

  ForgeExerciseEvaluation _pickBest(
    List<ForgeExerciseEvaluation> candidates,
    List<_Selection> selectedSoFar, {
    required int? remainingBudgetSeconds,
  }) {
    final ranked = candidates
        .map(
          (c) => (
            evaluation: c,
            score: _selectionScoreFor(c, selectedSoFar, remainingBudgetSeconds),
          ),
        )
        .toList();
    ranked.sort((a, b) {
      final scoreComparison = b.score.total.compareTo(a.score.total);
      if (scoreComparison != 0) return scoreComparison;
      return a.evaluation.candidate.exercise.code.compareTo(
        b.evaluation.candidate.exercise.code,
      );
    });
    return ranked.first.evaluation;
  }

  ForgeSelectionScore _selectionScoreFor(
    ForgeExerciseEvaluation candidate,
    List<_Selection> selectedSoFar,
    int? remainingBudgetSeconds,
  ) {
    final baseScore = candidate.score!.total;
    final categoryAlreadyPresent = selectedSoFar.any(
      (s) =>
          s.evaluation.candidate.categoryCode ==
          candidate.candidate.categoryCode,
    );
    final coverageBonus = categoryAlreadyPresent ? 0.0 : _coverageBonusWeight;
    final sharedMuscleSelections = selectedSoFar
        .where(
          (s) => s.evaluation.candidate.primaryMuscleCodes
              .intersection(candidate.candidate.primaryMuscleCodes)
              .isNotEmpty,
        )
        .length;
    final redundancyPenalty =
        sharedMuscleSelections * _redundancyPenaltyPerSharedMuscle;
    double remainingBudgetPenalty = 0.0;
    if (remainingBudgetSeconds != null) {
      final duration = candidate.estimatedDurationSeconds!;
      final overshoot = duration - remainingBudgetSeconds;
      if (overshoot > 0) {
        remainingBudgetPenalty =
            (overshoot / duration).clamp(0.0, 1.0) * _maxRemainingBudgetPenalty;
      }
    }
    return ForgeSelectionScore(
      baseScore: baseScore,
      coverageBonus: coverageBonus,
      redundancyPenalty: redundancyPenalty,
      remainingBudgetPenalty: remainingBudgetPenalty,
    );
  }
}
