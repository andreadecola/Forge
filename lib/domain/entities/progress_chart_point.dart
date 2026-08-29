/// A real body measurement projected onto one chart series.
///
/// This is deliberately not persisted. It only carries the data needed by
/// the progress charts and keeps the source measurement id for stable
/// ordering and interaction.
class BodyMetricPoint {
  const BodyMetricPoint({
    required this.measurementId,
    required this.measuredAt,
    required this.value,
  });

  final int? measurementId;
  final DateTime measuredAt;
  final double value;
}

/// A real pressure measurement projected onto the two pressure series.
class PressureChartPoint {
  const PressureChartPoint({
    required this.measurementId,
    required this.measuredAt,
    required this.systolic,
    required this.diastolic,
  });

  final int? measurementId;
  final DateTime measuredAt;
  final int systolic;
  final int diastolic;
}
