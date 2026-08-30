import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `allenamenti_esercizi` (Backup.1, sezione 1). [exerciseCode]
/// è il `codice` stabile del catalogo (Backup.1, sezione 5/15/16): **mai**
/// l'ID numerico `idEsercizio`, non portabile tra installazioni. Risolto
/// in fase di export; se la risoluzione fallisce l'intero export fallisce
/// (Backup.2, sezione 16 — nessun riferimento nullo silenzioso).
class BackupWorkoutExercise {
  const BackupWorkoutExercise({
    required this.localId,
    required this.workoutLocalId,
    required this.exerciseCode,
    required this.order,
    required this.sets,
    required this.repetitions,
    required this.durationSeconds,
    required this.restSeconds,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int localId;
  final int workoutLocalId;
  final String exerciseCode;
  final int order;
  final int? sets;
  final int? repetitions;
  final int? durationSeconds;
  final int? restSeconds;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'workoutLocalId': workoutLocalId,
    'exerciseCode': exerciseCode,
    'order': order,
    'sets': sets,
    'repetitions': repetitions,
    'durationSeconds': durationSeconds,
    'restSeconds': restSeconds,
    'notes': notes,
    'isActive': isActive,
    'createdAt': BackupDateCodec.encodeTimestampOrNull(createdAt),
    'updatedAt': BackupDateCodec.encodeTimestampOrNull(updatedAt),
  };

  static BackupWorkoutExercise fromJson(
    Map<String, dynamic> json,
    String path,
  ) {
    return BackupWorkoutExercise(
      localId: requireInt(json, 'localId', path),
      workoutLocalId: requireInt(json, 'workoutLocalId', path),
      exerciseCode: requireString(json, 'exerciseCode', path),
      order: requireInt(json, 'order', path),
      sets: optionalInt(json, 'sets', path),
      repetitions: optionalInt(json, 'repetitions', path),
      durationSeconds: optionalInt(json, 'durationSeconds', path),
      restSeconds: optionalInt(json, 'restSeconds', path),
      notes: optionalString(json, 'notes', path),
      isActive: requireBool(json, 'isActive', path),
      createdAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'createdAt', path),
      ),
      updatedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'updatedAt', path),
      ),
    );
  }
}
