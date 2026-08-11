import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/exercise_details.dart';
import 'package:forge/domain/entities/forge_exclusion_reason.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';

import 'forge_fixtures.dart';

ForgeRequest _request({
  int userLevel = 2,
  Set<String> equipment = const {'CHAIR'},
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

/// Catalogo misto (sezione 68): un eleggibile pulito, uno con livello
/// troppo alto, uno con attrezzatura mancante, uno inattivo, uno con
/// parametri non stimabili.
List<ExerciseDetails> _mixedCatalog() {
  return [
    buildExerciseDetails(
      exercise: buildExercise(
        id: 1,
        code: 'A-ELIGIBLE',
        minimumLevel: 1,
        defaultSets: 3,
        defaultReps: 10,
        defaultRestSeconds: 30,
      ),
      categoryCode: 'CORE',
    ),
    buildExerciseDetails(
      exercise: buildExercise(
        id: 2,
        code: 'B-LEVEL-TOO-HIGH',
        minimumLevel: 5,
        defaultReps: 10,
      ),
      categoryCode: 'CORE',
    ),
    buildExerciseDetails(
      exercise: buildExercise(
        id: 3,
        code: 'C-MISSING-EQUIPMENT',
        minimumLevel: 1,
        defaultReps: 10,
      ),
      categoryCode: 'CORE',
      requiredEquipmentCodes: ['DUMBBELL'],
    ),
    buildExerciseDetails(
      exercise: buildExercise(
        id: 4,
        code: 'D-INACTIVE',
        minimumLevel: 1,
        isActive: false,
        defaultReps: 10,
      ),
      categoryCode: 'CORE',
    ),
    buildExerciseDetails(
      exercise: buildExercise(id: 5, code: 'E-UNSUPPORTED', minimumLevel: 1),
      categoryCode: 'CORE',
    ),
  ];
}

void main() {
  const engine = ForgeEngine();

  test('ForgeEvaluationResult completo su catalogo misto (sezione 68): 1 '
      'eleggibile, 4 esclusi con i motivi corretti', () {
    final result = engine.evaluateExercises(_request(), _mixedCatalog());

    expect(result.eligible, hasLength(1));
    expect(result.eligible.single.candidate.exercise.code, 'A-ELIGIBLE');
    expect(result.eligible.single.score, isNotNull);
    expect(result.eligible.single.estimatedDurationSeconds, isNotNull);

    expect(result.excluded, hasLength(4));
    final byCode = {
      for (final e in result.excluded) e.candidate.exercise.code: e,
    };
    expect(
      byCode['B-LEVEL-TOO-HIGH']!.eligibility.reasons,
      contains(ForgeExclusionReason.levelTooHigh),
    );
    expect(
      byCode['C-MISSING-EQUIPMENT']!.eligibility.reasons,
      contains(ForgeExclusionReason.missingEquipment),
    );
    expect(
      byCode['D-INACTIVE']!.eligibility.reasons,
      contains(ForgeExclusionReason.inactive),
    );
    expect(
      byCode['E-UNSUPPORTED']!.eligibility.reasons,
      contains(ForgeExclusionReason.unsupportedParameters),
    );
    for (final excluded in result.excluded) {
      expect(excluded.score, isNull);
      expect(excluded.estimatedDurationSeconds, isNull);
    }
  });

  test('richiesta CUSTOM: nessuna eccezione, risultato vuoto con warning', () {
    final result = engine.evaluateExercises(
      _request(workoutType: WorkoutType.custom),
      _mixedCatalog(),
    );

    expect(result.eligible, isEmpty);
    expect(result.excluded, isEmpty);
    expect(result.warnings, isNotEmpty);
  });

  test('determinismo (sezione 41/65): stesso input eseguito più volte -> '
      'stesso ordine, stessi punteggi, stessi motivi', () {
    final catalog = _mixedCatalog();
    final request = _request();

    final first = engine.evaluateExercises(request, catalog);
    final second = engine.evaluateExercises(request, catalog);

    expect(
      first.eligible.map((e) => e.candidate.exercise.code).toList(),
      second.eligible.map((e) => e.candidate.exercise.code).toList(),
    );
    expect(
      first.eligible.map((e) => e.score!.total).toList(),
      second.eligible.map((e) => e.score!.total).toList(),
    );
    expect(
      first.excluded.map((e) => e.eligibility.reasons).toList(),
      second.excluded.map((e) => e.eligibility.reasons).toList(),
    );
  });

  test(
    'ordine di input diverso -> stesso risultato ordinato (sezione 42/66)',
    () {
      final catalog = _mixedCatalog();
      final shuffled = [
        catalog[2],
        catalog[4],
        catalog[0],
        catalog[3],
        catalog[1],
      ];
      final request = _request();

      final original = engine.evaluateExercises(request, catalog);
      final fromShuffled = engine.evaluateExercises(request, shuffled);

      expect(
        original.eligible.map((e) => e.candidate.exercise.code).toList(),
        fromShuffled.eligible.map((e) => e.candidate.exercise.code).toList(),
      );
      expect(
        original.excluded.map((e) => e.candidate.exercise.code).toSet(),
        fromShuffled.excluded.map((e) => e.candidate.exercise.code).toSet(),
      );
    },
  );

  test('tie break stabile a parità di punteggio: livello minimo crescente, '
      'poi codice esercizio crescente (sezione 43)', () {
    // Stesso identico esercizio (stesso score) tranne codice e id: a
    // parità di punteggio e livello, l'ordine deve essere alfabetico.
    final catalog = [
      buildExerciseDetails(
        exercise: buildExercise(
          id: 1,
          code: 'Z-LAST',
          minimumLevel: 1,
          defaultSets: 2,
          defaultReps: 10,
        ),
        categoryCode: 'CORE',
      ),
      buildExerciseDetails(
        exercise: buildExercise(
          id: 2,
          code: 'A-FIRST',
          minimumLevel: 1,
          defaultSets: 2,
          defaultReps: 10,
        ),
        categoryCode: 'CORE',
      ),
    ];

    final result = engine.evaluateExercises(_request(), catalog);

    expect(result.eligible.map((e) => e.candidate.exercise.code).toList(), [
      'A-FIRST',
      'Z-LAST',
    ]);
  });

  test('eleggibili ordinati per punteggio decrescente (sezione 48)', () {
    final result = engine.evaluateExercises(_request(), _mixedCatalog());
    for (var i = 1; i < result.eligible.length; i++) {
      expect(
        result.eligible[i - 1].score!.total,
        greaterThanOrEqualTo(result.eligible[i].score!.total),
      );
    }
  });
}
