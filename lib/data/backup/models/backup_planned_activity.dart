import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `attivita_pianificate` (Backup.1, sezione 1/17/30): preserva i
/// link espliciti Milestone 8.5 (`workoutSessionLocalId`/
/// `walkingSessionLocalId`) come riferimenti interni al backup, mai come
/// stato derivato — lo stato "in corso"/"completata" non è mai
/// persistito qui (Backup.1, sezione 8) e non compare in questo modello.
class BackupPlannedActivity {
  const BackupPlannedActivity({
    required this.localId,
    required this.profileLocalId,
    required this.scheduledDate,
    required this.type,
    required this.workoutLocalId,
    required this.plannedDurationMinutes,
    required this.status,
    required this.origin,
    required this.notes,
    required this.workoutSessionLocalId,
    required this.walkingSessionLocalId,
    required this.createdAt,
    required this.updatedAt,
  });

  final int localId;
  final int profileLocalId;
  final DateTime scheduledDate;
  final String type;
  final int? workoutLocalId;
  final int? plannedDurationMinutes;
  final String status;
  final String origin;
  final String? notes;
  final int? workoutSessionLocalId;
  final int? walkingSessionLocalId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'profileLocalId': profileLocalId,
    'scheduledDate': BackupDateCodec.encodeDateOnly(scheduledDate),
    'type': type,
    'workoutLocalId': workoutLocalId,
    'plannedDurationMinutes': plannedDurationMinutes,
    'status': status,
    'origin': origin,
    'notes': notes,
    'workoutSessionLocalId': workoutSessionLocalId,
    'walkingSessionLocalId': walkingSessionLocalId,
    'createdAt': BackupDateCodec.encodeTimestampOrNull(createdAt),
    'updatedAt': BackupDateCodec.encodeTimestampOrNull(updatedAt),
  };

  static BackupPlannedActivity fromJson(
    Map<String, dynamic> json,
    String path,
  ) {
    return BackupPlannedActivity(
      localId: requireInt(json, 'localId', path),
      profileLocalId: requireInt(json, 'profileLocalId', path),
      scheduledDate: BackupDateCodec.decodeDateOnly(
        requireString(json, 'scheduledDate', path),
      ),
      type: requireString(json, 'type', path),
      workoutLocalId: optionalInt(json, 'workoutLocalId', path),
      plannedDurationMinutes: optionalInt(json, 'plannedDurationMinutes', path),
      status: requireString(json, 'status', path),
      origin: requireString(json, 'origin', path),
      notes: optionalString(json, 'notes', path),
      workoutSessionLocalId: optionalInt(json, 'workoutSessionLocalId', path),
      walkingSessionLocalId: optionalInt(json, 'walkingSessionLocalId', path),
      createdAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'createdAt', path),
      ),
      updatedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'updatedAt', path),
      ),
    );
  }
}
