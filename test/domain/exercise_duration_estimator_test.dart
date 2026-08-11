import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_engine_config.dart';
import 'package:forge/domain/services/exercise_duration_estimator.dart';

import 'forge_fixtures.dart';

void main() {
  const config = ForgeEngineConfig(estimatedSecondsPerRepetition: 4);

  test('esercizio a ripetizioni: 3 serie x 10 rip, recupero 60 sec -> '
      '3*(10*4) + 2*60 (sezione 59)', () {
    final exercise = buildExercise(
      defaultSets: 3,
      defaultReps: 10,
      defaultRestSeconds: 60,
    );

    final seconds = ExerciseDurationEstimator.estimateSeconds(
      exercise: exercise,
      config: config,
    );

    expect(seconds, 3 * (10 * 4) + 2 * 60);
  });

  test(
    'esercizio a tempo: 3 serie x 30 sec, recupero 60 sec -> 30*3 + 60*2 '
    '(sezione 60, nessun transition time nella stima del singolo esercizio)',
    () {
      final exercise = buildExercise(
        defaultSets: 3,
        defaultDurationSeconds: 30,
        defaultRestSeconds: 60,
      );

      final seconds = ExerciseDurationEstimator.estimateSeconds(
        exercise: exercise,
        config: config,
      );

      expect(seconds, 30 * 3 + 60 * 2);
    },
  );

  test(
    'sets null -> trattato come 1 (sezione 61), nessun recupero contato',
    () {
      final exercise = buildExercise(
        defaultSets: null,
        defaultReps: 10,
        defaultRestSeconds: 60,
      );

      final seconds = ExerciseDurationEstimator.estimateSeconds(
        exercise: exercise,
        config: config,
      );

      expect(
        seconds,
        10 * 4,
        reason: '1 sola serie -> nessun recupero tra serie',
      );
    },
  );

  test('durationSeconds prevale su repetitions se entrambi presenti (sezione '
      '62, coerenza con la sessione runtime M4.4.2)', () {
    final exercise = buildExercise(
      defaultSets: 1,
      defaultReps: 100,
      defaultDurationSeconds: 20,
    );

    final seconds = ExerciseDurationEstimator.estimateSeconds(
      exercise: exercise,
      config: config,
    );

    expect(seconds, 20);
  });

  test(
    'una sola serie non aggiunge mai recupero, anche se restSeconds > 0',
    () {
      final exercise = buildExercise(
        defaultSets: 1,
        defaultDurationSeconds: 20,
        defaultRestSeconds: 60,
      );

      final seconds = ExerciseDurationEstimator.estimateSeconds(
        exercise: exercise,
        config: config,
      );

      expect(seconds, 20);
    },
  );

  test('né ripetizioni né durata -> null (sezione 22, non stimabile senza '
      'inventare un dato)', () {
    final exercise = buildExercise(defaultSets: 3, defaultRestSeconds: 30);

    final seconds = ExerciseDurationEstimator.estimateSeconds(
      exercise: exercise,
      config: config,
    );

    expect(seconds, isNull);
  });

  test('recupero assente (null) equivale a nessun recupero', () {
    final exercise = buildExercise(defaultSets: 3, defaultReps: 5);

    final seconds = ExerciseDurationEstimator.estimateSeconds(
      exercise: exercise,
      config: config,
    );

    expect(seconds, 3 * (5 * 4));
  });
}
