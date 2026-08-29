import '../entities/body_measurement.dart';
import '../entities/pressure_measurement.dart';
import '../entities/progress_chart_point.dart';

enum ProgressChartRange { sevenDays, thirtyDays, ninetyDays, all }

/// Pure preparation of historical data for the progress charts.
///
/// The service does not access persistence, Riverpod, or the system clock.
/// Every returned point maps to one real measurement; null body metrics are
/// omitted and no interpolation, fill, or aggregation is performed.
abstract final class ProgressChartService {
  static List<BodyMetricPoint> weightPoints({
    required List<BodyMeasurement> measurements,
    required ProgressChartRange range,
    required DateTime now,
  }) {
    return _bodyPoints(
      measurements: measurements,
      range: range,
      now: now,
      valueOf: (measurement) => measurement.weightKg,
    );
  }

  static List<BodyMetricPoint> waistPoints({
    required List<BodyMeasurement> measurements,
    required ProgressChartRange range,
    required DateTime now,
  }) {
    return _bodyPoints(
      measurements: measurements,
      range: range,
      now: now,
      valueOf: (measurement) => measurement.waistCm,
    );
  }

  static List<PressureChartPoint> pressurePoints({
    required List<PressureMeasurement> measurements,
    required ProgressChartRange range,
    required DateTime now,
  }) {
    final filtered =
        measurements
            .where(
              (measurement) => _isInRange(
                measuredAt: measurement.measuredAt,
                range: range,
                now: now,
              ),
            )
            .toList()
          ..sort(_comparePressureMeasurements);

    return [
      for (final measurement in filtered)
        PressureChartPoint(
          measurementId: measurement.id,
          measuredAt: measurement.measuredAt,
          systolic: measurement.systolic,
          diastolic: measurement.diastolic,
        ),
    ];
  }

  static List<BodyMetricPoint> _bodyPoints({
    required List<BodyMeasurement> measurements,
    required ProgressChartRange range,
    required DateTime now,
    required double? Function(BodyMeasurement) valueOf,
  }) {
    final filtered =
        measurements
            .where(
              (measurement) =>
                  valueOf(measurement) != null &&
                  _isInRange(
                    measuredAt: measurement.measuredAt,
                    range: range,
                    now: now,
                  ),
            )
            .toList()
          ..sort(_compareBodyMeasurements);

    return [
      for (final measurement in filtered)
        BodyMetricPoint(
          measurementId: measurement.id,
          measuredAt: measurement.measuredAt,
          value: valueOf(measurement)!,
        ),
    ];
  }

  static bool _isInRange({
    required DateTime measuredAt,
    required ProgressChartRange range,
    required DateTime now,
  }) {
    if (range == ProgressChartRange.all) return true;

    final days = switch (range) {
      ProgressChartRange.sevenDays => 7,
      ProgressChartRange.thirtyDays => 30,
      ProgressChartRange.ninetyDays => 90,
      ProgressChartRange.all => 0,
    };
    final start = now.subtract(Duration(days: days));

    // The lower boundary is inclusive. Future-dated data is excluded so a
    // bounded range always describes the interval ending at [now].
    return !measuredAt.isBefore(start) && !measuredAt.isAfter(now);
  }

  static int _compareBodyMeasurements(
    BodyMeasurement left,
    BodyMeasurement right,
  ) {
    final byDate = left.measuredAt.compareTo(right.measuredAt);
    if (byDate != 0) return byDate;
    return (left.id ?? 0).compareTo(right.id ?? 0);
  }

  static int _comparePressureMeasurements(
    PressureMeasurement left,
    PressureMeasurement right,
  ) {
    final byDate = left.measuredAt.compareTo(right.measuredAt);
    if (byDate != 0) return byDate;
    return (left.id ?? 0).compareTo(right.id ?? 0);
  }
}
