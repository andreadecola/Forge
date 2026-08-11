import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_engine_config.dart';
import 'package:forge/domain/entities/forge_exercise_history.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/services/forge_parameter_progression_policy.dart';

ForgeExerciseHistory _history({int timesCompleted = 3, int timesPlanned = 3}) {
  return ForgeExerciseHistory(
    exerciseId: 1,
    timesPlanned: timesPlanned,
    timesCompleted: timesCompleted,
    timesSkipped: 0,
    completedSets: timesPlanned * 3,
    plannedSets: timesPlanned * 3,
  );
}

void main() {
  const policy = ForgeParameterProgressionPolicy();
  const config = ForgeEngineConfig();

  test('esercizio a ripetizioni con evidenza sufficiente -> prima '
      'candidata: ripetizioni aumentate secondo config (sezione 52)', () {
    const current = WorkoutExercise(
      workoutId: 0,
      exerciseId: 1,
      order: 1,
      sets: 2,
      repetitions: 10,
      restSeconds: 30,
    );

    final proposals = policy.propose(
      current: current,
      history: _history(),
      config: config,
    );

    expect(proposals, isNotEmpty);
    final first = proposals.first;
    expect(
      first.workoutExercise.repetitions,
      10 + config.repsProgressionIncrement,
    );
    expect(
      first.workoutExercise.sets,
      2,
      reason: 'un solo parametro alla volta',
    );
    expect(
      first.workoutExercise.restSeconds,
      30,
      reason: 'sezione 30: rest invariato',
    );
  });

  test('esercizio a tempo con evidenza sufficiente -> prima candidata: '
      'durata aumentata secondo config (sezione 53)', () {
    const current = WorkoutExercise(
      workoutId: 0,
      exerciseId: 1,
      order: 1,
      sets: 2,
      durationSeconds: 30,
      restSeconds: 20,
    );

    final proposals = policy.propose(
      current: current,
      history: _history(),
      config: config,
    );

    expect(proposals, isNotEmpty);
    final first = proposals.first;
    expect(
      first.workoutExercise.durationSeconds,
      30 + config.durationProgressionIncrementSeconds,
    );
    expect(first.workoutExercise.restSeconds, 20);
  });

  test('il recupero non viene mai aumentato né ridotto, in nessuna '
      'candidata (sezione 30/54)', () {
    const current = WorkoutExercise(
      workoutId: 0,
      exerciseId: 1,
      order: 1,
      sets: 2,
      repetitions: 8,
      restSeconds: 45,
    );

    final proposals = policy.propose(
      current: current,
      history: _history(),
      config: config,
    );

    expect(proposals, isNotEmpty);
    for (final proposal in proposals) {
      expect(proposal.workoutExercise.restSeconds, 45);
    }
  });

  test('un esercizio a ripetizioni offre anche una seconda candidata di '
      'riserva con le serie aumentate, mai sopra maxGeneratedSets '
      '(sezione 26/29/55)', () {
    const current = WorkoutExercise(
      workoutId: 0,
      exerciseId: 1,
      order: 1,
      sets: 2,
      repetitions: 10,
    );

    final proposals = policy.propose(
      current: current,
      history: _history(),
      config: config,
    );

    expect(proposals.length, 2);
    expect(
      proposals[0].workoutExercise.repetitions,
      10 + config.repsProgressionIncrement,
    );
    expect(proposals[0].workoutExercise.sets, 2);
    expect(proposals[1].workoutExercise.sets, 3);
    expect(
      proposals[1].workoutExercise.repetitions,
      10,
      reason: 'un solo parametro alla volta',
    );
  });

  test('serie già al tetto maxGeneratedSets -> nessuna seconda candidata', () {
    final atCap = WorkoutExercise(
      workoutId: 0,
      exerciseId: 1,
      order: 1,
      sets: config.maxGeneratedSets,
      repetitions: 10,
    );

    final proposals = policy.propose(
      current: atCap,
      history: _history(),
      config: config,
    );

    expect(proposals.length, 1);
    expect(
      proposals.single.workoutExercise.repetitions,
      10 + config.repsProgressionIncrement,
    );
  });

  test('storico insufficiente (poche esecuzioni) -> nessuna proposta', () {
    const current = WorkoutExercise(
      workoutId: 0,
      exerciseId: 1,
      order: 1,
      repetitions: 10,
    );

    final proposals = policy.propose(
      current: current,
      history: _history(timesCompleted: 1),
      config: config,
    );

    expect(proposals, isEmpty);
  });

  test('nessuno storico -> nessuna proposta', () {
    const current = WorkoutExercise(
      workoutId: 0,
      exerciseId: 1,
      order: 1,
      repetitions: 10,
    );

    final proposals = policy.propose(
      current: current,
      history: null,
      config: config,
    );

    expect(proposals, isEmpty);
  });
}
