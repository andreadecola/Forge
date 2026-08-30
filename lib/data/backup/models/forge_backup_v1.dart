import 'backup_data_v1.dart';
import 'backup_metadata.dart';
import '../backup_json_helpers.dart';

/// Radice del formato di backup logico versionato (Backup.1, sezione
/// 7.3): `{"metadata": {...}, "data": {...}}`. Modello esplicito e
/// indipendente da Drift (Backup.2, sezione 10) — mai un
/// `row.toJson()` sulle classi generate.
class ForgeBackupV1 {
  const ForgeBackupV1({required this.metadata, required this.data});

  final BackupMetadata metadata;
  final BackupDataV1 data;

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'data': data.toJson(),
  };

  static ForgeBackupV1 fromJson(Map<String, dynamic> json) {
    const path = r'$';
    return ForgeBackupV1(
      metadata: BackupMetadata.fromJson(
        requireObject(json, 'metadata', path),
        '$path.metadata',
      ),
      data: BackupDataV1.fromJson(
        requireObject(json, 'data', path),
        '$path.data',
      ),
    );
  }
}
