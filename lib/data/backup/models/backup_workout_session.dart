import '../backup_date_codec.dart';
import '../backup_format_exception.dart';
import '../backup_json_helpers.dart';

/// Timer persistito annidato in una sessione (`sessioni_allenamento.timer_*`,
/// Backup.1 sezione 10/11). Preservato come istante (`startedAt`) più
/// durata target, mai come un countdown residuo ricalcolato (Backup.1,
/// sezione 3 — architettura timestamp-first).
class BackupSessionTimer {
  const BackupSessionTimer({
    required this.kind,
    required this.startedAt,
    required this.targetSeconds,
    required this.remainingPaused,
  });

  final String kind;
  final DateTime startedAt;
  final int targetSeconds;
  final int? remainingPaused;

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'startedAt': BackupDateCodec.encodeTimestamp(startedAt),
    'targetSeconds': targetSeconds,
    'remainingPaused': remainingPaused,
  };

  static BackupSessionTimer fromJson(Map<String, dynamic> json, String path) {
    return BackupSessionTimer(
      kind: requireString(json, 'kind', path),
      startedAt: BackupDateCodec.decodeTimestamp(
        requireString(json, 'startedAt', path),
      ),
      targetSeconds: requireInt(json, 'targetSeconds', path),
      remainingPaused: optionalInt(json, 'remainingPaused', path),
    );
  }
}

/// Riga di `sessioni_allenamento` (Backup.1, sezione 1): storico reale,
/// non ricostruibile. [workoutLocalId] è nullable (`ON DELETE SET NULL`
/// a livello DB): [workoutNameSnapshot] resta sempre leggibile anche se
/// la scheda originale non esiste più.
class BackupWorkoutSession {
  const BackupWorkoutSession({
    required this.localId,
    required this.profileLocalId,
    required this.workoutLocalId,
    required this.workoutNameSnapshot,
    required this.status,
    required this.currentExerciseIndex,
    required this.startedAt,
    required this.endedAt,
    required this.isPaused,
    required this.isCompleted,
    required this.timer,
    required this.createdAt,
    required this.updatedAt,
  });

  final int localId;
  final int profileLocalId;
  final int? workoutLocalId;
  final String workoutNameSnapshot;
  final String status;
  final int currentExerciseIndex;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isPaused;
  final bool isCompleted;
  final BackupSessionTimer? timer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'profileLocalId': profileLocalId,
    'workoutLocalId': workoutLocalId,
    'workoutNameSnapshot': workoutNameSnapshot,
    'status': status,
    'currentExerciseIndex': currentExerciseIndex,
    'startedAt': BackupDateCodec.encodeTimestamp(startedAt),
    'endedAt': BackupDateCodec.encodeTimestampOrNull(endedAt),
    'isPaused': isPaused,
    'isCompleted': isCompleted,
    'timer': timer?.toJson(),
    'createdAt': BackupDateCodec.encodeTimestampOrNull(createdAt),
    'updatedAt': BackupDateCodec.encodeTimestampOrNull(updatedAt),
  };

  static BackupWorkoutSession fromJson(Map<String, dynamic> json, String path) {
    final rawTimer = json['timer'];
    if (rawTimer != null && rawTimer is! Map<String, dynamic>) {
      throw BackupFormatException(
        path,
        'Campo "timer" di tipo errato: atteso object o null, trovato '
        '${rawTimer.runtimeType}.',
      );
    }
    return BackupWorkoutSession(
      localId: requireInt(json, 'localId', path),
      profileLocalId: requireInt(json, 'profileLocalId', path),
      workoutLocalId: optionalInt(json, 'workoutLocalId', path),
      workoutNameSnapshot: requireString(json, 'workoutNameSnapshot', path),
      status: requireString(json, 'status', path),
      currentExerciseIndex: requireInt(json, 'currentExerciseIndex', path),
      startedAt: BackupDateCodec.decodeTimestamp(
        requireString(json, 'startedAt', path),
      ),
      endedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'endedAt', path),
      ),
      isPaused: requireBool(json, 'isPaused', path),
      isCompleted: requireBool(json, 'isCompleted', path),
      timer: rawTimer == null
          ? null
          : BackupSessionTimer.fromJson(
              rawTimer as Map<String, dynamic>,
              '$path.timer',
            ),
      createdAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'createdAt', path),
      ),
      updatedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'updatedAt', path),
      ),
    );
  }
}
