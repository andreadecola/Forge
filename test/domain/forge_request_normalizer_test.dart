import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_request_normalizer.dart';

ForgeRequest _request({required Set<String> equipment}) {
  return ForgeRequest(
    profileId: 1,
    userLevel: 2,
    availableEquipmentCodes: equipment,
    targetDurationMinutes: 30,
    workoutType: WorkoutType.fullBody,
  );
}

void main() {
  test('rimuove i duplicati di attrezzatura (già garantito da Set, ma '
      'verificato qui)', () {
    // ignore: equal_elements_in_set
    final duplicated = {'BAND', 'BAND', 'DUMBBELL'};
    final normalized = ForgeRequestNormalizer.normalize(
      _request(equipment: duplicated),
    );
    expect(normalized.availableEquipmentCodes, {'BAND', 'DUMBBELL'});
  });

  test(
    'ordine diverso in input -> stesso risultato normalizzato (sezione 66)',
    () {
      final a = ForgeRequestNormalizer.normalize(
        _request(equipment: {'DUMBBELL', 'BAND', 'CHAIR'}),
      );
      final b = ForgeRequestNormalizer.normalize(
        _request(equipment: {'CHAIR', 'DUMBBELL', 'BAND'}),
      );

      expect(a.availableEquipmentCodes, b.availableEquipmentCodes);
      expect(
        a.availableEquipmentCodes.toList(),
        b.availableEquipmentCodes.toList(),
        reason: 'anche l\'ordine di iterazione deve essere stabile',
      );
    },
  );

  test('non altera gli altri campi della richiesta', () {
    final request = _request(equipment: {'BAND'});
    final normalized = ForgeRequestNormalizer.normalize(request);

    expect(normalized.profileId, request.profileId);
    expect(normalized.userLevel, request.userLevel);
    expect(normalized.targetDurationMinutes, request.targetDurationMinutes);
    expect(normalized.workoutType, request.workoutType);
  });
}
