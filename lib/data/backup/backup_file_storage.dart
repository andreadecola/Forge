import 'backup_save_result.dart';

/// Astrazione dello storage esterno di backup (Backup.3, sezione 13): il
/// layer core (`BackupMapper`/`BackupJsonCodec`/`BackupValidator`/
/// `BackupExportService`) non conosce alcun dettaglio di piattaforma o
/// plugin — questa interfaccia è l'unico punto di contatto.
///
/// [content] è il JSON **già validato** da [BackupExportService]: chi
/// implementa questa interfaccia non deve mai ri-serializzarlo o
/// ri-validarlo (Backup.3, sezione 18), solo scriverlo esattamente
/// com'è.
abstract class BackupFileStorage {
  Future<BackupSaveResult> saveBackup({
    required String suggestedFileName,
    required String content,
  });
}
