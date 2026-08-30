import 'models/backup_metadata.dart';

/// Motivo di fallimento del restore (Backup.4, sezione 64): ogni fase
/// del flusso ha una categoria distinta, per non confondere "file non
/// valido" con "versione incompatibile" o "scrittura fallita".
enum BackupRestoreFailureReason {
  readFailure('READ_FAILURE'),
  invalidBackup('INVALID_BACKUP'),
  incompatibleVersion('INCOMPATIBLE_VERSION'),
  catalogMismatch('CATALOG_MISMATCH'),
  restoreFailure('RESTORE_FAILURE'),
  verificationFailure('VERIFICATION_FAILURE');

  const BackupRestoreFailureReason(this.code);

  final String code;
}

enum BackupRestoreOutcome { success, cancelled, failure }

/// Esito del restore (Backup.4, sezione 64). [safetyBackupMetadata] è
/// **solo** il metadata del backup preventivo creato prima del REPLACE
/// (Backup.4, sezione 115) — mai il suo contenuto completo, per non
/// esporre/loggare dati personali (sezione 116).
class BackupRestoreResult {
  const BackupRestoreResult._({
    required this.outcome,
    this.safetyBackupMetadata,
    this.failureReason,
    this.errorMessage,
  });

  factory BackupRestoreResult.success({
    required BackupMetadata safetyBackupMetadata,
  }) => BackupRestoreResult._(
    outcome: BackupRestoreOutcome.success,
    safetyBackupMetadata: safetyBackupMetadata,
  );

  factory BackupRestoreResult.cancelled() =>
      const BackupRestoreResult._(outcome: BackupRestoreOutcome.cancelled);

  factory BackupRestoreResult.failure(
    BackupRestoreFailureReason reason,
    String message,
  ) => BackupRestoreResult._(
    outcome: BackupRestoreOutcome.failure,
    failureReason: reason,
    errorMessage: message,
  );

  final BackupRestoreOutcome outcome;
  final BackupMetadata? safetyBackupMetadata;
  final BackupRestoreFailureReason? failureReason;
  final String? errorMessage;

  bool get isSuccess => outcome == BackupRestoreOutcome.success;
  bool get isCancelled => outcome == BackupRestoreOutcome.cancelled;
  bool get isFailure => outcome == BackupRestoreOutcome.failure;
}
