import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_availability_status.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/services/exercise_availability_service.dart';

Exercise _exercise({required int minimumLevel, int? maximumLevel}) {
  return Exercise(
    id: 1,
    code: 'X-001',
    name: 'Esercizio',
    description: 'desc',
    instructions: 'istr',
    categoryId: 1,
    minimumLevel: minimumLevel,
    maximumLevel: maximumLevel,
    impactLevel: ExerciseImpactLevel.low,
    balanceRequired: false,
    floorRequired: false,
    standingRequired: false,
    supportAllowed: false,
    isSystem: true,
    isActive: true,
    catalogVersion: 1,
  );
}

void main() {
  const service = ExerciseAvailabilityService();

  test('livello ok + attrezzatura ok -> AVAILABLE', () {
    final status = service.evaluate(
      exercise: _exercise(minimumLevel: 1),
      userLevel: 1,
      ownedEquipmentCodes: {'CHAIR'},
      requiredEquipmentCodes: ['CHAIR'],
    );
    expect(status, ExerciseAvailabilityStatus.available);
  });

  test('livello insufficiente -> LOCKED_LEVEL (priorità sul livello)', () {
    final status = service.evaluate(
      exercise: _exercise(minimumLevel: 2),
      userLevel: 1,
      ownedEquipmentCodes: const {},
      requiredEquipmentCodes: const ['CHAIR'],
    );
    expect(status, ExerciseAvailabilityStatus.lockedLevel);
  });

  test('livello ok ma manca attrezzatura -> LOCKED_EQUIPMENT', () {
    final status = service.evaluate(
      exercise: _exercise(minimumLevel: 1),
      userLevel: 1,
      ownedEquipmentCodes: const {},
      requiredEquipmentCodes: const ['BAND'],
    );
    expect(status, ExerciseAvailabilityStatus.lockedEquipment);
  });

  test('attrezzatura NONE -> AVAILABLE indipendentemente dall\'inventario', () {
    final status = service.evaluate(
      exercise: _exercise(minimumLevel: 1),
      userLevel: 1,
      ownedEquipmentCodes: const {},
      requiredEquipmentCodes: const ['NONE'],
    );
    expect(status, ExerciseAvailabilityStatus.available);
  });

  test('richiede BAND + DUMBBELL, possiede solo BAND -> LOCKED_EQUIPMENT', () {
    final status = service.evaluate(
      exercise: _exercise(minimumLevel: 1),
      userLevel: 1,
      ownedEquipmentCodes: {'BAND'},
      requiredEquipmentCodes: const ['BAND', 'DUMBBELL'],
    );
    expect(status, ExerciseAvailabilityStatus.lockedEquipment);
  });

  test('richiede BAND + DUMBBELL, possiede entrambi -> AVAILABLE', () {
    final status = service.evaluate(
      exercise: _exercise(minimumLevel: 1),
      userLevel: 1,
      ownedEquipmentCodes: {'BAND', 'DUMBBELL'},
      requiredEquipmentCodes: const ['BAND', 'DUMBBELL'],
    );
    expect(status, ExerciseAvailabilityStatus.available);
  });

  test('maximumLevel: userLevel oltre il massimo -> LOCKED_LEVEL', () {
    final status = service.evaluate(
      exercise: _exercise(minimumLevel: 1, maximumLevel: 2),
      userLevel: 3,
      ownedEquipmentCodes: const {},
      requiredEquipmentCodes: const ['NONE'],
    );
    expect(status, ExerciseAvailabilityStatus.lockedLevel);
  });
}
