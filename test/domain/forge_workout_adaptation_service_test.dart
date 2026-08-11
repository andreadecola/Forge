import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/exercise_alternative.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/entities/exercise_progression.dart';
import 'package:forge/domain/entities/forge_adaptation_context.dart';
import 'package:forge/domain/entities/forge_adaptation_decision.dart';
import 'package:forge/domain/entities/forge_composition_reason.dart';
import 'package:forge/domain/entities/forge_evaluation_result.dart';
import 'package:forge/domain/entities/forge_exercise_adaptation_action.dart';
import 'package:forge/domain/entities/forge_exercise_history.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/generated_workout_exercise.dart';
import 'package:forge/domain/entities/generated_workout_plan.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/services/forge_workout_adaptation_service.dart';

import 'forge_fixtures.dart';

ForgeRequest _request({int targetDurationMinutes = 30}) {
  return ForgeRequest(
    profileId: 1,
    userLevel: 2,
    availableEquipmentCodes: const {},
    targetDurationMinutes: targetDurationMinutes,
    workoutType: WorkoutType.fullBody,
  );
}

GeneratedWorkoutExercise _planEntry({
  required int exerciseId,
  required String code,
  int order = 1,
  int? repetitions = 10,
  int estimatedDurationSeconds = 40,
}) {
  return GeneratedWorkoutExercise(
    workoutExercise: WorkoutExercise(
      workoutId: GeneratedWorkoutExercise.placeholderWorkoutId,
      exerciseId: exerciseId,
      order: order,
      repetitions: repetitions,
    ),
    exercise: buildExercise(id: exerciseId, code: code, defaultReps: 10),
    estimatedDurationSeconds: estimatedDurationSeconds,
    score: buildEvaluation(
      exercise: buildExercise(id: exerciseId, code: code),
      scoreTotal: 0.8,
      estimatedDurationSeconds: estimatedDurationSeconds,
    ).score!,
    decisionReasons: const [],
  );
}

GeneratedWorkoutPlan _plan(
  List<GeneratedWorkoutExercise> exercises, {
  int targetDurationMinutes = 30,
}) {
  // Normalizza sempre l'ordine in base alla posizione nella lista: i
  // chiamanti costruiscono ogni voce con `_planEntry` senza doversi
  // preoccupare di passare un `order` coerente a mano.
  final ordered = [
    for (var i = 0; i < exercises.length; i++)
      GeneratedWorkoutExercise(
        workoutExercise: exercises[i].workoutExercise.copyWith(order: i + 1),
        exercise: exercises[i].exercise,
        estimatedDurationSeconds: exercises[i].estimatedDurationSeconds,
        score: exercises[i].score,
        decisionReasons: exercises[i].decisionReasons,
      ),
  ];
  final total =
      ordered.fold<int>(0, (a, e) => a + e.estimatedDurationSeconds) +
      (ordered.length - 1) * 10;
  return GeneratedWorkoutPlan(
    request: _request(targetDurationMinutes: targetDurationMinutes),
    workoutType: WorkoutType.fullBody,
    targetDurationMinutes: targetDurationMinutes,
    estimatedDurationSeconds: total,
    exercises: ordered,
    warnings: const [],
    decisionReasons: const [
      ForgeCompositionReason(
        code: ForgeCompositionReasonCode.coverageSatisfied,
      ),
    ],
    isComplete: true,
  );
}

ForgeEvaluationResult _evaluationWith(
  List<({int id, String code, String category, int duration})> catalog,
) {
  return ForgeEvaluationResult(
    normalizedRequest: _request(),
    eligible: [
      for (final entry in catalog)
        buildEvaluation(
          exercise: buildExercise(
            id: entry.id,
            code: entry.code,
            defaultReps: 10,
          ),
          categoryCode: entry.category,
          scoreTotal: 0.7,
          estimatedDurationSeconds: entry.duration,
        ),
    ],
    excluded: const [],
  );
}

ForgeAdaptationContext _context(
  ForgeAdaptationDecision decision,
  Map<int, ForgeExerciseHistory> history,
) {
  return ForgeAdaptationContext(
    completedSessions: 5,
    abortedSessions: 0,
    recentSessionCount: 5,
    recentCompletionRate: 1.0,
    recentSetCompletionRate: 1.0,
    exerciseHistory: history,
    decision: decision,
    reasons: const [],
  );
}

ForgeExerciseHistory _richHistory(int exerciseId) {
  return ForgeExerciseHistory(
    exerciseId: exerciseId,
    timesPlanned: 4,
    timesCompleted: 4,
    timesSkipped: 0,
    completedSets: 12,
    plannedSets: 12,
  );
}

void main() {
  const service = ForgeWorkoutAdaptationService();

  test('decision maintain -> piano identico, tutte le voci keep', () {
    final plan = _plan([
      _planEntry(exerciseId: 1, code: 'LEG-1'),
      _planEntry(exerciseId: 2, code: 'UPPER-1'),
    ]);
    final evaluation = _evaluationWith([
      (id: 1, code: 'LEG-1', category: 'GAMBE_GLUTEI', duration: 40),
      (id: 2, code: 'UPPER-1', category: 'PETTO_SPINTA', duration: 40),
    ]);

    final adapted = service.adapt(
      plan: plan,
      context: _context(ForgeAdaptationDecision.maintain, const {}),
      evaluation: evaluation,
      progressionsByExerciseId: const {},
      regressionsByExerciseId: const {},
      alternativesByExerciseId: const {},
    );

    expect(
      adapted.plan.estimatedDurationSeconds,
      plan.estimatedDurationSeconds,
    );
    expect(
      adapted.exerciseDecisions.every(
        (d) => d.action == ForgeExerciseAdaptationAction.keep,
      ),
      isTrue,
    );
  });

  test('guardia di durata: aumento parametro sforerebbe la finestra -> '
      'non applicato, nessun cambiamento (sezione 38/56)', () {
    // Target 1 minuto (60s), tolleranza 15% -> finestra max 69s. Due
    // esercizi a 7 ripetizioni (7*4s = 28s ciascuno) + 1 transizione da
    // 10s = 66s: valido, ma già vicino al limite. Un aumento di 1
    // ripetizione (+4s, config default) su uno qualunque dei due porta a
    // 70s > 69s -> deve essere rifiutato per entrambi.
    final plan = _plan([
      _planEntry(
        exerciseId: 1,
        code: 'LEG-1',
        repetitions: 7,
        estimatedDurationSeconds: 28,
      ),
      _planEntry(
        exerciseId: 2,
        code: 'UPPER-1',
        repetitions: 7,
        estimatedDurationSeconds: 28,
      ),
    ], targetDurationMinutes: 1);
    final evaluation = _evaluationWith([
      (id: 1, code: 'LEG-1', category: 'GAMBE_GLUTEI', duration: 28),
      (id: 2, code: 'UPPER-1', category: 'PETTO_SPINTA', duration: 28),
    ]);
    expect(plan.estimatedDurationSeconds, 66);

    final adapted = service.adapt(
      plan: plan,
      context: _context(ForgeAdaptationDecision.progress, {
        1: _richHistory(1),
        2: _richHistory(2),
      }),
      evaluation: evaluation,
      progressionsByExerciseId: const {},
      regressionsByExerciseId: const {},
      alternativesByExerciseId: const {},
    );

    expect(
      adapted.plan.estimatedDurationSeconds,
      66,
      reason: 'nessun aumento applicato',
    );
    for (final decision in adapted.exerciseDecisions) {
      expect(decision.action, ForgeExerciseAdaptationAction.keep);
      expect(decision.reasons, isEmpty);
    }
    expect(
      adapted.plan.exercises.map((e) => e.workoutExercise.repetitions),
      everyElement(7),
    );
  });

  test('guardia di copertura: la sostituzione romperebbe un requisito '
      'obbligatorio prima soddisfatto -> non applicata, avoidTemporarily '
      '(sezione 40/59)', () {
    // fullBody richiede GAMBE_GLUTEI + un esercizio upper-body: LEG-1 è
    // l'unico GAMBE_GLUTEI del piano. La sua regressione porta a un
    // esercizio CORE (non richiesto): applicarla lascerebbe zero
    // GAMBE_GLUTEI -> guardia deve rifiutare.
    final plan = _plan([
      _planEntry(exerciseId: 1, code: 'LEG-1'),
      _planEntry(exerciseId: 2, code: 'UPPER-1'),
      _planEntry(exerciseId: 3, code: 'CORE-1'),
    ]);
    final evaluation = _evaluationWith([
      (id: 1, code: 'LEG-1', category: 'GAMBE_GLUTEI', duration: 40),
      (id: 2, code: 'UPPER-1', category: 'PETTO_SPINTA', duration: 40),
      (id: 3, code: 'CORE-1', category: 'CORE', duration: 40),
      (id: 4, code: 'CORE-REG', category: 'CORE', duration: 40),
    ]);
    final regressions = {
      1: [
        ExerciseProgression(
          id: 1,
          type: ExerciseProgressionType.ripetizioni,
          minimumLevel: 1,
          priority: 1,
          target: buildExercise(id: 4, code: 'CORE-REG'),
        ),
      ],
    };
    final history = {
      1: ForgeExerciseHistory(
        exerciseId: 1,
        timesPlanned: 4,
        timesCompleted: 1,
        timesSkipped: 3,
        completedSets: 4,
        plannedSets: 12,
      ),
    };

    final adapted = service.adapt(
      plan: plan,
      context: _context(ForgeAdaptationDecision.simplify, history),
      evaluation: evaluation,
      progressionsByExerciseId: const {},
      regressionsByExerciseId: regressions,
      alternativesByExerciseId: const {},
    );

    final legDecision = adapted.exerciseDecisions.firstWhere(
      (d) => d.sourceExerciseId == 1,
    );
    expect(legDecision.action, ForgeExerciseAdaptationAction.avoidTemporarily);
    expect(
      adapted.plan.exercises.map((e) => e.exercise.code),
      contains('LEG-1'),
      reason: 'LEG-1 deve restare nel piano, la sostituzione va rifiutata',
    );
  });

  test('sostituzione valida (nessuna guardia violata) viene applicata '
      'nella stessa posizione (sezione 41)', () {
    final plan = _plan([
      _planEntry(exerciseId: 1, code: 'LEG-1'),
      _planEntry(exerciseId: 2, code: 'UPPER-1'),
      _planEntry(exerciseId: 3, code: 'CORE-1'),
    ]);
    final evaluation = _evaluationWith([
      (id: 1, code: 'LEG-1', category: 'GAMBE_GLUTEI', duration: 40),
      (id: 2, code: 'UPPER-1', category: 'PETTO_SPINTA', duration: 40),
      (id: 3, code: 'CORE-1', category: 'CORE', duration: 40),
      (id: 4, code: 'CORE-REG', category: 'CORE', duration: 40),
    ]);
    final regressions = {
      3: [
        ExerciseProgression(
          id: 1,
          type: ExerciseProgressionType.ripetizioni,
          minimumLevel: 1,
          priority: 1,
          target: buildExercise(id: 4, code: 'CORE-REG'),
        ),
      ],
    };
    final history = {
      3: ForgeExerciseHistory(
        exerciseId: 3,
        timesPlanned: 4,
        timesCompleted: 1,
        timesSkipped: 3,
        completedSets: 4,
        plannedSets: 12,
      ),
    };

    final adapted = service.adapt(
      plan: plan,
      context: _context(ForgeAdaptationDecision.simplify, history),
      evaluation: evaluation,
      progressionsByExerciseId: const {},
      regressionsByExerciseId: regressions,
      alternativesByExerciseId: const {},
    );

    expect(adapted.plan.exercises[2].exercise.code, 'CORE-REG');
    expect(adapted.plan.exercises[2].workoutExercise.order, 3);
    expect(adapted.plan.exercises[0].exercise.code, 'LEG-1');
    expect(adapted.plan.exercises[1].exercise.code, 'UPPER-1');
  });

  test('alternativa non eleggibile (attrezzatura mancante) -> non usata, '
      'nessun bypass di eligibility (sezione 39)', () {
    final plan = _plan([
      _planEntry(exerciseId: 1, code: 'LEG-1'),
      _planEntry(exerciseId: 2, code: 'UPPER-1'),
      _planEntry(exerciseId: 3, code: 'CORE-1'),
    ]);
    // L'alternativa (id 5) non è nel catalogo eleggibile (non compare in
    // evaluation.eligible): simula un'attrezzatura mancante già decisa
    // dal motore Milestone 5.1.
    final evaluation = _evaluationWith([
      (id: 1, code: 'LEG-1', category: 'GAMBE_GLUTEI', duration: 40),
      (id: 2, code: 'UPPER-1', category: 'PETTO_SPINTA', duration: 40),
      (id: 3, code: 'CORE-1', category: 'CORE', duration: 40),
    ]);
    final alternatives = {
      3: [
        ExerciseAlternative(
          id: 1,
          reason: ExerciseAlternativeReason.attrezzatura,
          priority: 1,
          target: buildExercise(id: 5, code: 'CORE-ALT'),
        ),
      ],
    };
    final history = {
      3: ForgeExerciseHistory(
        exerciseId: 3,
        timesPlanned: 4,
        timesCompleted: 1,
        timesSkipped: 3,
        completedSets: 4,
        plannedSets: 12,
      ),
    };

    final adapted = service.adapt(
      plan: plan,
      context: _context(ForgeAdaptationDecision.simplify, history),
      evaluation: evaluation,
      progressionsByExerciseId: const {},
      regressionsByExerciseId: const {},
      alternativesByExerciseId: alternatives,
    );

    expect(
      adapted.plan.exercises.map((e) => e.exercise.code),
      contains('CORE-1'),
    );
    expect(
      adapted.plan.exercises.map((e) => e.exercise.code),
      isNot(contains('CORE-ALT')),
    );
  });

  test('determinismo: stesso input adattato più volte -> stesso piano '
      '(sezione 61)', () {
    final plan = _plan([
      _planEntry(exerciseId: 1, code: 'LEG-1'),
      _planEntry(exerciseId: 2, code: 'UPPER-1'),
    ]);
    final evaluation = _evaluationWith([
      (id: 1, code: 'LEG-1', category: 'GAMBE_GLUTEI', duration: 40),
      (id: 2, code: 'UPPER-1', category: 'PETTO_SPINTA', duration: 40),
    ]);
    final context = _context(ForgeAdaptationDecision.progress, {
      1: _richHistory(1),
      2: _richHistory(2),
    });

    final reference = service.adapt(
      plan: plan,
      context: context,
      evaluation: evaluation,
      progressionsByExerciseId: const {},
      regressionsByExerciseId: const {},
      alternativesByExerciseId: const {},
    );

    for (var i = 0; i < 20; i++) {
      final result = service.adapt(
        plan: plan,
        context: context,
        evaluation: evaluation,
        progressionsByExerciseId: const {},
        regressionsByExerciseId: const {},
        alternativesByExerciseId: const {},
      );
      expect(
        result.plan.exercises
            .map((e) => e.workoutExercise.repetitions)
            .toList(),
        reference.plan.exercises
            .map((e) => e.workoutExercise.repetitions)
            .toList(),
      );
      expect(
        result.plan.estimatedDurationSeconds,
        reference.plan.estimatedDurationSeconds,
      );
    }
  });
}
