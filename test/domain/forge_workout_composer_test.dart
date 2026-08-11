import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_composition_reason.dart';
import 'package:forge/domain/entities/forge_engine_config.dart';
import 'package:forge/domain/entities/forge_evaluation_result.dart';
import 'package:forge/domain/entities/forge_exercise_evaluation.dart';
import 'package:forge/domain/entities/forge_generation_warning.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_workout_composer.dart';

import 'forge_fixtures.dart';

ForgeRequest _request({
  int userLevel = 2,
  Set<String> equipment = const {},
  int targetDurationMinutes = 30,
  WorkoutType workoutType = WorkoutType.fullBody,
}) {
  return ForgeRequest(
    profileId: 1,
    userLevel: userLevel,
    availableEquipmentCodes: equipment,
    targetDurationMinutes: targetDurationMinutes,
    workoutType: workoutType,
  );
}

ForgeEvaluationResult _evaluationOf(
  List<ForgeExerciseEvaluation> eligible, {
  WorkoutType workoutType = WorkoutType.fullBody,
  int targetDurationMinutes = 30,
}) {
  return ForgeEvaluationResult(
    normalizedRequest: _request(
      workoutType: workoutType,
      targetDurationMinutes: targetDurationMinutes,
    ),
    eligible: eligible,
    excluded: const [],
  );
}

/// Un candidato "generico" per categoria/durata/punteggio, per popolare i
/// requisiti di copertura senza dover ripetere sempre gli stessi campi.
ForgeExerciseEvaluation _candidate({
  required String code,
  required String categoryCode,
  double score = 0.5,
  int durationSeconds = 60,
  Set<String> muscles = const {},
}) {
  return buildEvaluation(
    exercise: buildExercise(id: code.hashCode, code: code),
    categoryCode: categoryCode,
    primaryMuscleCodes: muscles,
    scoreTotal: score,
    estimatedDurationSeconds: durationSeconds,
  );
}

/// Pool minimo che soddisfa la copertura obbligatoria di fullBody
/// (GAMBE_GLUTEI, un upper-body, CORE) con margine per la Fase B.
List<ForgeExerciseEvaluation> _fullBodyPool() {
  return [
    _candidate(code: 'LEG-1', categoryCode: 'GAMBE_GLUTEI', score: 0.9),
    _candidate(code: 'LEG-2', categoryCode: 'GAMBE_GLUTEI', score: 0.6),
    _candidate(code: 'UPPER-1', categoryCode: 'PETTO_SPINTA', score: 0.85),
    _candidate(code: 'UPPER-2', categoryCode: 'SCHIENA', score: 0.6),
    _candidate(code: 'CORE-1', categoryCode: 'CORE', score: 0.8),
    _candidate(code: 'CORE-2', categoryCode: 'CORE', score: 0.5),
    _candidate(code: 'MOB-1', categoryCode: 'MOBILITA', score: 0.4),
  ];
}

void main() {
  const composer = ForgeWorkoutComposer();

  test(
    'copertura obbligatoria soddisfatta -> isComplete, coverageSatisfied',
    () {
      final plan = composer.compose(_evaluationOf(_fullBodyPool()));

      expect(plan.isComplete, isTrue);
      expect(
        plan.decisionReasons.map((r) => r.code),
        contains(ForgeCompositionReasonCode.coverageSatisfied),
      );
      expect(
        plan.decisionReasons.map((r) => r.code),
        isNot(contains(ForgeCompositionReasonCode.partialCoverage)),
      );
    },
  );

  test('copertura obbligatoria mancante (nessun candidato per la categoria '
      'richiesta) -> partialCoverage, isComplete false', () {
    final pool = [
      _candidate(code: 'CORE-1', categoryCode: 'CORE', score: 0.8),
      _candidate(code: 'CORE-2', categoryCode: 'CORE', score: 0.6),
      _candidate(code: 'CORE-3', categoryCode: 'CORE', score: 0.4),
    ];

    final plan = composer.compose(_evaluationOf(pool));

    expect(plan.isComplete, isFalse);
    expect(
      plan.decisionReasons.map((r) => r.code),
      contains(ForgeCompositionReasonCode.partialCoverage),
    );
  });

  test('nessun esercizio duplicato nel piano finale', () {
    final plan = composer.compose(_evaluationOf(_fullBodyPool()));

    final codes = plan.exercises.map((e) => e.exercise.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('rispetta maxExercisesPerCategory in Fase B (soft, ma reale)', () {
    final pool = [
      _candidate(code: 'LEG-1', categoryCode: 'GAMBE_GLUTEI', score: 0.9),
      _candidate(code: 'UPPER-1', categoryCode: 'PETTO_SPINTA', score: 0.9),
      _candidate(code: 'CORE-1', categoryCode: 'CORE', score: 0.95),
      _candidate(code: 'CORE-2', categoryCode: 'CORE', score: 0.9),
      _candidate(code: 'CORE-3', categoryCode: 'CORE', score: 0.85),
      _candidate(code: 'CORE-4', categoryCode: 'CORE', score: 0.8),
      _candidate(code: 'CORE-5', categoryCode: 'CORE', score: 0.75),
    ];
    const config = ForgeEngineConfig(
      maxExercisesPerCategory: 2,
      maximumExercises: 8,
    );
    final plan = ForgeWorkoutComposer(
      config: config,
    ).compose(_evaluationOf(pool));

    final coreCount = plan.exercises
        .where((e) => e.exercise.code.startsWith('CORE'))
        .length;
    expect(coreCount, lessThanOrEqualTo(2));
  });

  test(
    'durata entro target -> withinDurationTarget, nessun warning di durata',
    () {
      // 5 esercizi da 60s + 4 transizioni di 10s = 340s, target 6 minuti
      // (360s) con tolleranza 15% -> finestra [306, 414]: dentro.
      final pool = _fullBodyPool();
      const config = ForgeEngineConfig(
        maximumExercises: 5,
        minimumExercises: 3,
      );
      final plan = ForgeWorkoutComposer(
        config: config,
      ).compose(_evaluationOf(pool, targetDurationMinutes: 6));

      expect(
        plan.warnings,
        isNot(contains(ForgeGenerationWarning.durationBelowTarget)),
      );
      expect(
        plan.warnings,
        isNot(contains(ForgeGenerationWarning.durationAboveTarget)),
      );
      expect(
        plan.decisionReasons.map((r) => r.code),
        contains(ForgeCompositionReasonCode.withinDurationTarget),
      );
    },
  );

  test(
    'pool con esercizi troppo lunghi per il target -> durationBelowTarget',
    () {
      final pool = [
        _candidate(
          code: 'LEG-1',
          categoryCode: 'GAMBE_GLUTEI',
          durationSeconds: 20,
        ),
        _candidate(
          code: 'UPPER-1',
          categoryCode: 'PETTO_SPINTA',
          durationSeconds: 20,
        ),
        _candidate(code: 'CORE-1', categoryCode: 'CORE', durationSeconds: 20),
      ];
      const config = ForgeEngineConfig(
        minimumExercises: 3,
        maximumExercises: 3,
      );
      final plan = ForgeWorkoutComposer(
        config: config,
      ).compose(_evaluationOf(pool, targetDurationMinutes: 30));

      expect(
        plan.warnings,
        contains(ForgeGenerationWarning.durationBelowTarget),
      );
      expect(
        plan.decisionReasons.map((r) => r.code),
        contains(ForgeCompositionReasonCode.belowDurationTarget),
      );
    },
  );

  test('pool insufficiente per il minimo -> fallback e warning dedicato', () {
    final pool = [
      _candidate(code: 'LEG-1', categoryCode: 'GAMBE_GLUTEI'),
      _candidate(code: 'UPPER-1', categoryCode: 'PETTO_SPINTA'),
      _candidate(code: 'CORE-1', categoryCode: 'CORE'),
    ];
    const config = ForgeEngineConfig(minimumExercises: 5, maximumExercises: 8);
    final plan = ForgeWorkoutComposer(
      config: config,
    ).compose(_evaluationOf(pool));

    // Solo 3 candidati disponibili in tutto: il minimo di 5 non è
    // raggiungibile, ma il fallback deve comunque essere stato tentato.
    expect(plan.exercises.length, 3);
    expect(plan.warnings, contains(ForgeGenerationWarning.limitedExercisePool));
  });

  test('a parità di punteggio contestuale, preferisce ridurre la ridondanza '
      'muscolare (nessuna sovrapposizione di muscoli primari)', () {
    // GAMBE_GLUTEI viene coperto per primo (Fase A, primo requisito di
    // fullBody): SEED entra nella selezione prima che OVERLAP/DISTINCT
    // vengano confrontati per il requisito upper-body successivo.
    final seed = _candidate(
      code: 'SEED',
      categoryCode: 'GAMBE_GLUTEI',
      score: 0.9,
      muscles: {'FLESSORI_ANCA'},
    );
    final overlapping = _candidate(
      code: 'OVERLAP',
      categoryCode: 'SCHIENA',
      score: 0.5,
      muscles: {'FLESSORI_ANCA'},
    );
    final distinct = _candidate(
      code: 'DISTINCT',
      categoryCode: 'SCHIENA',
      score: 0.5,
      muscles: {'LOMBARI'},
    );
    final coreFiller = _candidate(
      code: 'CORE-FILLER',
      categoryCode: 'CORE',
      score: 0.5,
    );
    final pool = [seed, overlapping, distinct, coreFiller];
    const config = ForgeEngineConfig(minimumExercises: 3, maximumExercises: 3);

    final plan = ForgeWorkoutComposer(
      config: config,
    ).compose(_evaluationOf(pool));

    final codes = plan.exercises.map((e) => e.exercise.code).toSet();
    expect(codes, contains('DISTINCT'));
    expect(codes, isNot(contains('OVERLAP')));
  });

  test('determinismo: stesso input eseguito più volte -> stesso piano', () {
    final pool = _fullBodyPool();
    final evaluation = _evaluationOf(pool);

    final first = composer.compose(evaluation);
    final second = composer.compose(evaluation);

    expect(
      first.exercises.map((e) => e.exercise.code).toList(),
      second.exercises.map((e) => e.exercise.code).toList(),
    );
    expect(first.estimatedDurationSeconds, second.estimatedDurationSeconds);
  });

  test('ordine del pool di input diverso -> stesso piano finale', () {
    final pool = _fullBodyPool();
    final shuffled = [
      pool[4],
      pool[1],
      pool[6],
      pool[0],
      pool[3],
      pool[2],
      pool[5],
    ];

    final fromOriginal = composer.compose(_evaluationOf(pool));
    final fromShuffled = composer.compose(_evaluationOf(shuffled));

    expect(
      fromOriginal.exercises.map((e) => e.exercise.code).toSet(),
      fromShuffled.exercises.map((e) => e.exercise.code).toSet(),
    );
  });

  test(
    '100 esecuzioni ripetute sullo stesso input -> stesso risultato ogni volta',
    () {
      final evaluation = _evaluationOf(_fullBodyPool());
      final reference = composer
          .compose(evaluation)
          .exercises
          .map((e) => e.exercise.code)
          .toList();

      for (var i = 0; i < 100; i++) {
        final result = composer
            .compose(evaluation)
            .exercises
            .map((e) => e.exercise.code)
            .toList();
        expect(result, reference);
      }
    },
  );

  test(
    'ogni WorkoutType supportato produce un piano eseguibile su un pool ricco',
    () {
      final richPool = [
        ..._fullBodyPool(),
        _candidate(code: 'CARDIO-1', categoryCode: 'CARDIO', score: 0.7),
        _candidate(code: 'CARDIO-2', categoryCode: 'CARDIO', score: 0.5),
        _candidate(code: 'STRETCH-1', categoryCode: 'STRETCHING', score: 0.6),
        _candidate(code: 'EQ-1', categoryCode: 'EQUILIBRIO', score: 0.5),
      ];
      for (final type in WorkoutType.values) {
        if (type == WorkoutType.custom) continue;
        final plan = composer.compose(
          _evaluationOf(richPool, workoutType: type),
        );
        expect(plan.exercises, isNotEmpty, reason: '$type');
        expect(plan.workoutType, type);
      }
    },
  );
}
