import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/services/workout_exercise_factory.dart';

Exercise _exercise({
  int? defaultSets,
  int? defaultReps,
  int? defaultDurationSeconds,
  int? defaultRestSeconds,
}) {
  return Exercise(
    id: 42,
    code: 'X-001',
    name: 'Esercizio',
    description: 'desc',
    instructions: 'istr',
    categoryId: 1,
    minimumLevel: 1,
    impactLevel: ExerciseImpactLevel.low,
    balanceRequired: false,
    floorRequired: false,
    standingRequired: false,
    supportAllowed: false,
    defaultSets: defaultSets,
    defaultReps: defaultReps,
    defaultDurationSeconds: defaultDurationSeconds,
    defaultRestSeconds: defaultRestSeconds,
    isSystem: true,
    isActive: true,
    catalogVersion: 1,
  );
}

void main() {
  const factory = WorkoutExerciseFactory();

  test(
    'esercizio a ripetizioni: riporta i default del catalogo, durata resta null',
    () {
      final exercise = _exercise(
        defaultSets: 2,
        defaultReps: 10,
        defaultDurationSeconds: null,
        defaultRestSeconds: 60,
      );

      final result = factory.fromExercise(
        exercise: exercise,
        workoutId: 7,
        order: 1,
      );

      expect(result.workoutId, 7);
      expect(result.exerciseId, 42);
      expect(result.order, 1);
      expect(result.sets, 2);
      expect(result.repetitions, 10);
      expect(result.durationSeconds, isNull);
      expect(result.restSeconds, 60);
      expect(result.id, isNull);
    },
  );

  test(
    'esercizio a tempo: riporta la durata del catalogo, ripetizioni resta null',
    () {
      final exercise = _exercise(
        defaultSets: 3,
        defaultReps: null,
        defaultDurationSeconds: 30,
        defaultRestSeconds: 45,
      );

      final result = factory.fromExercise(
        exercise: exercise,
        workoutId: 7,
        order: 2,
      );

      expect(result.sets, 3);
      expect(result.repetitions, isNull);
      expect(result.durationSeconds, 30);
      expect(result.restSeconds, 45);
    },
  );

  test('nessun default nel catalogo: nessun valore inventato, tutto null', () {
    final exercise = _exercise();

    final result = factory.fromExercise(
      exercise: exercise,
      workoutId: 7,
      order: 3,
    );

    expect(result.sets, isNull);
    expect(result.repetitions, isNull);
    expect(result.durationSeconds, isNull);
    expect(result.restSeconds, isNull);
  });
}
