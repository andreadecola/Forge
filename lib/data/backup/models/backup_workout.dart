import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `allenamenti` (Backup.1, sezione 1). [origin] preserva la
/// stringa `.code` reale (`"USER"`/`"FORGE_ENGINE"`/`"SYSTEM"`, mai
/// usato quest'ultimo — Backup.1, sezione 9/19/20): un Workout
/// `FORGE_ENGINE` è persistito esattamente come uno `USER`, nessuna
/// rigenerazione durante l'export. [isActive] distingue le schede
/// archiviate (`false`): sono comunque incluse (Backup.1, sezione 62).
class BackupWorkout {
  const BackupWorkout({
    required this.localId,
    required this.profileLocalId,
    required this.name,
    required this.description,
    required this.type,
    required this.level,
    required this.estimatedDurationMinutes,
    required this.status,
    required this.origin,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int localId;
  final int profileLocalId;
  final String name;
  final String? description;
  final String type;
  final int level;
  final int? estimatedDurationMinutes;
  final String status;
  final String origin;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'profileLocalId': profileLocalId,
    'name': name,
    'description': description,
    'type': type,
    'level': level,
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'status': status,
    'origin': origin,
    'isActive': isActive,
    'createdAt': BackupDateCodec.encodeTimestampOrNull(createdAt),
    'updatedAt': BackupDateCodec.encodeTimestampOrNull(updatedAt),
  };

  static BackupWorkout fromJson(Map<String, dynamic> json, String path) {
    return BackupWorkout(
      localId: requireInt(json, 'localId', path),
      profileLocalId: requireInt(json, 'profileLocalId', path),
      name: requireString(json, 'name', path),
      description: optionalString(json, 'description', path),
      type: requireString(json, 'type', path),
      level: requireInt(json, 'level', path),
      estimatedDurationMinutes: optionalInt(
        json,
        'estimatedDurationMinutes',
        path,
      ),
      status: requireString(json, 'status', path),
      origin: requireString(json, 'origin', path),
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
