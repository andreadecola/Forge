import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/exercise_details.dart';
import 'package:forge/domain/entities/forge_generation_error.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';
import 'package:forge/domain/services/forge_workout_generator.dart';

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

List<ExerciseDetails> _fullBodyCatalog() {
  return [
    buildExerciseDetails(
      exercise: buildExercise(
        id: 1,
        code: 'LEG-1',
        minimumLevel: 1,
        defaultReps: 10,
      ),
      categoryCode: 'GAMBE_GLUTEI',
    ),
    buildExerciseDetails(
      exercise: buildExercise(
        id: 2,
        code: 'UPPER-1',
        minimumLevel: 1,
        defaultReps: 10,
      ),
      categoryCode: 'PETTO_SPINTA',
    ),
    buildExerciseDetails(
      exercise: buildExercise(
        id: 3,
        code: 'CORE-1',
        minimumLevel: 1,
        defaultReps: 10,
      ),
      categoryCode: 'CORE',
    ),
    buildExerciseDetails(
      exercise: buildExercise(
        id: 4,
        code: 'MOB-1',
        minimumLevel: 1,
        defaultReps: 10,
      ),
      categoryCode: 'MOBILITA',
    ),
  ];
}

void main() {
  const engine = ForgeEngine();
  const generator = ForgeWorkoutGenerator();

  test('richiesta non valida (livello 0) -> invalidRequest, plan nullo', () {
    final evaluation = engine.evaluateExercises(
      _request(userLevel: 0),
      _fullBodyCatalog(),
    );
    final result = generator.generate(evaluation);

    expect(result.success, isFalse);
    expect(result.errors, [ForgeGenerationError.invalidRequest]);
    expect(result.plan, isNull);
  });

  test('WorkoutType CUSTOM -> unsupportedWorkoutType, plan nullo', () {
    final evaluation = engine.evaluateExercises(
      _request(workoutType: WorkoutType.custom),
      _fullBodyCatalog(),
    );
    final result = generator.generate(evaluation);

    expect(result.success, isFalse);
    expect(result.errors, [ForgeGenerationError.unsupportedWorkoutType]);
    expect(result.plan, isNull);
  });

  test('nessun esercizio eleggibile (livello utente troppo basso per tutto '
      'il catalogo) -> insufficientEligibleExercises, plan nullo', () {
    final highLevelCatalog = [
      buildExerciseDetails(
        exercise: buildExercise(
          id: 1,
          code: 'HARD-1',
          minimumLevel: 5,
          defaultReps: 10,
        ),
        categoryCode: 'CORE',
      ),
    ];
    final evaluation = engine.evaluateExercises(
      _request(userLevel: 1),
      highLevelCatalog,
    );
    final result = generator.generate(evaluation);

    expect(result.success, isFalse);
    expect(result.errors, [ForgeGenerationError.insufficientEligibleExercises]);
    expect(result.plan, isNull);
  });

  test('catalogo sufficiente e completo -> generazione riuscita', () {
    final evaluation = engine.evaluateExercises(_request(), _fullBodyCatalog());
    final result = generator.generate(evaluation);

    expect(result.success, isTrue);
    expect(result.errors, isEmpty);
    expect(result.plan, isNotNull);
    expect(result.plan!.exercises, isNotEmpty);
    expect(result.evaluation, evaluation);
  });

  test('copertura obbligatoria non soddisfacibile (solo CORE nel catalogo) '
      '-> missingRequiredCoverage, ma il piano di miglior tentativo resta '
      'comunque disponibile (spiegabilità, sezione 6)', () {
    final coreOnlyCatalog = [
      buildExerciseDetails(
        exercise: buildExercise(
          id: 1,
          code: 'CORE-1',
          minimumLevel: 1,
          defaultReps: 10,
        ),
        categoryCode: 'CORE',
      ),
      buildExerciseDetails(
        exercise: buildExercise(
          id: 2,
          code: 'CORE-2',
          minimumLevel: 1,
          defaultReps: 10,
        ),
        categoryCode: 'CORE',
      ),
    ];
    final evaluation = engine.evaluateExercises(_request(), coreOnlyCatalog);
    final result = generator.generate(evaluation);

    expect(result.success, isFalse);
    expect(result.errors, [ForgeGenerationError.missingRequiredCoverage]);
    expect(result.plan, isNotNull);
    expect(result.plan!.exercises, isNotEmpty);
  });
}
