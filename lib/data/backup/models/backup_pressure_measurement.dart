import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `misurazioni_pressione` (Backup.1, sezione 1). Nessuna
/// interpretazione clinica: valori grezzi così come persistiti
/// (Backup.1, sezione 26).
class BackupPressureMeasurement {
  const BackupPressureMeasurement({
    required this.localId,
    required this.profileLocalId,
    required this.measuredAt,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.measurementContext,
    required this.notes,
  });

  final int localId;
  final int profileLocalId;
  final DateTime measuredAt;
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final String? measurementContext;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'profileLocalId': profileLocalId,
    'measuredAt': BackupDateCodec.encodeTimestamp(measuredAt),
    'systolic': systolic,
    'diastolic': diastolic,
    'heartRate': heartRate,
    'measurementContext': measurementContext,
    'notes': notes,
  };

  static BackupPressureMeasurement fromJson(
    Map<String, dynamic> json,
    String path,
  ) {
    return BackupPressureMeasurement(
      localId: requireInt(json, 'localId', path),
      profileLocalId: requireInt(json, 'profileLocalId', path),
      measuredAt: BackupDateCodec.decodeTimestamp(
        requireString(json, 'measuredAt', path),
      ),
      systolic: requireInt(json, 'systolic', path),
      diastolic: requireInt(json, 'diastolic', path),
      heartRate: optionalInt(json, 'heartRate', path),
      measurementContext: optionalString(json, 'measurementContext', path),
      notes: optionalString(json, 'notes', path),
    );
  }
}
