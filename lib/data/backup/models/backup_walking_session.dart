import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `camminate` (Backup.1, sezione 1): storico reale, incluse le
/// sessioni ancora `IN_PROGRESS` (Backup.1, sezione 63 — non solo
/// record "positivi").
class BackupWalkingSession {
  const BackupWalkingSession({
    required this.localId,
    required this.profileLocalId,
    required this.startedAt,
    required this.endedAt,
    required this.distanceMeters,
    required this.steps,
    required this.isPaused,
    required this.pauseStartedAt,
    required this.accumulatedPauseSeconds,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int localId;
  final int profileLocalId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? distanceMeters;
  final int? steps;
  final bool isPaused;
  final DateTime? pauseStartedAt;
  final int accumulatedPauseSeconds;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'profileLocalId': profileLocalId,
    'startedAt': BackupDateCodec.encodeTimestamp(startedAt),
    'endedAt': BackupDateCodec.encodeTimestampOrNull(endedAt),
    'distanceMeters': distanceMeters,
    'steps': steps,
    'isPaused': isPaused,
    'pauseStartedAt': BackupDateCodec.encodeTimestampOrNull(pauseStartedAt),
    'accumulatedPauseSeconds': accumulatedPauseSeconds,
    'status': status,
    'notes': notes,
    'createdAt': BackupDateCodec.encodeTimestampOrNull(createdAt),
    'updatedAt': BackupDateCodec.encodeTimestampOrNull(updatedAt),
  };

  static BackupWalkingSession fromJson(Map<String, dynamic> json, String path) {
    return BackupWalkingSession(
      localId: requireInt(json, 'localId', path),
      profileLocalId: requireInt(json, 'profileLocalId', path),
      startedAt: BackupDateCodec.decodeTimestamp(
        requireString(json, 'startedAt', path),
      ),
      endedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'endedAt', path),
      ),
      distanceMeters: optionalInt(json, 'distanceMeters', path),
      steps: optionalInt(json, 'steps', path),
      isPaused: requireBool(json, 'isPaused', path),
      pauseStartedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'pauseStartedAt', path),
      ),
      accumulatedPauseSeconds: requireInt(
        json,
        'accumulatedPauseSeconds',
        path,
      ),
      status: requireString(json, 'status', path),
      notes: optionalString(json, 'notes', path),
      createdAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'createdAt', path),
      ),
      updatedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'updatedAt', path),
      ),
    );
  }
}
