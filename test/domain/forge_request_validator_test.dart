import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_request_validator.dart';

ForgeRequest _request({
  int userLevel = 1,
  int targetDurationMinutes = 30,
  WorkoutType workoutType = WorkoutType.fullBody,
}) {
  return ForgeRequest(
    profileId: 1,
    userLevel: userLevel,
    availableEquipmentCodes: const {},
    targetDurationMinutes: targetDurationMinutes,
    workoutType: workoutType,
  );
}

void main() {
  test('richiesta valida -> isValid true, nessun errore', () {
    final result = ForgeRequestValidator.validate(_request());
    expect(result.isValid, isTrue);
    expect(result.errors, isEmpty);
  });

  test('livello <= 0 -> invalida', () {
    final result = ForgeRequestValidator.validate(_request(userLevel: 0));
    expect(result.isValid, isFalse);
    expect(result.errors, isNotEmpty);
  });

  test('durata <= 0 -> invalida', () {
    final result = ForgeRequestValidator.validate(
      _request(targetDurationMinutes: 0),
    );
    expect(result.isValid, isFalse);
  });

  test('durata negativa -> invalida', () {
    final result = ForgeRequestValidator.validate(
      _request(targetDurationMinutes: -10),
    );
    expect(result.isValid, isFalse);
  });

  test('CUSTOM non è generabile dal Forge Engine -> invalida (sezione 32)', () {
    final result = ForgeRequestValidator.validate(
      _request(workoutType: WorkoutType.custom),
    );
    expect(result.isValid, isFalse);
    expect(result.errors, isNotEmpty);
  });

  test('tutti i WorkoutType non-CUSTOM sono validi', () {
    for (final type in WorkoutType.values) {
      if (type == WorkoutType.custom) continue;
      final result = ForgeRequestValidator.validate(
        _request(workoutType: type),
      );
      expect(result.isValid, isTrue, reason: '$type dovrebbe essere valido');
    }
  });
}
