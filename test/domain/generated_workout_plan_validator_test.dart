import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_composition_reason.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/forge_score.dart';
import 'package:forge/domain/entities/generated_workout_exercise.dart';
import 'package:forge/domain/entities/generated_workout_plan.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/services/generated_workout_plan_validator.dart';

import 'forge_fixtures.dart';

ForgeRequest _request() {
  return const ForgeRequest(
    profileId: 1,
    userLevel: 1,
    availableEquipmentCodes: {},
    targetDurationMinutes: 30,
    workoutType: WorkoutType.fullBody,
  );
}

GeneratedWorkoutExercise _entry({
  required int exerciseId,
  required String code,
  required int order,
  int? repetitions = 10,
  int? restSeconds,
}) {
  final exercise = buildExercise(id: exerciseId, code: code, defaultReps: 10);
  return GeneratedWorkoutExercise(
    workoutExercise: WorkoutExercise(
      workoutId: GeneratedWorkoutExercise.placeholderWorkoutId,
      exerciseId: exerciseId,
      order: order,
      repetitions: repetitions,
      restSeconds: restSeconds,
    ),
    exercise: exercise,
    estimatedDurationSeconds: 40,
    score: const ForgeScore(total: 0.8, components: [], reasons: []),
    decisionReasons: const [],
  );
}

GeneratedWorkoutPlan _plan(List<GeneratedWorkoutExercise> exercises) {
  return GeneratedWorkoutPlan(
    request: _request(),
    workoutType: WorkoutType.fullBody,
    targetDurationMinutes: 30,
    estimatedDurationSeconds: 120,
    exercises: exercises,
    warnings: const [],
    decisionReasons: const [
      ForgeCompositionReason(
        code: ForgeCompositionReasonCode.coverageSatisfied,
      ),
    ],
    isComplete: true,
  );
}

void main() {
  const validator = GeneratedWorkoutPlanValidator();

  test(
    'piano valido (ordine 1..N, nessun duplicato, parametri validi) -> nessun errore',
    () {
      final plan = _plan([
        _entry(exerciseId: 1, code: 'A-001', order: 1),
        _entry(exerciseId: 2, code: 'A-002', order: 2),
        _entry(exerciseId: 3, code: 'A-003', order: 3),
      ]);

      expect(validator.validate(plan).isValid, isTrue);
    },
  );

  test('piano vuoto -> errore', () {
    expect(validator.validate(_plan(const [])).isValid, isFalse);
  });

  test('ordine con un buco (1, 3) -> errore', () {
    final plan = _plan([
      _entry(exerciseId: 1, code: 'A-001', order: 1),
      _entry(exerciseId: 2, code: 'A-002', order: 3),
    ]);

    expect(validator.validate(plan).isValid, isFalse);
  });

  test('esercizio duplicato (stesso exerciseId due volte) -> errore', () {
    final plan = _plan([
      _entry(exerciseId: 1, code: 'A-001', order: 1),
      _entry(exerciseId: 1, code: 'A-001', order: 2),
    ]);

    expect(validator.validate(plan).isValid, isFalse);
  });

  test('parametro non valido (recupero negativo) -> errore (riusa '
      'WorkoutValidationService.validateWorkoutExercise, nessuna regola '
      'duplicata)', () {
    final plan = _plan([
      _entry(exerciseId: 1, code: 'A-001', order: 1, restSeconds: -5),
    ]);

    expect(validator.validate(plan).isValid, isFalse);
  });
}
