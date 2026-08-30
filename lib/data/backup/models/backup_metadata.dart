import '../backup_date_codec.dart';
import '../backup_format_exception.dart';
import '../backup_json_helpers.dart';

/// Metadata del backup (Backup.1, sezione 7.2): `backupFormatVersion` è
/// la versione del **formato JSON**, indipendente da `databaseVersion`
/// (lo `schemaVersion` Drift al momento dell'export). `catalogVersion` è
/// solo diagnostica (mappa `tipoCatalogo → versione`, letta da
/// `versioni_catalogo`): non viene mai usata per decidere se un backup è
/// importabile, quel giudizio spetta a `backupFormatVersion` e alla
/// risoluzione dei `code` di catalogo (Backup.1, sezione 5).
class BackupMetadata {
  const BackupMetadata({
    required this.backupFormatVersion,
    required this.databaseVersion,
    required this.catalogVersion,
    required this.appVersion,
    required this.exportedAt,
  });

  final int backupFormatVersion;
  final int databaseVersion;

  /// `tipoCatalogo → versione`, es. `{"ESERCIZI": 2}`.
  final Map<String, int> catalogVersion;
  final String appVersion;
  final DateTime exportedAt;

  Map<String, dynamic> toJson() => {
    'backupFormatVersion': backupFormatVersion,
    'databaseVersion': databaseVersion,
    'catalogVersion': catalogVersion,
    'appVersion': appVersion,
    'exportedAt': BackupDateCodec.encodeTimestamp(exportedAt),
  };

  static BackupMetadata fromJson(Map<String, dynamic> json, String path) {
    final rawCatalogVersion = requireObject(json, 'catalogVersion', path);
    final catalogVersion = <String, int>{};
    for (final entry in rawCatalogVersion.entries) {
      final value = entry.value;
      if (value is! int) {
        throw BackupFormatException(
          '$path.catalogVersion.${entry.key}',
          'Versione catalogo di tipo errato: atteso int, trovato '
              '${value.runtimeType}.',
        );
      }
      catalogVersion[entry.key] = value;
    }
    return BackupMetadata(
      backupFormatVersion: requireInt(json, 'backupFormatVersion', path),
      databaseVersion: requireInt(json, 'databaseVersion', path),
      catalogVersion: catalogVersion,
      appVersion: requireString(json, 'appVersion', path),
      exportedAt: BackupDateCodec.decodeTimestamp(
        requireString(json, 'exportedAt', path),
      ),
    );
  }
}
