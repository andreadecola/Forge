import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_engine_config.dart';
import 'package:forge/domain/entities/forge_exclusion_reason.dart';
import 'package:forge/domain/services/forge_eligibility_service.dart';

import 'forge_fixtures.dart';

void main() {
  const service = ForgeEligibilityService();
  const config = ForgeEngineConfig();

  test('attivo + livello ok + attrezzatura disponibile -> eligible', () {
    final candidate = buildCandidate(
      exercise: buildExercise(minimumLevel: 1, defaultReps: 10),
      requiredEquipmentCodes: {'CHAIR'},
    );

    final result = service.evaluate(
      candidate: candidate,
      userLevel: 1,
      availableEquipmentCodes: {'CHAIR'},
      config: config,
    );

    expect(result.eligible, isTrue);
    expect(result.reasons, isEmpty);
  });

  test('esercizio inattivo -> excluded con motivo inactive', () {
    final candidate = buildCandidate(
      exercise: buildExercise(isActive: false, defaultReps: 10),
    );

    final result = service.evaluate(
      candidate: candidate,
      userLevel: 1,
      availableEquipmentCodes: const {},
      config: config,
    );

    expect(result.eligible, isFalse);
    expect(result.reasons, contains(ForgeExclusionReason.inactive));
  });

  test('livello utente insufficiente -> excluded con motivo levelTooHigh', () {
    final candidate = buildCandidate(
      exercise: buildExercise(minimumLevel: 4, defaultReps: 10),
    );

    final result = service.evaluate(
      candidate: candidate,
      userLevel: 1,
      availableEquipmentCodes: const {},
      config: config,
    );

    expect(result.eligible, isFalse);
    expect(result.reasons, contains(ForgeExclusionReason.levelTooHigh));
  });

  test('utente oltre il livello massimo dell\'esercizio -> excluded con '
      'motivo levelTooLow', () {
    final candidate = buildCandidate(
      exercise: buildExercise(
        minimumLevel: 1,
        maximumLevel: 2,
        defaultReps: 10,
      ),
    );

    final result = service.evaluate(
      candidate: candidate,
      userLevel: 3,
      availableEquipmentCodes: const {},
      config: config,
    );

    expect(result.eligible, isFalse);
    expect(result.reasons, contains(ForgeExclusionReason.levelTooLow));
  });

  test('attrezzatura mancante -> excluded con motivo missingEquipment', () {
    final candidate = buildCandidate(
      exercise: buildExercise(defaultReps: 10),
      requiredEquipmentCodes: {'BAND'},
    );

    final result = service.evaluate(
      candidate: candidate,
      userLevel: 1,
      availableEquipmentCodes: const {},
      config: config,
    );

    expect(result.eligible, isFalse);
    expect(result.reasons, contains(ForgeExclusionReason.missingEquipment));
  });

  test('NONE -> eligible senza bisogno di alcuna attrezzatura', () {
    final candidate = buildCandidate(
      exercise: buildExercise(defaultReps: 10),
      requiredEquipmentCodes: {'NONE'},
    );

    final result = service.evaluate(
      candidate: candidate,
      userLevel: 1,
      availableEquipmentCodes: const {},
      config: config,
    );

    expect(result.eligible, isTrue);
  });

  test('HOUSEHOLD mancante -> excluded (trattato come attrezzatura reale)', () {
    final candidate = buildCandidate(
      exercise: buildExercise(defaultReps: 10),
      requiredEquipmentCodes: {'HOUSEHOLD'},
    );

    final result = service.evaluate(
      candidate: candidate,
      userLevel: 1,
      availableEquipmentCodes: const {},
      config: config,
    );

    expect(result.eligible, isFalse);
    expect(result.reasons, contains(ForgeExclusionReason.missingEquipment));
  });

  test(
    'né ripetizioni né durata -> excluded con motivo unsupportedParameters',
    () {
      final candidate = buildCandidate(exercise: buildExercise());

      final result = service.evaluate(
        candidate: candidate,
        userLevel: 1,
        availableEquipmentCodes: const {},
        config: config,
      );

      expect(result.eligible, isFalse);
      expect(
        result.reasons,
        contains(ForgeExclusionReason.unsupportedParameters),
      );
    },
  );

  test('più vincoli HARD violati contemporaneamente -> tutti i motivi '
      'riportati, non solo il primo (sezione 16/67)', () {
    final candidate = buildCandidate(
      exercise: buildExercise(isActive: false, minimumLevel: 5),
      requiredEquipmentCodes: {'BAND'},
    );

    final result = service.evaluate(
      candidate: candidate,
      userLevel: 1,
      availableEquipmentCodes: const {},
      config: config,
    );

    expect(result.eligible, isFalse);
    expect(result.reasons.toSet(), {
      ForgeExclusionReason.inactive,
      ForgeExclusionReason.levelTooHigh,
      ForgeExclusionReason.missingEquipment,
      ForgeExclusionReason.unsupportedParameters,
    });
  });
}
