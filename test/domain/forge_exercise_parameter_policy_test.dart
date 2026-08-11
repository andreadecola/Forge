import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/generated_workout_exercise.dart';
import 'package:forge/domain/services/forge_exercise_parameter_policy.dart';

import 'forge_fixtures.dart';

void main() {
  const policy = ForgeExerciseParameterPolicy();

  test(
    'usa i default del catalogo senza adattamento al livello (sezione 33)',
    () {
      final exercise = buildExercise(
        id: 1,
        code: 'X-001',
        defaultSets: 3,
        defaultReps: 12,
        defaultRestSeconds: 45,
      );

      final workoutExercise = policy.parametersFor(
        exercise: exercise,
        order: 2,
      );

      expect(workoutExercise.sets, 3);
      expect(workoutExercise.repetitions, 12);
      expect(workoutExercise.restSeconds, 45);
      expect(workoutExercise.order, 2);
      expect(
        workoutExercise.workoutId,
        GeneratedWorkoutExercise.placeholderWorkoutId,
      );
      expect(workoutExercise.exerciseId, exercise.id);
    },
  );

  test('nessun default nel catalogo -> nessun valore inventato', () {
    final exercise = buildExercise(id: 2, code: 'CARD-999');

    final workoutExercise = policy.parametersFor(exercise: exercise, order: 1);

    expect(workoutExercise.sets, isNull);
    expect(workoutExercise.repetitions, isNull);
    expect(workoutExercise.durationSeconds, isNull);
  });
}
