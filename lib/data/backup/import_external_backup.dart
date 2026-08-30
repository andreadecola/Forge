import 'backup_file_reader.dart';
import 'backup_restore_result.dart';
import 'backup_restore_service.dart';

/// Orchestratore applicativo simmetrico a [CreateExternalBackup]
/// (Backup.3): `pickAndReadBackup() → restore(content)`. Nessuna logica
/// propria oltre alla composizione (Backup.4, sezione 16 applicato al
/// percorso di import).
class ImportExternalBackup {
  const ImportExternalBackup({
    required this.fileReader,
    required this.restoreService,
  });

  final BackupFileReader fileReader;
  final BackupRestoreService restoreService;

  Future<BackupRestoreResult> call() async {
    final readResult = await fileReader.pickAndReadBackup();
    if (readResult.isCancelled) {
      return BackupRestoreResult.cancelled();
    }
    if (readResult.isFailure) {
      return BackupRestoreResult.failure(
        BackupRestoreFailureReason.readFailure,
        readResult.errorMessage!,
      );
    }
    return restoreService.restore(readResult.content!);
  }
}
