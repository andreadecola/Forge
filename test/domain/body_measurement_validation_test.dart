import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/domain/use_cases/add_body_measurement.dart';
import 'package:forge/domain/use_cases/update_body_measurement.dart';

import '../data/workout_test_helpers.dart' show insertProfilo;

class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

/// Hardening delle fondamenta Progressi (Milestone 7.1, sezione 27):
/// nessuna classificazione clinica testata qui — solo plausibilità
/// (numeri positivi, data non futura, profilo valido).
void main() {
  late AppDatabase db;
  late BodyMetricsRepositoryImpl repository;
  late int profileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = BodyMetricsRepositoryImpl(db.bodyMeasurementsDao);
    profileId = await insertProfilo(db);
  });

  tearDown(() => db.close());

  BodyMeasurement measurement({
    int? profileIdOverride,
    DateTime? measuredAt,
    required double weightKg,
    double? waistCm,
  }) {
    return BodyMeasurement(
      profileId: profileIdOverride ?? profileId,
      measuredAt: measuredAt ?? DateTime(2026, 1, 1),
      weightKg: weightKg,
      waistCm: waistCm,
    );
  }

  final clock = _FixedClock(DateTime(2026, 1, 10));

  group('AddBodyMeasurement', () {
    test('peso soltanto -> valido', () async {
      final id = await AddBodyMeasurement(repository, clock: clock)(
        measurement(weightKg: 80),
      );
      expect(id, isNotNull);
    });

    test('girovita soltanto (peso comunque richiesto dallo schema attuale, '
        'sezione 6/20) -> valido se peso > 0', () async {
      final id = await AddBodyMeasurement(repository, clock: clock)(
        measurement(weightKg: 80, waistCm: 90),
      );
      expect(id, isNotNull);
    });

    test('peso + girovita -> valido', () async {
      final id = await AddBodyMeasurement(repository, clock: clock)(
        measurement(weightKg: 80, waistCm: 90),
      );
      expect(id, isNotNull);
    });

    test('peso non plausibile (<= 0) -> invalido', () {
      expect(
        () => AddBodyMeasurement(repository, clock: clock)(
          measurement(weightKg: 0),
        ),
        throwsArgumentError,
      );
      expect(
        () => AddBodyMeasurement(repository, clock: clock)(
          measurement(weightKg: -5),
        ),
        throwsArgumentError,
      );
    });

    test('girovita negativo -> invalido', () {
      expect(
        () => AddBodyMeasurement(repository, clock: clock)(
          measurement(weightKg: 80, waistCm: -1),
        ),
        throwsArgumentError,
      );
    });

    test('profilo non valido (<= 0) -> invalido', () {
      expect(
        () => AddBodyMeasurement(repository, clock: clock)(
          measurement(weightKg: 80, profileIdOverride: 0),
        ),
        throwsArgumentError,
      );
    });

    test('data futura -> invalido', () {
      expect(
        () => AddBodyMeasurement(repository, clock: clock)(
          measurement(weightKg: 80, measuredAt: DateTime(2026, 1, 11)),
        ),
        throwsArgumentError,
      );
    });

    test('data passata (sezione 9: correzione retroattiva consentita) -> '
        'valido', () async {
      final id = await AddBodyMeasurement(repository, clock: clock)(
        measurement(weightKg: 80, measuredAt: DateTime(2020, 1, 1)),
      );
      expect(id, isNotNull);
    });
  });

  group('UpdateBodyMeasurement', () {
    test('stessa validazione di add', () async {
      final id = await AddBodyMeasurement(repository, clock: clock)(
        measurement(weightKg: 80),
      );
      await UpdateBodyMeasurement(repository, clock: clock)(
        measurement(weightKg: 78).copyWith(id: id),
      );
      final updated = await repository.getById(id);
      expect(updated!.weightKg, 78);

      expect(
        () => UpdateBodyMeasurement(repository, clock: clock)(
          measurement(weightKg: -1).copyWith(id: id),
        ),
        throwsArgumentError,
      );
    });
  });
}
