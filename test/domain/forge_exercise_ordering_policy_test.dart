import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_exercise_ordering_policy.dart';

import 'forge_fixtures.dart';

void main() {
  test(
    'ordina per rango di categoria (mobilità prima di core in fullBody)',
    () {
      final mobility = buildEvaluation(
        exercise: buildExercise(id: 1, code: 'M-001'),
        categoryCode: 'MOBILITA',
        scoreTotal: 0.5,
        estimatedDurationSeconds: 30,
      );
      final core = buildEvaluation(
        exercise: buildExercise(id: 2, code: 'C-001'),
        categoryCode: 'CORE',
        scoreTotal: 0.9,
        estimatedDurationSeconds: 30,
      );

      final ordered = ForgeExerciseOrderingPolicy.order(
        evaluations: [core, mobility],
        workoutType: WorkoutType.fullBody,
      );

      expect(ordered.map((e) => e.candidate.exercise.code).toList(), [
        'M-001',
        'C-001',
      ]);
    },
  );

  test(
    'a parità di rango di categoria, tie-break su exercise.code crescente',
    () {
      final z = buildEvaluation(
        exercise: buildExercise(id: 1, code: 'CORE-Z'),
        categoryCode: 'CORE',
        scoreTotal: 0.9,
        estimatedDurationSeconds: 30,
      );
      final a = buildEvaluation(
        exercise: buildExercise(id: 2, code: 'CORE-A'),
        categoryCode: 'CORE',
        scoreTotal: 0.1,
        estimatedDurationSeconds: 30,
      );

      final ordered = ForgeExerciseOrderingPolicy.order(
        evaluations: [z, a],
        workoutType: WorkoutType.fullBody,
      );

      expect(ordered.map((e) => e.candidate.exercise.code).toList(), [
        'CORE-A',
        'CORE-Z',
      ]);
    },
  );

  test('CUSTOM non è generabile: order lancia', () {
    expect(
      () => ForgeExerciseOrderingPolicy.order(
        evaluations: const [],
        workoutType: WorkoutType.custom,
      ),
      throwsArgumentError,
    );
  });
}
