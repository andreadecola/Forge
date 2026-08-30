import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/catalog_providers.dart';
import '../repositories/forge_providers.dart';
import '../repositories/repository_providers.dart';
import '../repositories/walking_session_providers.dart';
import '../repositories/workout_providers.dart';
import '../repositories/workout_session_providers.dart';
import '../database/database_provider.dart';
import 'backup_export_service.dart';
import 'backup_file_reader.dart';
import 'backup_file_storage.dart';
import 'backup_mapper.dart';
import 'backup_restore_service.dart';
import 'create_external_backup.dart';
import 'file_picker_backup_file_reader.dart';
import 'file_picker_backup_file_storage.dart';
import 'import_external_backup.dart';

/// Composizione Riverpod di Backup.2/Backup.3: nessun repository nuovo
/// creato qui, solo assemblaggio di provider già esistenti (Backup.2,
/// sezione 60 — mai esporre `AppDatabase` alla UI, mai duplicare
/// repository).
final backupMapperProvider = Provider<BackupMapper>((ref) {
  return BackupMapper(
    profileRepository: ref.watch(profileRepositoryProvider),
    equipmentRepository: ref.watch(equipmentRepositoryProvider),
    bodyMetricsRepository: ref.watch(bodyMetricsRepositoryProvider),
    pressureRepository: ref.watch(pressureRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    workoutRepository: ref.watch(workoutRepositoryProvider),
    workoutSessionRepository: ref.watch(workoutSessionRepositoryProvider),
    walkingSessionRepository: ref.watch(walkingSessionRepositoryProvider),
    plannedActivityRepository: ref.watch(plannedActivityRepositoryProvider),
    exerciseRepository: ref.watch(exerciseRepositoryProvider),
    database: ref.watch(databaseProvider),
  );
});

final backupExportServiceProvider = Provider<BackupExportService>((ref) {
  return BackupExportService(
    mapper: ref.watch(backupMapperProvider),
    exerciseRepository: ref.watch(exerciseRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

/// Tipizzato sull'interfaccia astratta (non l'implementazione concreta):
/// permette di sostituirlo con un fake nei test widget senza toccare il
/// picker/plugin reale (Backup.3). Implementazione reale: Android,
/// Storage Access Framework.
final backupFileStorageProvider = Provider<BackupFileStorage>((ref) {
  return const FilePickerBackupFileStorage();
});

final createExternalBackupProvider = Provider<CreateExternalBackup>((ref) {
  return CreateExternalBackup(
    exportService: ref.watch(backupExportServiceProvider),
    fileStorage: ref.watch(backupFileStorageProvider),
  );
});

/// Stessa ragione di [backupFileStorageProvider]: tipizzato
/// sull'interfaccia astratta per restare sostituibile nei test
/// (Backup.4). Implementazione reale: Android, Storage Access
/// Framework.
final backupFileReaderProvider = Provider<BackupFileReader>((ref) {
  return const FilePickerBackupFileReader();
});

final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  return BackupRestoreService(
    database: ref.watch(databaseProvider),
    exerciseRepository: ref.watch(exerciseRepositoryProvider),
    exportService: ref.watch(backupExportServiceProvider),
  );
});

final importExternalBackupProvider = Provider<ImportExternalBackup>((ref) {
  return ImportExternalBackup(
    fileReader: ref.watch(backupFileReaderProvider),
    restoreService: ref.watch(backupRestoreServiceProvider),
  );
});
