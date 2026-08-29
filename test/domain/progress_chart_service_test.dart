import 'package:flutter_test/flutter_test.dart';

import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';
import 'package:forge/domain/services/progress_chart_service.dart';

void main() {
  final now = DateTime(2026, 8, 29, 12);

  BodyMeasurement body({
    required int id,
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

  PressureMeasurement pressure({
    required int id,
    required DateTime measuredAt,
    required int systolic,
    required int diastolic,
  }) {
    return PressureMeasurement(
      id: id,
      profileId: 1,
      measuredAt: measuredAt,
      systolic: systolic,
      diastolic: diastolic,
    );
  }

  group('ProgressChartService', () {
    test('returns empty lists for empty input', () {
      expect(
        ProgressChartService.weightPoints(
          measurements: const [],
          range: ProgressChartRange.all,
          now: now,
        ),
        isEmpty,
      );
      expect(
        ProgressChartService.pressurePoints(
          measurements: const [],
          range: ProgressChartRange.all,
          now: now,
        ),
        isEmpty,
      );
    });

    test('filters null body metrics independently', () {
      final measurements = [
        body(id: 1, measuredAt: now, weightKg: 145),
        body(
          id: 2,
          measuredAt: now.add(const Duration(hours: 1)),
          waistCm: 132,
        ),
      ];

      final weight = ProgressChartService.weightPoints(
        measurements: measurements,
        range: ProgressChartRange.all,
        now: now,
      );
      final waist = ProgressChartService.waistPoints(
        measurements: measurements,
        range: ProgressChartRange.all,
        now: now,
      );

      expect(weight.map((point) => point.measurementId), [1]);
      expect(waist.map((point) => point.measurementId), [2]);
    });

    test('orders body points ASC by measuredAt and then id', () {
      final first = DateTime(2026, 8, 20);
      final measurements = [
        body(id: 5, measuredAt: first, weightKg: 145),
        body(id: 3, measuredAt: first, weightKg: 146),
        body(id: 8, measuredAt: DateTime(2026, 8, 25), weightKg: 144),
      ];

      final points = ProgressChartService.weightPoints(
        measurements: measurements.reversed.toList(),
        range: ProgressChartRange.all,
        now: now,
      );

      expect(points.map((point) => point.measurementId), [3, 5, 8]);
      expect(points.map((point) => point.value), [146, 145, 144]);
    });

    test('orders pressure points and preserves both series values', () {
      final measuredAt = DateTime(2026, 8, 20, 8);
      final points = ProgressChartService.pressurePoints(
        measurements: [
          pressure(id: 9, measuredAt: measuredAt, systolic: 128, diastolic: 82),
          pressure(id: 2, measuredAt: measuredAt, systolic: 120, diastolic: 80),
        ],
        range: ProgressChartRange.all,
        now: now,
      );

      expect(points.map((point) => point.measurementId), [2, 9]);
      expect(points.first.systolic, 120);
      expect(points.first.diastolic, 80);
    });

    test('uses an inclusive lower boundary and excludes future data', () {
      final points = ProgressChartService.weightPoints(
        measurements: [
          body(
            id: 1,
            measuredAt: now.subtract(const Duration(days: 7)),
            weightKg: 150,
          ),
          body(
            id: 2,
            measuredAt: now.subtract(const Duration(days: 7, minutes: 1)),
            weightKg: 151,
          ),
          body(
            id: 3,
            measuredAt: now.add(const Duration(minutes: 1)),
            weightKg: 149,
          ),
        ],
        range: ProgressChartRange.sevenDays,
        now: now,
      );

      expect(points.map((point) => point.measurementId), [1]);
    });

    test('uses an inclusive upper boundary at exactly now', () {
      final points = ProgressChartService.weightPoints(
        measurements: [
          body(id: 1, measuredAt: now, weightKg: 150),
          body(
            id: 2,
            measuredAt: now.add(const Duration(minutes: 1)),
            weightKg: 149,
          ),
        ],
        range: ProgressChartRange.sevenDays,
        now: now,
      );

      expect(points.map((point) => point.measurementId), [1]);
    });

    test('a single-point input yields a single-point series without '
        'crashing', () {
      final points = ProgressChartService.weightPoints(
        measurements: [body(id: 1, measuredAt: now, weightKg: 150)],
        range: ProgressChartRange.all,
        now: now,
      );

      expect(points, hasLength(1));
      expect(points.single.measurementId, 1);
      expect(points.single.value, 150);
    });

    test('applies 30 and 90 day windows and leaves all unfiltered', () {
      final measurements = [
        body(
          id: 1,
          measuredAt: now.subtract(const Duration(days: 30)),
          weightKg: 150,
        ),
        body(
          id: 2,
          measuredAt: now.subtract(const Duration(days: 31)),
          weightKg: 149,
        ),
        body(
          id: 3,
          measuredAt: now.subtract(const Duration(days: 90)),
          weightKg: 148,
        ),
        body(
          id: 4,
          measuredAt: now.subtract(const Duration(days: 91)),
          weightKg: 147,
        ),
      ];

      expect(
        ProgressChartService.weightPoints(
          measurements: measurements,
          range: ProgressChartRange.thirtyDays,
          now: now,
        ).map((point) => point.measurementId),
        [1],
      );
      expect(
        ProgressChartService.weightPoints(
          measurements: measurements,
          range: ProgressChartRange.ninetyDays,
          now: now,
        ).map((point) => point.measurementId),
        [3, 2, 1],
      );
      expect(
        ProgressChartService.weightPoints(
          measurements: measurements,
          range: ProgressChartRange.all,
          now: now,
        ).length,
        4,
      );
    });

    test('keeps one point and partial body records valid', () {
      final points = ProgressChartService.waistPoints(
        measurements: [
          body(id: 1, measuredAt: now, waistCm: 132),
          body(id: 2, measuredAt: now, weightKg: 145),
        ],
        range: ProgressChartRange.all,
        now: now,
      );

      expect(points, hasLength(1));
      expect(points.single.value, 132);
    });

    test('preparation remains deterministic for a large unordered dataset', () {
      final measurements = [
        for (var index = 0; index < 1000; index++)
          body(
            id: index + 1,
            measuredAt: now.subtract(Duration(hours: index)),
            weightKg: index.isEven ? 100 + index.toDouble() : null,
            waistCm: index.isOdd ? 80 + index.toDouble() : null,
          ),
      ].reversed.toList();

      final points = ProgressChartService.weightPoints(
        measurements: measurements,
        range: ProgressChartRange.all,
        now: now,
      );

      expect(points, hasLength(500));
      expect(points.first.measuredAt.isBefore(points.last.measuredAt), isTrue);
      expect(points.every((point) => point.measurementId!.isOdd), isTrue);
    });
  });
}
