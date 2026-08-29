import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/pressure_repository_impl.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';

import 'workout_test_helpers.dart' show insertProfilo;

/// Hardening delle fondamenta Progressi (Milestone 7.1, sezioni 16/17/28-30):
/// stesso set di proprietà di `body_measurements_repository_test.dart`, per
/// la pressione — incluso il nuovo `getById`/`updateMeasurement` esposti a
/// livello di repository in questa milestone.
void main() {
  late AppDatabase db;
  late PressureRepositoryImpl repository;
  late int profileId;
  late int otherProfileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = PressureRepositoryImpl(db.pressureMeasurementsDao);
    profileId = await insertProfilo(db);
    otherProfileId = await insertProfilo(db);
  });

  tearDown(() => db.close());

  PressureMeasurement measurement({
    int? id,
    int? profileIdOverride,
    required DateTime measuredAt,
    required int systolic,
    required int diastolic,
    int? heartRate,
    String? notes,
  }) {
    return PressureMeasurement(
      id: id,
      profileId: profileIdOverride ?? profileId,
      measuredAt: measuredAt,
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      notes: notes,
    );
  }

  test('create -> getById restituisce la stessa misurazione (mapping '
      'fedele)', () async {
    final id = await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 1, 8),
        systolic: 120,
        diastolic: 80,
        heartRate: 65,
        notes: 'a riposo',
      ),
    );
    final saved = await repository.getById(id);
    expect(saved, isNotNull);
    expect(saved!.systolic, 120);
    expect(saved.diastolic, 80);
    expect(saved.heartRate, 65);
    expect(saved.notes, 'a riposo');
  });

  test('getById su id inesistente -> null', () async {
    expect(await repository.getById(999), isNull);
  });

  test('update corregge i campi (nuovo in Milestone 7.1), delete rimuove la '
      'riga', () async {
    final id = await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 1),
        systolic: 120,
        diastolic: 80,
      ),
    );
    await repository.updateMeasurement(
      measurement(
        id: id,
        measuredAt: DateTime(2026, 1, 1),
        systolic: 118,
        diastolic: 76,
      ),
    );
    final updated = await repository.getById(id);
    expect(updated!.systolic, 118);
    expect(updated.diastolic, 76);

    await repository.deleteMeasurement(id);
    expect(await repository.getById(id), isNull);
  });

  test('ordinamento: measuredAt DESC, deterministico (sezione 16)', () async {
    await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 1),
        systolic: 130,
        diastolic: 85,
      ),
    );
    await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 5),
        systolic: 118,
        diastolic: 76,
      ),
    );
    await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 3),
        systolic: 122,
        diastolic: 80,
      ),
    );

    final all = await repository.getMeasurementsByProfile(profileId);
    expect(all.map((m) => m.systolic).toList(), [118, 122, 130]);
  });

  test(
    'più misurazioni nello stesso giorno sono consentite (sezione 15)',
    () async {
      await repository.addMeasurement(
        measurement(
          measuredAt: DateTime(2026, 1, 1, 8),
          systolic: 120,
          diastolic: 80,
        ),
      );
      await repository.addMeasurement(
        measurement(
          measuredAt: DateTime(2026, 1, 1, 20),
          systolic: 128,
          diastolic: 84,
        ),
      );

      final all = await repository.getMeasurementsByProfile(profileId);
      expect(all.length, 2);
    },
  );

  test('separazione per profilo (sezione 17)', () async {
    await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 1),
        systolic: 120,
        diastolic: 80,
      ),
    );
    await repository.addMeasurement(
      measurement(
        measuredAt: DateTime(2026, 1, 1),
        systolic: 110,
        diastolic: 70,
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
      measurement(
        measuredAt: DateTime(2026, 1, 1),
        systolic: 120,
        diastolic: 80,
      ),
    );
    await pumpEventQueue();

    await repository.updateMeasurement(
      measurement(
        id: id,
        measuredAt: DateTime(2026, 1, 1),
        systolic: 118,
        diastolic: 78,
      ),
    );
    await pumpEventQueue();

    await repository.deleteMeasurement(id);
    await pumpEventQueue();

    expect(emissions, [0, 1, 1, 0]);
    await sub.cancel();
  });
}
