import '../../core/constants/app_constants.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/services/clock.dart';
import 'backup_export_exceptions.dart';
import 'backup_export_result.dart';
import 'backup_format_exception.dart';
import 'backup_format_version.dart';
import 'backup_json_codec.dart';
import 'backup_mapper.dart';
import 'backup_validator.dart';
import 'models/backup_data_v1.dart';
import 'models/backup_metadata.dart';
import 'models/forge_backup_v1.dart';

/// Orchestratore dell'export di backup (Backup.2, sezioni 38/53/56):
///
/// snapshot (read-only) → modelli → JSON → parse di controllo →
/// validazione → solo allora l'export è dichiarato riuscito.
///
/// Non scrive alcun file: ritorna il [ForgeBackupV1] e il JSON già
/// pronti, lasciando la persistenza su storage esterno a una fase
/// successiva (Backup.3+). Non modifica mai il database (sola lettura,
/// sezione 39).
class BackupExportService {
  const BackupExportService({
    required this.mapper,
    required this.exerciseRepository,
    this.clock = const SystemClock(),
  });

  final BackupMapper mapper;
  final ExerciseRepository exerciseRepository;
  final Clock clock;

  Future<BackupExportResult> export() async {
    final BackupDataV1 data;
    final Map<String, int> catalogVersions;
    try {
      data = await mapper.buildSnapshot();
      catalogVersions = await mapper.catalogVersions();
    } on BackupExerciseCodeUnresolvedException catch (e) {
      return BackupExportResult.failure([
        BackupExportFailure(
          reason: BackupExportFailureReason.catalogResolution,
          message: e.toString(),
        ),
      ]);
    } catch (e) {
      return BackupExportResult.failure([
        BackupExportFailure(
          reason: BackupExportFailureReason.databaseRead,
          message: 'Lettura database fallita: $e',
        ),
      ]);
    }

    final metadata = BackupMetadata(
      backupFormatVersion: currentBackupFormatVersion,
      databaseVersion: mapper.databaseVersion,
      catalogVersion: catalogVersions,
      appVersion: AppConstants.appVersion,
      exportedAt: clock.now(),
    );
    final backup = ForgeBackupV1(metadata: metadata, data: data);

    final String json;
    try {
      json = BackupJsonCodec.encode(backup);
    } catch (e) {
      return BackupExportResult.failure([
        BackupExportFailure(
          reason: BackupExportFailureReason.serialization,
          message: 'Serializzazione JSON fallita: $e',
        ),
      ]);
    }

    // Self-validation (sezione 53): il backup non è dichiarato pronto
    // finché non ha superato un round-trip completo parse+validate a
    // partire dal JSON appena prodotto — non dal modello ancora in
    // memoria, per essere certi che sia esattamente ciò che verrà letto
    // da un futuro import.
    final ForgeBackupV1 reparsed;
    try {
      reparsed = BackupJsonCodec.decode(json);
    } on BackupFormatException catch (e) {
      return BackupExportResult.failure([
        BackupExportFailure(
          reason: BackupExportFailureReason.selfCheckParsing,
          message: e.toString(),
        ),
      ]);
    }

    final validator = BackupValidator(
      exerciseCodeExists: (code) async =>
          (await exerciseRepository.getExerciseByCode(code)) != null,
    );
    final issues = await validator.validate(reparsed);
    if (issues.isNotEmpty) {
      return BackupExportResult.failure([
        for (final issue in issues)
          BackupExportFailure(
            reason: BackupExportFailureReason.selfCheckValidation,
            message: issue.toString(),
          ),
      ]);
    }

    return BackupExportResult.success(backup: backup, json: json);
  }
}
