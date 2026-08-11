import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/exercise_alternative.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/entities/exercise_progression.dart';
import 'package:forge/domain/entities/forge_adaptation_decision.dart';
import 'package:forge/domain/entities/forge_adaptation_reason.dart';
import 'package:forge/domain/entities/forge_engine_config.dart';
import 'package:forge/domain/entities/forge_exercise_adaptation_action.dart';
import 'package:forge/domain/entities/forge_exercise_history.dart';
import 'package:forge/domain/services/forge_exercise_adaptation_policy.dart';

import 'forge_fixtures.dart';

ExerciseProgression _progression(int targetId, {String targetCode = 'B-001'}) {
  return ExerciseProgression(
    id: 1,
    type: ExerciseProgressionType.ripetizioni,
    minimumLevel: 1,
    priority: 1,
    target: buildExercise(id: targetId, code: targetCode),
  );
}

ExerciseAlternative _alternative(int targetId, {String targetCode = 'C-001'}) {
  return ExerciseAlternative(
    id: 1,
    reason: ExerciseAlternativeReason.attrezzatura,
    priority: 1,
    target: buildExercise(id: targetId, code: targetCode),
  );
}

ForgeExerciseHistory _history({
  int timesCompleted = 3,
  int timesSkipped = 0,
  int completedSets = 9,
  int plannedSets = 9,
  int timesPlanned = 3,
}) {
  return ForgeExerciseHistory(
    exerciseId: 1,
    timesPlanned: timesPlanned,
    timesCompleted: timesCompleted,
    timesSkipped: timesSkipped,
    completedSets: completedSets,
    plannedSets: plannedSets,
  );
}

void main() {
  const policy = ForgeExerciseAdaptationPolicy();
  const config = ForgeEngineConfig();
  final source = buildExercise(id: 1, code: 'A-001');

  test('globalDecision maintain -> sempre keep, indipendentemente dallo '
      'storico o dalle relazioni disponibili', () {
    final decision = policy.decide(
      sourceExercise: source,
      history: _history(),
      progressions: [_progression(2)],
      regressions: const [],
      alternatives: const [],
      eligibleExerciseIds: {2},
      exerciseIdsAlreadyInPlan: {1},
      globalDecision: ForgeAdaptationDecision.maintain,
      config: config,
    );

    expect(decision.action, ForgeExerciseAdaptationAction.keep);
  });

  group('progress', () {
    test('progressione esplicita disponibile ed eleggibile -> progress '
        '(sezione 21)', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(),
        progressions: [_progression(2)],
        regressions: const [],
        alternatives: const [],
        eligibleExerciseIds: {2},
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.progress,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.progress);
      expect(decision.targetExerciseId, 2);
      expect(
        decision.reasons,
        contains(ForgeAdaptationReason.explicitProgressionAvailable),
      );
    });

    test('progressione esplicita richiede attrezzatura non posseduta '
        '(non eleggibile) -> keep (sezione 57)', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(),
        progressions: [_progression(2)],
        regressions: const [],
        alternatives: const [],
        eligibleExerciseIds: const {}, // 2 non è eleggibile
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.progress,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.keep);
    });

    test('progressione con minimumLevel > userLevel corrente non è '
        'eleggibile -> keep (sezione 58, guardia applicata a monte '
        'tramite eligibleExerciseIds)', () {
      // La guardia di livello è già decisa da ForgeEligibilityService
      // (Milestone 5.1) per la richiesta corrente: qui si verifica solo
      // che la policy non bypassi mai eligibleExerciseIds.
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(),
        progressions: [_progression(2)],
        regressions: const [],
        alternatives: const [],
        eligibleExerciseIds: const {}, // simula esclusione per livello
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.progress,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.keep);
    });

    test('target già presente nel piano -> nessun duplicato, keep '
        '(sezione 60)', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(),
        progressions: [_progression(2)],
        regressions: const [],
        alternatives: const [],
        eligibleExerciseIds: {2},
        exerciseIdsAlreadyInPlan: {1, 2}, // 2 già nel piano
        globalDecision: ForgeAdaptationDecision.progress,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.keep);
    });

    test('storico insufficiente per questo esercizio -> keep anche se il '
        'contesto globale è progress', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(timesCompleted: 1), // sotto la soglia (default 2)
        progressions: [_progression(2)],
        regressions: const [],
        alternatives: const [],
        eligibleExerciseIds: {2},
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.progress,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.keep);
    });

    test('nessuna progressione esplicita nel catalogo -> keep, mai '
        'inventata (STOP 2)', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(),
        progressions: const [],
        regressions: const [],
        alternatives: const [],
        eligibleExerciseIds: {2},
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.progress,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.keep);
      expect(decision.targetExerciseId, isNull);
    });
  });

  group('simplify', () {
    test('skip ripetuti con regressione esplicita eleggibile -> regress '
        '(sezione 49)', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(timesSkipped: 2),
        progressions: const [],
        regressions: [_progression(3, targetCode: 'REG-001')],
        alternatives: const [],
        eligibleExerciseIds: {3},
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.simplify,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.regress);
      expect(decision.targetExerciseId, 3);
      expect(
        decision.reasons,
        contains(ForgeAdaptationReason.repeatedExerciseSkip),
      );
    });

    test('un singolo skip non basta (sezione 22) -> keep', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(timesSkipped: 1),
        progressions: const [],
        regressions: [_progression(3)],
        alternatives: const [],
        eligibleExerciseIds: {3},
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.simplify,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.keep);
    });

    test('skip ripetuti, nessuna regressione ma alternativa eleggibile '
        '-> replace (sezione 23)', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(timesSkipped: 2),
        progressions: const [],
        regressions: const [],
        alternatives: [_alternative(4)],
        eligibleExerciseIds: {4},
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.simplify,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.replace);
      expect(decision.targetExerciseId, 4);
    });

    test('skip ripetuti, nessuna regressione/alternativa eleggibile o '
        'disponibile -> avoidTemporarily, mai un esercizio inventato '
        '(sezione 50)', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(timesSkipped: 2),
        progressions: const [],
        regressions: const [],
        alternatives: const [],
        eligibleExerciseIds: const {},
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.simplify,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.avoidTemporarily);
      expect(decision.targetExerciseId, isNull);
      expect(
        decision.reasons,
        contains(ForgeAdaptationReason.repeatedExerciseSkip),
      );
    });

    test('completamento serie molto basso (senza skip) -> segnale '
        'sufficiente per regress', () {
      final decision = policy.decide(
        sourceExercise: source,
        history: _history(completedSets: 2, plannedSets: 9), // ~0.22
        progressions: const [],
        regressions: [_progression(3)],
        alternatives: const [],
        eligibleExerciseIds: {3},
        exerciseIdsAlreadyInPlan: {1},
        globalDecision: ForgeAdaptationDecision.simplify,
        config: config,
      );

      expect(decision.action, ForgeExerciseAdaptationAction.regress);
      expect(
        decision.reasons,
        contains(ForgeAdaptationReason.lowSetCompletion),
      );
    });
  });
}
