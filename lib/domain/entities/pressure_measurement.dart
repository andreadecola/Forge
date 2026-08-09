class PressureMeasurement {
  const PressureMeasurement({
    this.id,
    required this.profileId,
    required this.measuredAt,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.measurementContext,
    this.notes,
  });

  final int? id;
  final int profileId;
  final DateTime measuredAt;
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final String? measurementContext;
  final String? notes;
}
