import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';
import 'package:forge/domain/services/pressure_progress_service.dart';

/// Test di [PressureProgressService] (Milestone 7.3): puro, senza DB —
/// verifica order-invariance e tie-break per id a parità di `measuredAt`.
void main() {
  PressureMeasurement measurement({
    int? id,
    required DateTime measuredAt,
    int systolic = 120,
    int diastolic = 80,
  }) {
    return PressureMeasurement(
      id: id,
      profileId: 1,
      measuredAt: measuredAt,
      systolic: systolic,
      diastolic: diastolic,
    );
  }

  test('lista vuota -> null', () {
    expect(PressureProgressService.latest(const []), isNull);
  });

  test('singola misurazione -> quella stessa', () {
    final m = measurement(id: 1, measuredAt: DateTime(2026, 1, 1));
    expect(PressureProgressService.latest([m]), same(m));
  });

  test('multiple misurazioni -> la più recente per measuredAt', () {
    final oldest = measurement(id: 1, measuredAt: DateTime(2026, 1, 1));
    final newest = measurement(
      id: 2,
      measuredAt: DateTime(2026, 1, 15),
      systolic: 118,
    );
    final middle = measurement(id: 3, measuredAt: DateTime(2026, 1, 8));

    final latest = PressureProgressService.latest([oldest, newest, middle]);

    expect(latest, same(newest));
  });

  test('è invariante rispetto all\'ordine della lista in ingresso', () {
    final measurements = [
      measurement(id: 1, measuredAt: DateTime(2026, 1, 1)),
      measurement(id: 2, measuredAt: DateTime(2026, 1, 15)),
      measurement(id: 3, measuredAt: DateTime(2026, 1, 8)),
    ];

    final forward = PressureProgressService.latest(measurements);
    final reversed = PressureProgressService.latest(
      measurements.reversed.toList(),
    );

    expect(forward!.id, 2);
    expect(reversed!.id, 2);
  });

  test('a parità di measuredAt sceglie l\'id più alto', () {
    final sameInstant = DateTime(2026, 1, 1, 8);
    final latest = PressureProgressService.latest([
      measurement(id: 5, measuredAt: sameInstant, systolic: 120),
      measurement(id: 9, measuredAt: sameInstant, systolic: 130),
      measurement(id: 2, measuredAt: sameInstant, systolic: 110),
    ]);

    expect(latest!.id, 9);
    expect(latest.systolic, 130);
  });
}
