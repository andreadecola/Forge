/// Motivo di fallimento del salvataggio (Backup.3, sezione 15): distinto
/// da [BackupExportFailureReason] (quello riguarda l'export logico, non
/// ancora il file). `exportFailed` è l'unico caso in cui il fallimento
/// viene dall'export a monte, non dallo storage.
enum BackupSaveFailureReason {
  exportFailed('EXPORT_FAILED'),
  storageUnavailable('STORAGE_UNAVAILABLE'),
  writeFailed('WRITE_FAILED'),
  invalidResult('INVALID_RESULT'),
  unexpectedPlatformFailure('UNEXPECTED_PLATFORM_FAILURE');

  const BackupSaveFailureReason(this.code);

  final String code;
}

enum BackupSaveOutcome { success, cancelled, failure }

/// Esito del salvataggio su storage esterno (Backup.3, sezione 14): tre
/// esiti distinti, mai un'eccezione generica per il caso "annullato
/// dall'utente" (sezione 14 — CANCELLED non è un errore).
///
/// [savedIdentifier] è un identificatore **opaco** (tipicamente la
/// stringa di un `content://` URI restituito da Storage Access
/// Framework): mai un percorso filesystem assunto (Backup.3, sezione 19/20).
class BackupSaveResult {
  const BackupSaveResult._({
    required this.outcome,
    this.savedIdentifier,
    this.failureReason,
    this.errorMessage,
  });

  factory BackupSaveResult.success(String? savedIdentifier) =>
      BackupSaveResult._(
        outcome: BackupSaveOutcome.success,
        savedIdentifier: savedIdentifier,
      );

  factory BackupSaveResult.cancelled() =>
      const BackupSaveResult._(outcome: BackupSaveOutcome.cancelled);

  factory BackupSaveResult.failure(
    BackupSaveFailureReason reason,
    String message,
  ) => BackupSaveResult._(
    outcome: BackupSaveOutcome.failure,
    failureReason: reason,
    errorMessage: message,
  );

  final BackupSaveOutcome outcome;
  final String? savedIdentifier;
  final BackupSaveFailureReason? failureReason;
  final String? errorMessage;

  bool get isSuccess => outcome == BackupSaveOutcome.success;
  bool get isCancelled => outcome == BackupSaveOutcome.cancelled;
  bool get isFailure => outcome == BackupSaveOutcome.failure;
}
