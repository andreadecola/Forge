import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_engine_config.dart';
import 'package:forge/domain/entities/forge_score_component.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_scoring_service.dart';

import 'forge_fixtures.dart';

void main() {
  const service = ForgeScoringService();
  const config = ForgeEngineConfig();

  double componentValue(dynamic score, ForgeScoreComponentType type) {
    return score.components.firstWhere((c) => c.type == type).value as double;
  }

  test('workoutTypeMatch: una categoria preferita per il tipo ottiene un '
      'punteggio più alto di una scoraggiata (sezione 64)', () {
    final preferred = service.score(
      candidate: buildCandidate(
        exercise: buildExercise(defaultReps: 10),
        categoryCode: 'GAMBE_GLUTEI',
      ),
      workoutType: WorkoutType.lowerBody,
      userLevel: 1,
      estimatedDurationSeconds: 60,
      targetDurationMinutes: 30,
      config: config,
    );
    final discouraged = service.score(
      candidate: buildCandidate(
        exercise: buildExercise(defaultReps: 10),
        categoryCode: 'BRACCIA',
      ),
      workoutType: WorkoutType.lowerBody,
      userLevel: 1,
      estimatedDurationSeconds: 60,
      targetDurationMinutes: 30,
      config: config,
    );

    expect(
      componentValue(preferred, ForgeScoreComponentType.workoutTypeMatch),
      greaterThan(
        componentValue(discouraged, ForgeScoreComponentType.workoutTypeMatch),
      ),
    );
  });

  test('levelFit: un esercizio di livello più vicino a quello dell\'utente '
      'ottiene un punteggio più alto (sezione 37/64)', () {
    final close = service.score(
      candidate: buildCandidate(
        exercise: buildExercise(minimumLevel: 3, defaultReps: 10),
      ),
      workoutType: WorkoutType.fullBody,
      userLevel: 3,
      estimatedDurationSeconds: 60,
      targetDurationMinutes: 30,
      config: config,
    );
    final far = service.score(
      candidate: buildCandidate(
        exercise: buildExercise(minimumLevel: 1, defaultReps: 10),
      ),
      workoutType: WorkoutType.fullBody,
      userLevel: 3,
      estimatedDurationSeconds: 60,
      targetDurationMinutes: 30,
      config: config,
    );

    expect(
      componentValue(close, ForgeScoreComponentType.levelFit),
      greaterThan(componentValue(far, ForgeScoreComponentType.levelFit)),
    );
    expect(componentValue(close, ForgeScoreComponentType.levelFit), 1.0);
  });

  test('equipmentSimplicity: meno attrezzatura richiesta -> punteggio più '
      'alto, senza dominare il totale (sezione 38/64)', () {
    final simple = service.score(
      candidate: buildCandidate(exercise: buildExercise(defaultReps: 10)),
      workoutType: WorkoutType.fullBody,
      userLevel: 1,
      estimatedDurationSeconds: 60,
      targetDurationMinutes: 30,
      config: config,
    );
    final complex = service.score(
      candidate: buildCandidate(
        exercise: buildExercise(defaultReps: 10),
        requiredEquipmentCodes: {'BAND', 'DUMBBELL'},
      ),
      workoutType: WorkoutType.fullBody,
      userLevel: 1,
      estimatedDurationSeconds: 60,
      targetDurationMinutes: 30,
      config: config,
    );

    expect(
      componentValue(simple, ForgeScoreComponentType.equipmentSimplicity),
      greaterThan(
        componentValue(complex, ForgeScoreComponentType.equipmentSimplicity),
      ),
    );
    expect(
      config.componentWeights[ForgeScoreComponentType.equipmentSimplicity],
      lessThan(
        config.componentWeights[ForgeScoreComponentType.workoutTypeMatch]!,
      ),
    );
  });

  test('NONE non conta come attrezzatura per equipmentSimplicity', () {
    final withNone = service.score(
      candidate: buildCandidate(
        exercise: buildExercise(defaultReps: 10),
        requiredEquipmentCodes: {'NONE'},
      ),
      workoutType: WorkoutType.fullBody,
      userLevel: 1,
      estimatedDurationSeconds: 60,
      targetDurationMinutes: 30,
      config: config,
    );

    expect(
      componentValue(withNone, ForgeScoreComponentType.equipmentSimplicity),
      1.0,
    );
  });

  test('durationFit: dentro la tolleranza -> punteggio massimo; molto oltre '
      'il budget -> punteggio più basso (sezione 39/64)', () {
    final withinBudget = service.score(
      candidate: buildCandidate(exercise: buildExercise(defaultReps: 10)),
      workoutType: WorkoutType.fullBody,
      userLevel: 1,
      estimatedDurationSeconds: 5 * 60, // 5 min su 30 -> ratio 0.17
      targetDurationMinutes: 30,
      config: config,
    );
    final overBudget = service.score(
      candidate: buildCandidate(exercise: buildExercise(defaultReps: 10)),
      workoutType: WorkoutType.fullBody,
      userLevel: 1,
      estimatedDurationSeconds: 30 * 60, // uguale all'intera durata target
      targetDurationMinutes: 30,
      config: config,
    );

    expect(
      componentValue(withinBudget, ForgeScoreComponentType.durationFit),
      1.0,
    );
    expect(
      componentValue(withinBudget, ForgeScoreComponentType.durationFit),
      greaterThan(
        componentValue(overBudget, ForgeScoreComponentType.durationFit),
      ),
    );
  });

  test('total è la somma pesata dei componenti (0.0..1.0)', () {
    final score = service.score(
      candidate: buildCandidate(exercise: buildExercise(defaultReps: 10)),
      workoutType: WorkoutType.fullBody,
      userLevel: 1,
      estimatedDurationSeconds: 60,
      targetDurationMinutes: 30,
      config: config,
    );

    final expectedTotal = score.components.fold<double>(
      0.0,
      (sum, c) => sum + c.value * config.componentWeights[c.type]!,
    );
    expect(score.total, expectedTotal);
    expect(score.total, inInclusiveRange(0.0, 1.0));
    expect(score.reasons, hasLength(4));
  });
}
