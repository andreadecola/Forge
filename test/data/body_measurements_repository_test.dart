import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/domain/entities/body_measurement.dart';

import 'workout_test_helpers.dart' show insertProfilo;

/// Hardening delle fondamenta Progressi (Milestone 7.1, sezioni 16/17/28-30):
/// CRUD completo, ordinamento deterministico, più misurazioni nello stesso
/// giorno, separazione per profilo, stream `watch*`.
void main() {
  late AppDatabase db;
  late BodyMetricsRepositoryImpl repository;
  late int profileId;
  late int otherProfileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = BodyMetricsRepositoryImpl(db.bodyMeasurementsDao);
    profileId = await insertProfilo(db);
    otherProfileId = await insertProfilo(db);
  });

  tearDown(() => db.close());

  BodyMeasurement measurement({
    int? id,
    int? profileIdOverride,
    required DateTime measuredAt,
    required double weightKg,
    double? waistCm,
    String? notes,
  }) {
    return BodyMeasurement(
      id: id,
      profileId: profileIdOverride ?? profileId,
      measuredAt: measuredAt,
      weightKg: weightKg,
      waistCm: waistCm,
      notes: notes,
    );
  }

  test('create -> getById restituisce la stessa misurazione (mapping '
      'fedele)', () async {
    final id = await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 1, 8),
        weightKg: 79.5,
        waistCm: 88.2,
        notes: 'digiuno',
      ),
    );
    final saved = await repository.getById(id);
    expect(saved, isNotNull);
    expect(saved!.weightKg, 79.5);
    expect(saved.waistCm, 88.2);
    expect(saved.notes, 'digiuno');
    expect(saved.profileId, profileId);
  });

  test('getById su id inesistente -> null', () async {
    expect(await repository.getById(999), isNull);
  });

  test('update corregge i campi, delete rimuove la riga', () async {
    final id = await repository.addMeasurement(
      measurement(measuredAt: DateTime(2026, 1, 1), weightKg: 80),
    );
    await repository.updateMeasurement(
      measurement(id: id, measuredAt: DateTime(2026, 1, 1), weightKg: 78.5),
    );
    expect((await repository.getById(id))!.weightKg, 78.5);

    await repository.deleteMeasurement(id);
    expect(await repository.getById(id), isNull);
  });

  test('ordinamento: measuredAt DESC, deterministico (sezione 16)', () async {
    await repository.addMeasurement(
      measurement(measuredAt: DateTime(2026, 1, 1), weightKg: 82),
    );
    await repository.addMeasurement(
      measurement(measuredAt: DateTime(2026, 1, 5), weightKg: 80),
    );
    await repository.addMeasurement(
      measurement(measuredAt: DateTime(2026, 1, 3), weightKg: 81),
    );

    final all = await repository.getMeasurementsByProfile(profileId);
    expect(all.map((m) => m.weightKg).toList(), [80, 81, 82]);
  });

  test(
    'più misurazioni nello stesso giorno sono consentite (sezione 15)',
    () async {
      await repository.addMeasurement(
        measurement(measuredAt: DateTime(2026, 1, 1, 8), weightKg: 80),
      );
      await repository.addMeasurement(
        measurement(measuredAt: DateTime(2026, 1, 1, 20), weightKg: 79.8),
      );

      final all = await repository.getMeasurementsByProfile(profileId);
      expect(all.length, 2);
    },
  );

  test('separazione per profilo: le misurazioni di un profilo non compaiono '
      "nell'altro (sezione 17)", () async {
    await repository.addMeasurement(
      measurement(measuredAt: DateTime(2026, 1, 1), weightKg: 80),
    );
    await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 1),
        weightKg: 65,
        profileIdOverride: otherProfileId,
      ),
    );

    expect((await repository.getMeasurementsByProfile(profileId)).length, 1);
    expect(
      (await repository.getMeasurementsByProfile(otherProfileId)).length,
      1,
    );
  });

  test('watchMeasurementsByProfile emette su create/update/delete', () async {
    final emissions = <int>[];
    final sub = repository
        .watchMeasurementsByProfile(profileId)
        .listen((list) => emissions.add(list.length));
    await pumpEventQueue();

    final id = await repository.addMeasurement(
      measurement(measuredAt: DateTime(2026, 1, 1), weightKg: 80),
    );
    await pumpEventQueue();

    await repository.updateMeasurement(
      measurement(id: id, measuredAt: DateTime(2026, 1, 1), weightKg: 79),
    );
    await pumpEventQueue();

    await repository.deleteMeasurement(id);
    await pumpEventQueue();

    expect(emissions, [0, 1, 1, 0]);
    await sub.cancel();
  });
}
