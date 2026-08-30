/// Motivo di fallimento della lettura di un file di backup esistente
/// (Backup.4, sezione 13/14).
enum BackupReadFailureReason {
  storageUnavailable('STORAGE_UNAVAILABLE'),
  fileTooLarge('FILE_TOO_LARGE'),
  invalidEncoding('INVALID_ENCODING'),
  unexpectedPlatformFailure('UNEXPECTED_PLATFORM_FAILURE');

  const BackupReadFailureReason(this.code);

  final String code;
}

enum BackupReadOutcome { success, cancelled, failure }

/// Esito della selezione/lettura di un file di backup (Backup.4, sezione
/// 12/13): [content] è la stringa UTF-8 già decodificata, non ancora
/// interpretata come JSON (quello spetta a `BackupJsonCodec`, sezione 16).
class BackupReadResult {
  const BackupReadResult._({
    required this.outcome,
    this.content,
    this.failureReason,
    this.errorMessage,
  });

  factory BackupReadResult.success(String content) =>
      BackupReadResult._(outcome: BackupReadOutcome.success, content: content);

  factory BackupReadResult.cancelled() =>
      const BackupReadResult._(outcome: BackupReadOutcome.cancelled);

  factory BackupReadResult.failure(
    BackupReadFailureReason reason,
    String message,
  ) => BackupReadResult._(
    outcome: BackupReadOutcome.failure,
    failureReason: reason,
    errorMessage: message,
  );

  final BackupReadOutcome outcome;
  final String? content;
  final BackupReadFailureReason? failureReason;
  final String? errorMessage;

  bool get isSuccess => outcome == BackupReadOutcome.success;
  bool get isCancelled => outcome == BackupReadOutcome.cancelled;
  bool get isFailure => outcome == BackupReadOutcome.failure;
}
