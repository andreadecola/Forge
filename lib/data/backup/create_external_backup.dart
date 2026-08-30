import 'backup_export_service.dart';
import 'backup_file_storage.dart';
import 'backup_filename.dart';
import 'backup_save_result.dart';

/// Orchestratore applicativo di Backup.3 (sezione 16): compone
/// [BackupExportService] (Backup.2, invariato — sezione 35) con
/// [BackupFileStorage], senza contenere logica propria di export o di
/// scrittura file.
///
/// `export() → JSON validato → filename → storage.saveBackup() → result`.
/// Se l'export fallisce, **non** viene mai invocato lo storage (Backup.3,
/// sezione 39: nessun picker aperto per un backup non valido).
class CreateExternalBackup {
  const CreateExternalBackup({
    required this.exportService,
    required this.fileStorage,
  });

  final BackupExportService exportService;
  final BackupFileStorage fileStorage;

  Future<BackupSaveResult> call() async {
    final exportResult = await exportService.export();
    if (!exportResult.isSuccess) {
      final reasons = exportResult.errors.map((e) => e.toString()).join('; ');
      return BackupSaveResult.failure(
        BackupSaveFailureReason.exportFailed,
        'Esportazione del backup fallita: $reasons',
      );
    }

    // Stesso istante logico per metadata.exportedAt (già fissato
    // dentro l'export appena completato) e per il nome file (Backup.3,
    // sezione 10): un'unica chiamata al clock condiviso, mai una seconda
    // lettura che potrebbe restituire un secondo diverso.
    final fileName = BackupFilename.generate(
      exportResult.backup!.metadata.exportedAt,
    );

    return fileStorage.saveBackup(
      suggestedFileName: fileName,
      content: exportResult.json!,
    );
  }
}
