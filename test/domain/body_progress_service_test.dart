import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/services/body_progress_service.dart';

/// Test di [BodyProgressService] (Milestone 7.2): puro, senza DB — verifica
/// order-invariance e tie-break per id a parità di `measuredAt`.
void main() {
  UserProfile profile({double initialWeightKg = 80}) {
    return UserProfile(
      name: 'Alex',
      birthDate: DateTime(1990, 1, 1),
      heightCm: 175,
      initialWeightKg: initialWeightKg,
      preferredWalkMinutes: 30,
      equipmentBudgetLimit: 50,
      startDate: DateTime(2026, 1, 1),
    );
  }

  BodyMeasurement measurement({
    int? id,
    required DateTime measuredAt,
    double? weightKg,
    double? waistCm,
  }) {
    return BodyMeasurement(
      id: id,
      profileId: 1,
      measuredAt: measuredAt,
      weightKg: weightKg,
      waistCm: waistCm,
    );
  }

  test('nessuna misurazione: solo la baseline, tutto il resto null', () {
    final summary = BodyProgressService.summarize(
      profile: profile(),
      measurements: const [],
    );

    expect(summary.initialWeightKg, 80);
    expect(summary.latestWeightKg, isNull);
    expect(summary.latestWeightMeasuredAt, isNull);
    expect(summary.weightDeltaKg, isNull);
    expect(summary.latestWaistCm, isNull);
    expect(summary.latestWaistMeasuredAt, isNull);
  });

  test('calcola peso/girovita più recenti e il delta rispetto alla '
      'baseline', () {
    final summary = BodyProgressService.summarize(
      profile: profile(initialWeightKg: 80),
      measurements: [
        measurement(
          id: 1,
          measuredAt: DateTime(2026, 1, 1),
          weightKg: 80,
          waistCm: 90,
        ),
        measurement(
          id: 2,
          measuredAt: DateTime(2026, 1, 15),
          weightKg: 77.5,
          waistCm: 87,
        ),
      ],
    );

    expect(summary.latestWeightKg, 77.5);
    expect(summary.latestWeightMeasuredAt, DateTime(2026, 1, 15));
    expect(summary.weightDeltaKg, closeTo(-2.5, 0.0001));
    expect(summary.latestWaistCm, 87);
    expect(summary.latestWaistMeasuredAt, DateTime(2026, 1, 15));
  });

  test('è invariante rispetto all\'ordine della lista in ingresso', () {
    final measurements = [
      measurement(id: 1, measuredAt: DateTime(2026, 1, 1), weightKg: 80),
      measurement(id: 2, measuredAt: DateTime(2026, 1, 15), weightKg: 77.5),
      measurement(id: 3, measuredAt: DateTime(2026, 1, 8), weightKg: 79),
    ];

    final forward = BodyProgressService.summarize(
      profile: profile(),
      measurements: measurements,
    );
    final reversed = BodyProgressService.summarize(
      profile: profile(),
      measurements: measurements.reversed.toList(),
    );

    expect(forward.latestWeightKg, 77.5);
    expect(reversed.latestWeightKg, 77.5);
    expect(forward.latestWeightMeasuredAt, reversed.latestWeightMeasuredAt);
  });

  test('a parità di measuredAt sceglie l\'id più alto', () {
    final sameInstant = DateTime(2026, 1, 1, 8);
    final summary = BodyProgressService.summarize(
      profile: profile(),
      measurements: [
        measurement(id: 5, measuredAt: sameInstant, weightKg: 80),
        measurement(id: 9, measuredAt: sameInstant, weightKg: 81),
        measurement(id: 2, measuredAt: sameInstant, weightKg: 79),
      ],
    );

    expect(summary.latestWeightKg, 81);
  });

  test('"solo girovita" non produce un peso più recente fittizio', () {
    final summary = BodyProgressService.summarize(
      profile: profile(initialWeightKg: 80),
      measurements: [
        measurement(id: 1, measuredAt: DateTime(2026, 1, 1), weightKg: 79),
        measurement(id: 2, measuredAt: DateTime(2026, 1, 15), waistCm: 88),
      ],
    );

    // La misurazione più recente in assoluto è "solo girovita": il peso
    // più recente resta quello della riga precedente, non null.
    expect(summary.latestWeightKg, 79);
    expect(summary.latestWeightMeasuredAt, DateTime(2026, 1, 1));
    expect(summary.latestWaistCm, 88);
    expect(summary.latestWaistMeasuredAt, DateTime(2026, 1, 15));
  });

  test('peso e girovita sono tracciati indipendentemente: nessuna '
      'misurazione con peso -> weightDeltaKg null anche con girovita '
      'presente', () {
    final summary = BodyProgressService.summarize(
      profile: profile(initialWeightKg: 80),
      measurements: [
        measurement(id: 1, measuredAt: DateTime(2026, 1, 1), waistCm: 90),
      ],
    );

    expect(summary.latestWeightKg, isNull);
    expect(summary.weightDeltaKg, isNull);
    expect(summary.latestWaistCm, 90);
  });

  test('delta positivo quando il peso attuale supera la baseline', () {
    final summary = BodyProgressService.summarize(
      profile: profile(initialWeightKg: 70),
      measurements: [
        measurement(id: 1, measuredAt: DateTime(2026, 1, 1), weightKg: 72),
      ],
    );

    expect(summary.weightDeltaKg, closeTo(2, 0.0001));
  });
}
