import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `sessioni_esercizi` (Backup.1, sezione 1): snapshot reale dei
/// parametri al momento dell'avvio, più il progresso raggiunto.
/// [exerciseCode] risolto dal catalogo, mai l'ID numerico (stesso
/// principio di [BackupWorkoutExercise]). [workoutExerciseLocalId] è
/// nullable (`ON DELETE SET NULL`): la riga scheda originale potrebbe
/// non esistere più.
class BackupSessionExercise {
  const BackupSessionExercise({
    required this.localId,
    required this.sessionLocalId,
    required this.workoutExerciseLocalId,
    required this.exerciseCode,
    required this.order,
    required this.totalSets,
    required this.completedSets,
    required this.repetitions,
    required this.durationSeconds,
    required this.restSeconds,
    required this.isSkipped,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final int localId;
  final int sessionLocalId;
  final int? workoutExerciseLocalId;
  final String exerciseCode;
  final int order;
  final int totalSets;
  final int completedSets;
  final int? repetitions;
  final int? durationSeconds;
  final int? restSeconds;
  final bool isSkipped;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'sessionLocalId': sessionLocalId,
    'workoutExerciseLocalId': workoutExerciseLocalId,
    'exerciseCode': exerciseCode,
    'order': order,
    'totalSets': totalSets,
    'completedSets': completedSets,
    'repetitions': repetitions,
    'durationSeconds': durationSeconds,
    'restSeconds': restSeconds,
    'isSkipped': isSkipped,
    'isCompleted': isCompleted,
    'createdAt': BackupDateCodec.encodeTimestampOrNull(createdAt),
    'updatedAt': BackupDateCodec.encodeTimestampOrNull(updatedAt),
  };

  static BackupSessionExercise fromJson(
    Map<String, dynamic> json,
    String path,
  ) {
    return BackupSessionExercise(
      localId: requireInt(json, 'localId', path),
      sessionLocalId: requireInt(json, 'sessionLocalId', path),
      workoutExerciseLocalId: optionalInt(json, 'workoutExerciseLocalId', path),
      exerciseCode: requireString(json, 'exerciseCode', path),
      order: requireInt(json, 'order', path),
      totalSets: requireInt(json, 'totalSets', path),
      completedSets: requireInt(json, 'completedSets', path),
      repetitions: optionalInt(json, 'repetitions', path),
      durationSeconds: optionalInt(json, 'durationSeconds', path),
      restSeconds: optionalInt(json, 'restSeconds', path),
      isSkipped: requireBool(json, 'isSkipped', path),
      isCompleted: requireBool(json, 'isCompleted', path),
      createdAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'createdAt', path),
      ),
      updatedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'updatedAt', path),
      ),
    );
  }
}
