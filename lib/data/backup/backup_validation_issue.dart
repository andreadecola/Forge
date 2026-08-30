/// Categoria di un problema trovato da `BackupValidator` (Backup.2,
/// sezione 47): distinto da `BackupFormatException`, che riguarda solo
/// errori strutturali di parsing (tipo/campo), mai semantici.
enum BackupValidationIssueCode {
  unsupportedFormatVersion('UNSUPPORTED_FORMAT_VERSION'),
  duplicateLocalId('DUPLICATE_LOCAL_ID'),
  danglingReference('DANGLING_REFERENCE'),
  unknownCatalogCode('UNKNOWN_CATALOG_CODE'),
  unrecognizedEnumValue('UNRECOGNIZED_ENUM_VALUE'),
  domainInvariantViolation('DOMAIN_INVARIANT_VIOLATION'),
  missingRequiredTimestamp('MISSING_REQUIRED_TIMESTAMP');

  const BackupValidationIssueCode(this.code);

  final String code;
}

/// Un singolo problema semantico trovato in un [ForgeBackupV1] già
/// strutturalmente valido (già passato da `BackupJsonCodec.decode`
/// senza eccezioni). [path] individua la riga/campo coinvolto, per un
/// report utile senza dover ripetere il controllo manualmente.
class BackupValidationIssue {
  const BackupValidationIssue({
    required this.code,
    required this.path,
    required this.message,
  });

  final BackupValidationIssueCode code;
  final String path;
  final String message;

  @override
  String toString() => '[${code.code}] $path: $message';
}
