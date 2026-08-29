import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/pressure_repository_impl.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/domain/use_cases/add_pressure_measurement.dart';
import 'package:forge/domain/use_cases/update_pressure_measurement.dart';

import '../data/workout_test_helpers.dart' show insertProfilo;

class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

/// Hardening delle fondamenta Progressi (Milestone 7.1, sezione 27):
/// nessuna classificazione clinica testata qui ("normale"/"alta"/ecc. non
/// esiste e non deve esistere) — solo plausibilità numerica.
void main() {
  late AppDatabase db;
  late PressureRepositoryImpl repository;
  late int profileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = PressureRepositoryImpl(db.pressureMeasurementsDao);
    profileId = await insertProfilo(db);
  });

  tearDown(() => db.close());

  PressureMeasurement measurement({
    int? id,
    int? profileIdOverride,
    DateTime? measuredAt,
    required int systolic,
    required int diastolic,
  }) {
    return PressureMeasurement(
      id: id,
      profileId: profileIdOverride ?? profileId,
      measuredAt: measuredAt ?? DateTime(2026, 1, 1),
      systolic: systolic,
      diastolic: diastolic,
    );
  }

  final clock = _FixedClock(DateTime(2026, 1, 10));

  group('AddPressureMeasurement', () {
    test('valida -> creata', () async {
      final id = await AddPressureMeasurement(repository, clock: clock)(
        measurement(systolic: 120, diastolic: 80),
      );
      expect(id, isNotNull);
    });

    test('sistolica <= 0 -> invalida', () {
      expect(
        () => AddPressureMeasurement(repository, clock: clock)(
          measurement(systolic: 0, diastolic: 80),
        ),
        throwsArgumentError,
      );
    });

    test('diastolica <= 0 -> invalida', () {
      expect(
        () => AddPressureMeasurement(repository, clock: clock)(
          measurement(systolic: 120, diastolic: 0),
        ),
        throwsArgumentError,
      );
    });

    test('profilo non valido -> invalida', () {
      expect(
        () => AddPressureMeasurement(repository, clock: clock)(
          measurement(systolic: 120, diastolic: 80, profileIdOverride: -1),
        ),
        throwsArgumentError,
      );
    });

    test('data futura -> invalida', () {
      expect(
        () => AddPressureMeasurement(repository, clock: clock)(
          measurement(
            systolic: 120,
            diastolic: 80,
            measuredAt: DateTime(2026, 1, 11),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('nessuna classificazione clinica: un valore comunemente considerato '
        '"alto" non viene rifiutato solo per quello (sezione 8/14)', () async {
      final id = await AddPressureMeasurement(repository, clock: clock)(
        measurement(systolic: 180, diastolic: 110),
      );
      expect(id, isNotNull);
    });
  });

  group('UpdatePressureMeasurement', () {
    test('stessa validazione di add, nessun percorso di modifica esisteva '
        'prima di questa milestone', () async {
      final id = await AddPressureMeasurement(repository, clock: clock)(
        measurement(systolic: 120, diastolic: 80),
      );
      await UpdatePressureMeasurement(repository, clock: clock)(
        measurement(id: id, systolic: 118, diastolic: 76),
      );
      final updated = await repository.getById(id);
      expect(updated!.systolic, 118);

      expect(
        () => UpdatePressureMeasurement(repository, clock: clock)(
          measurement(id: id, systolic: 0, diastolic: 80),
        ),
        throwsArgumentError,
      );
    });
  });
}
