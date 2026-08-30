import 'models/forge_backup_v1.dart';

/// Categoria di fallimento dell'export (Backup.2, sezione 55): distingue
/// dove il processo si è fermato, per un messaggio/diagnostica utile.
enum BackupExportFailureReason {
  databaseRead('DATABASE_READ'),
  catalogResolution('CATALOG_RESOLUTION'),
  serialization('SERIALIZATION'),
  selfCheckParsing('SELF_CHECK_PARSING'),
  selfCheckValidation('SELF_CHECK_VALIDATION');

  const BackupExportFailureReason(this.code);

  final String code;
}

/// Un singolo motivo di fallimento dell'export, con messaggio
/// descrittivo. Stesso stile di `PersistGeneratedWorkoutError` (elenco
/// di enum) usato altrove nel dominio, esteso con un messaggio perché
/// l'export di backup — a differenza degli use case esistenti — deve
/// poter riportare un dettaglio parametrico (es. quale `exerciseCode`
/// non si è risolto, quale riferimento interno pende).
class BackupExportFailure {
  const BackupExportFailure({required this.reason, required this.message});

  final BackupExportFailureReason reason;
  final String message;

  @override
  String toString() => '[${reason.code}] $message';
}

/// Esito dell'export (Backup.2, sezione 54): mai "completato" se
/// [errors] non è vuoto (Backup.2, sezione 53 — la self-validation deve
/// avere successo). Nessun file scritto qui (Backup.2, sezione 56): solo
/// il [backup] e il [json] già pronti per essere salvati da un livello
/// superiore.
class BackupExportResult {
  const BackupExportResult._({this.backup, this.json, required this.errors});

  factory BackupExportResult.success({
    required ForgeBackupV1 backup,
    required String json,
  }) => BackupExportResult._(backup: backup, json: json, errors: const []);

  factory BackupExportResult.failure(List<BackupExportFailure> errors) =>
      BackupExportResult._(errors: errors);

  final ForgeBackupV1? backup;
  final String? json;
  final List<BackupExportFailure> errors;

  bool get isSuccess => errors.isEmpty && backup != null && json != null;
}
