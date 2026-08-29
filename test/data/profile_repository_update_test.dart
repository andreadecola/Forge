import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/core/constants/activity_level.dart';
import 'package:forge/domain/entities/biological_sex.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/use_cases/save_profile.dart';

void main() {
  late AppDatabase database;
  late ProfileRepositoryImpl repository;
  late UserProfile initial;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = ProfileRepositoryImpl(database.userProfileDao);
    initial = UserProfile(
      name: 'Alex',
      birthDate: DateTime(1990, 1, 1),
      biologicalSexForFormula: BiologicalSexForFormula.male,
      heightCm: 189,
      initialWeightKg: 150,
      targetWeightKg: 120,
      preferredWalkMinutes: 30,
      equipmentBudgetLimit: 50,
      startDate: DateTime(2026, 1, 1),
      activityLevel: ActivityLevel.sedentary,
    );
    final id = await repository.saveProfile(initial);
    initial = (await repository.getCurrentProfile())!.copyWith(id: id);
  });

  tearDown(() => database.close());

  test('aggiorna altezza e peso iniziale sulla stessa riga', () async {
    final updated = initial.copyWith(heightCm: 190, initialWeightKg: 148);

    final returnedId = await SaveProfile(repository)(updated);
    final current = await repository.getCurrentProfile();
    final rows = await database.select(database.userProfilesTable).get();

    expect(returnedId, initial.id);
    expect(current!.id, initial.id);
    expect(current.heightCm, 190);
    expect(current.initialWeightKg, 148);
    expect(rows, hasLength(1));
  });

  test('preserva gli altri dati del profilo durante l update', () async {
    final updated = initial.copyWith(
      heightCm: 190,
      initialWeightKg: 148,
      name: 'Bianca',
      biologicalSexForFormula: () => BiologicalSexForFormula.female,
      targetWeightKg: () => null,
      preferredWalkMinutes: 45,
      equipmentBudgetLimit: 1250.5,
      activityLevel: ActivityLevel.veryActive,
    );

    await repository.saveProfile(updated);
    final current = await repository.getCurrentProfile();

    expect(current!.id, initial.id);
    expect(current.name, 'Bianca');
    expect(current.birthDate, initial.birthDate);
    expect(current.startDate, initial.startDate);
    expect(current.biologicalSexForFormula, BiologicalSexForFormula.female);
    expect(current.targetWeightKg, isNull);
    expect(current.preferredWalkMinutes, 45);
    expect(current.equipmentBudgetLimit, 1250.5);
    expect(current.activityLevel, ActivityLevel.veryActive);
    expect(current.createdAt, initial.createdAt);
  });

  test('un update non crea un secondo profilo', () async {
    await repository.saveProfile(initial.copyWith(initialWeightKg: 148));
    await repository.saveProfile(initial.copyWith(initialWeightKg: 146));

    final rows = await database.select(database.userProfilesTable).get();
    expect(rows, hasLength(1));
    expect(rows.single.initialWeightKg, 146);
  });
}
