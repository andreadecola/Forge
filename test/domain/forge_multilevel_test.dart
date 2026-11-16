import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';

import 'forge_fixtures.dart';

ForgeRequest _request({int userLevel = 5, Set<int>? selectedLevels}) {
  return ForgeRequest(
    profileId: 1,
    userLevel: userLevel,
    selectedLevels: selectedLevels,
    availableEquipmentCodes: const {},
    targetDurationMinutes: 30,
    workoutType: WorkoutType.fullBody,
  );
}

List<dynamic> _catalog() {
  return [
    for (var level = 1; level <= 5; level++)
      buildExerciseDetails(
        exercise: buildExercise(
          id: level,
          code: 'LEVEL-$level',
          minimumLevel: level,
          defaultReps: 10,
        ),
        categoryCode: 'CORE',
      ),
    buildExerciseDetails(
      exercise: buildExercise(
        id: 6,
        code: 'LEVEL-2-MAX-2',
        minimumLevel: 2,
        maximumLevel: 2,
        defaultReps: 10,
      ),
      categoryCode: 'CORE',
    ),
  ];
}

void main() {
  const engine = ForgeEngine();

  Set<String> eligibleCodes(ForgeRequest request) {
    return engine
        .evaluateExercises(request, _catalog().cast())
        .eligible
        .map((entry) => entry.candidate.exercise.code)
        .toSet();
  }

  test('un solo livello conserva esattamente il comportamento precedente', () {
    final legacy = engine.evaluateExercises(
      _request(userLevel: 3),
      _catalog().cast(),
    );
    final explicit = engine.evaluateExercises(
      _request(userLevel: 3, selectedLevels: {3}),
      _catalog().cast(),
    );

    expect(
      explicit.eligible.map((entry) => entry.candidate.exercise.code).toList(),
      legacy.eligible.map((entry) => entry.candidate.exercise.code).toList(),
    );
    expect(
      explicit.eligible.map((entry) => entry.score!.total).toList(),
      legacy.eligible.map((entry) => entry.score!.total).toList(),
    );
  });

  test('due livelli includono il pool compatibile senza quota per livello', () {
    final codes = eligibleCodes(_request(selectedLevels: {1, 2}));

    expect(codes, containsAll(['LEVEL-1', 'LEVEL-2']));
    expect(codes, isNot(contains('LEVEL-3')));
    expect(codes, contains('LEVEL-2-MAX-2'));
  });

  test(
    'livelli non consecutivi usano la compatibilità OR, senza bypassare il massimo',
    () {
      final codes = eligibleCodes(_request(selectedLevels: {1, 3}));

      expect(codes, containsAll(['LEVEL-1', 'LEVEL-2', 'LEVEL-3']));
      expect(codes, isNot(contains('LEVEL-2-MAX-2')));
      expect(codes, isNot(contains('LEVEL-4')));
    },
  );

  test(
    'tutti e cinque i livelli rendono disponibili tutti i livelli del catalogo',
    () {
      final codes = eligibleCodes(_request(selectedLevels: {1, 2, 3, 4, 5}));

      expect(
        codes,
        containsAll(['LEVEL-1', 'LEVEL-2', 'LEVEL-3', 'LEVEL-4', 'LEVEL-5']),
      );
      expect(codes, contains('LEVEL-2-MAX-2'));
    },
  );

  test('set vuoto: richiesta spiegata come non valida', () {
    final result = engine.evaluateExercises(
      _request(selectedLevels: const {}),
      _catalog().cast(),
    );

    expect(result.eligible, isEmpty);
    expect(result.excluded, isEmpty);
    expect(result.warnings, contains('Seleziona almeno un livello.'));
  });

  test('ordine e ripetizione della selezione non cambiano il risultato', () {
    final first = engine.evaluateExercises(
      _request(selectedLevels: {1, 3, 5}),
      _catalog().cast(),
    );
    final second = engine.evaluateExercises(
      _request(selectedLevels: {5, 1, 3}),
      _catalog().cast(),
    );

    expect(
      first.eligible.map((entry) => entry.candidate.exercise.code).toList(),
      second.eligible.map((entry) => entry.candidate.exercise.code).toList(),
    );
    expect(
      first.eligible.map((entry) => entry.score!.total).toList(),
      second.eligible.map((entry) => entry.score!.total).toList(),
    );
  });

  test('safety: un livello superiore non supera maximumLevel', () {
    final result = engine.evaluateExercises(
      _request(selectedLevels: {3, 5}),
      _catalog().cast(),
    );
    final excluded = result.excluded.firstWhere(
      (entry) => entry.candidate.exercise.code == 'LEVEL-2-MAX-2',
    );

    expect(excluded.eligibility.eligible, isFalse);
  });
}
