import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/repositories/pressure_repository_impl.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/equipment_item.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';
import 'package:forge/domain/entities/user_profile.dart';

void main() {
  late AppDatabase database;
  late int profileId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    profileId = await ProfileRepositoryImpl(database.userProfileDao)
        .saveProfile(
          UserProfile(
            name: 'Alex',
            birthDate: DateTime(1990, 1, 1),
            heightCm: 175,
            initialWeightKg: 80,
            preferredWalkMinutes: 30,
            equipmentBudgetLimit: 50,
            startDate: DateTime(2026, 1, 1),
          ),
        );
  });

  tearDown(() => database.close());

  group('ProfileRepositoryImpl', () {
    test(
      'saveProfile then getCurrentProfile returns the saved profile',
      () async {
        final repository = ProfileRepositoryImpl(database.userProfileDao);
        final current = await repository.getCurrentProfile();
        expect(current, isNotNull);
        expect(current!.id, profileId);
        expect(current.name, 'Alex');
      },
    );
  });

  group('BodyMetricsRepositoryImpl', () {
    test('addMeasurement then getLatestWeight returns it', () async {
      final repository = BodyMetricsRepositoryImpl(
        database.bodyMeasurementsDao,
      );
      await repository.addMeasurement(
        BodyMeasurement(
          profileId: profileId,
          measuredAt: DateTime(2026, 1, 1),
          weightKg: 80,
        ),
      );
      await repository.addMeasurement(
        BodyMeasurement(
          profileId: profileId,
          measuredAt: DateTime(2026, 1, 8),
          weightKg: 78.5,
        ),
      );

      final latest = await repository.getLatestWeight(profileId);
      expect(latest, isNotNull);
      expect(latest!.weightKg, 78.5);

      final all = await repository.getMeasurementsByProfile(profileId);
      expect(all, hasLength(2));
    });

    test('deleteMeasurement removes the row', () async {
      final repository = BodyMetricsRepositoryImpl(
        database.bodyMeasurementsDao,
      );
      final id = await repository.addMeasurement(
        BodyMeasurement(
          profileId: profileId,
          measuredAt: DateTime(2026, 1, 1),
          weightKg: 80,
        ),
      );

      await repository.deleteMeasurement(id);

      final all = await repository.getMeasurementsByProfile(profileId);
      expect(all, isEmpty);
    });
  });

  group('PressureRepositoryImpl', () {
    test('addMeasurement then getLatestPressure returns it', () async {
      final repository = PressureRepositoryImpl(
        database.pressureMeasurementsDao,
      );
      await repository.addMeasurement(
        PressureMeasurement(
          profileId: profileId,
          measuredAt: DateTime(2026, 1, 1),
          systolic: 120,
          diastolic: 80,
        ),
      );

      final latest = await repository.getLatestPressure(profileId);
      expect(latest, isNotNull);
      expect(latest!.systolic, 120);
      expect(latest.diastolic, 80);
    });
  });

  group('EquipmentRepositoryImpl', () {
    test('saveInitialEquipment then getOwnedEquipment reflects it', () async {
      final repository = EquipmentRepositoryImpl(database.userEquipmentDao);
      await repository.saveInitialEquipment(
        profileId: profileId,
        owned: {EquipmentItem.chair, EquipmentItem.mat},
      );

      final owned = await repository.getOwnedEquipment(profileId);
      expect(
        owned.map((e) => e.item),
        containsAll([EquipmentItem.chair, EquipmentItem.mat]),
      );

      final all = await repository.getAllEquipmentStates(profileId);
      expect(all, hasLength(EquipmentItem.values.length));
    });

    test('updateEquipment toggles ownership', () async {
      final repository = EquipmentRepositoryImpl(database.userEquipmentDao);
      await repository.saveInitialEquipment(profileId: profileId, owned: {});

      await repository.updateEquipment(
        profileId: profileId,
        item: EquipmentItem.step,
        owned: true,
      );

      final owned = await repository.getOwnedEquipment(profileId);
      expect(owned.map((e) => e.item), [EquipmentItem.step]);
    });
  });

  group('SettingsRepositoryImpl', () {
    test('onboardingCompleted defaults to false and can be set', () async {
      final repository = SettingsRepositoryImpl(database.appSettingsDao);
      expect(await repository.isOnboardingCompleted(), isFalse);

      await repository.setOnboardingCompleted(true);

      expect(await repository.isOnboardingCompleted(), isTrue);
    });
  });
}
