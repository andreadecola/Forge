import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/backup/backup_export_service.dart';
import 'package:forge/data/backup/backup_file_storage.dart';
import 'package:forge/data/backup/backup_filename.dart';
import 'package:forge/data/backup/backup_mapper.dart';
import 'package:forge/data/backup/backup_save_result.dart';
import 'package:forge/data/backup/create_external_backup.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/repositories/pressure_repository_impl.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_alternative.dart';
import 'package:forge/domain/entities/exercise_category.dart';
import 'package:forge/domain/entities/exercise_details.dart';
import 'package:forge/domain/entities/exercise_image.dart';
import 'package:forge/domain/entities/exercise_progression.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/repositories/exercise_repository.dart';

import '../workout_test_helpers.dart';

/// Cattura ogni invocazione: usata per verificare che l'orchestratore
/// passi filename/contenuto invariati, senza duplicarli o modificarli
/// (Backup.3, sezione 18/36).
class _FakeBackupFileStorage implements BackupFileStorage {
  BackupSaveResult nextResult = BackupSaveResult.success('content://fake');
  int callCount = 0;
  String? lastFileName;
  String? lastContent;

  @override
  Future<BackupSaveResult> saveBackup({
    required String suggestedFileName,
    required String content,
  }) async {
    callCount++;
    lastFileName = suggestedFileName;
    lastContent = content;
    return nextResult;
  }
}

/// Stesso ruolo di `_AlwaysMissingCatalogRepository` in
/// `backup_export_service_test.dart`: forza deterministicamente un
/// fallimento dell'export (qui usato solo per il test "export failure
/// non deve mai aprire lo storage").
class _AlwaysMissingCatalogRepository implements ExerciseRepository {
  _AlwaysMissingCatalogRepository(this._delegate);
  final ExerciseRepository _delegate;

  @override
  Future<Exercise?> getExerciseByCode(String code) async => null;

  @override
  Future<List<Exercise>> getExercises() => _delegate.getExercises();
  @override
  Future<List<ExerciseCategory>> getCategories() => _delegate.getCategories();
  @override
  Future<Map<int, Set<String>>> getRequiredEquipmentCodesByExercise() =>
      _delegate.getRequiredEquipmentCodesByExercise();
  @override
  Stream<List<Exercise>> watchExercises() => _delegate.watchExercises();
  @override
  Future<Exercise?> getExerciseById(int id) => _delegate.getExerciseById(id);
  @override
  Future<List<Exercise>> getExercisesByCategory(String categoryCode) =>
      _delegate.getExercisesByCategory(categoryCode);
  @override
  Future<List<Exercise>> getExercisesByLevel(int userLevel) =>
      _delegate.getExercisesByLevel(userLevel);
  @override
  Future<List<Exercise>> searchExercises(String query) =>
      _delegate.searchExercises(query);
  @override
  Future<List<Exercise>> getExercisesByAvailableEquipment(
    Set<String> ownedEquipmentCodes,
  ) => _delegate.getExercisesByAvailableEquipment(ownedEquipmentCodes);
  @override
  Future<ExerciseDetails?> getExerciseDetails(int exerciseId) =>
      _delegate.getExerciseDetails(exerciseId);
  @override
  Future<List<ExerciseImage>> getImages(int exerciseId) =>
      _delegate.getImages(exerciseId);
  @override
  Future<List<ExerciseProgression>> getProgressions(int exerciseId) =>
      _delegate.getProgressions(exerciseId);
  @override
  Future<List<ExerciseProgression>> getRegressions(int exerciseId) =>
      _delegate.getRegressions(exerciseId);
  @override
  Future<List<ExerciseAlternative>> getAlternatives(int exerciseId) =>
      _delegate.getAlternatives(exerciseId);
}

void main() {
  late AppDatabase db;
  late DriftExerciseRepository exerciseRepository;
  late BackupExportService exportService;
  late _FakeBackupFileStorage fakeStorage;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Nome con caratteri Unicode reali (accenti/apostrofi, sezione 43):
    // verifica che l'encoding UTF-8 sopravviva fino al layer storage.
    final now = DateTime(2026, 1, 1);
    final profileId = await db
        .into(db.userProfilesTable)
        .insert(
          UserProfilesTableCompanion.insert(
            name: 'Renée D\'Angelo',
            birthDate: DateTime(1990, 1, 1),
            heightCm: 175,
            initialWeightKg: 80,
            preferredWalkMinutes: 30,
            equipmentBudgetLimit: 50,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    // Un workout con un esercizio del catalogo: necessario perché il
    // test "export failure non deve mai aprire lo storage" possa
    // esercitare davvero il controllo sul catalogo (altrimenti, senza
    // alcun riferimento a un esercizio, non ci sarebbe nulla da
    // risolvere e l'export riuscirebbe comunque).
    final categoriaId = await insertCategoria(db);
    final exerciseId = await insertEsercizio(
      db,
      codice: 'EX-A',
      idCategoria: categoriaId,
    );
    exerciseRepository = DriftExerciseRepository(db);
    await DriftWorkoutRepository(db).createWorkoutWithExercises(
      workout: Workout(
        profileId: profileId,
        name: 'Scheda',
        type: WorkoutType.fullBody,
        level: 1,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
        createdAt: now,
        updatedAt: now,
      ),
      exercises: [
        WorkoutExercise(
          workoutId: 0,
          exerciseId: exerciseId,
          order: 1,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    final mapper = BackupMapper(
      profileRepository: ProfileRepositoryImpl(db.userProfileDao),
      equipmentRepository: EquipmentRepositoryImpl(db.userEquipmentDao),
      bodyMetricsRepository: BodyMetricsRepositoryImpl(db.bodyMeasurementsDao),
      pressureRepository: PressureRepositoryImpl(db.pressureMeasurementsDao),
      settingsRepository: SettingsRepositoryImpl(db.appSettingsDao),
      workoutRepository: DriftWorkoutRepository(db),
      workoutSessionRepository: DriftWorkoutSessionRepository(db),
      walkingSessionRepository: DriftWalkingSessionRepository(db),
      plannedActivityRepository: DriftPlannedActivityRepository(
        db.attivitaPianificateDao,
      ),
      exerciseRepository: exerciseRepository,
      database: db,
    );
    exportService = BackupExportService(
      mapper: mapper,
      exerciseRepository: exerciseRepository,
    );
    fakeStorage = _FakeBackupFileStorage();
  });

  tearDown(() => db.close());

  test('export riuscito: lo storage viene invocato una volta con filename '
      'coerente col clock dell\'export e contenuto identico al JSON '
      'esportato (Backup.3, sezione 36)', () async {
    final orchestrator = CreateExternalBackup(
      exportService: exportService,
      fileStorage: fakeStorage,
    );

    final result = await orchestrator.call();
    final exportResult = await exportService.export();

    expect(result.isSuccess, isTrue);
    expect(fakeStorage.callCount, 1);
    expect(
      fakeStorage.lastFileName,
      BackupFilename.generate(exportResult.backup!.metadata.exportedAt),
    );
    expect(fakeStorage.lastFileName, endsWith('.json'));
    expect(fakeStorage.lastContent, contains('Renée D\'Angelo'));
  });

  test('lo storage annullato dall\'utente produce un risultato cancelled, '
      'mai un\'eccezione (Backup.3, sezione 37)', () async {
    fakeStorage.nextResult = BackupSaveResult.cancelled();
    final orchestrator = CreateExternalBackup(
      exportService: exportService,
      fileStorage: fakeStorage,
    );

    final result = await orchestrator.call();

    expect(result.isCancelled, isTrue);
    expect(fakeStorage.callCount, 1);
  });

  test('un fallimento di scrittura dello storage produce un risultato '
      'failure controllato (Backup.3, sezione 38)', () async {
    fakeStorage.nextResult = BackupSaveResult.failure(
      BackupSaveFailureReason.writeFailed,
      'disco pieno (simulato)',
    );
    final orchestrator = CreateExternalBackup(
      exportService: exportService,
      fileStorage: fakeStorage,
    );

    final result = await orchestrator.call();

    expect(result.isFailure, isTrue);
    expect(result.failureReason, BackupSaveFailureReason.writeFailed);
  });

  test('se l\'export fallisce lo storage non viene mai invocato (Backup.3, '
      'sezione 39)', () async {
    final failingExportService = BackupExportService(
      mapper: BackupMapper(
        profileRepository: ProfileRepositoryImpl(db.userProfileDao),
        equipmentRepository: EquipmentRepositoryImpl(db.userEquipmentDao),
        bodyMetricsRepository: BodyMetricsRepositoryImpl(
          db.bodyMeasurementsDao,
        ),
        pressureRepository: PressureRepositoryImpl(db.pressureMeasurementsDao),
        settingsRepository: SettingsRepositoryImpl(db.appSettingsDao),
        workoutRepository: DriftWorkoutRepository(db),
        workoutSessionRepository: DriftWorkoutSessionRepository(db),
        walkingSessionRepository: DriftWalkingSessionRepository(db),
        plannedActivityRepository: DriftPlannedActivityRepository(
          db.attivitaPianificateDao,
        ),
        exerciseRepository: exerciseRepository,
        database: db,
      ),
      // Forza il fallimento della self-validation (stesso meccanismo di
      // backup_export_service_test.dart), senza dover corrompere il DB.
      exerciseRepository: _AlwaysMissingCatalogRepository(exerciseRepository),
    );
    final orchestrator = CreateExternalBackup(
      exportService: failingExportService,
      fileStorage: fakeStorage,
    );

    final result = await orchestrator.call();

    expect(result.isFailure, isTrue);
    expect(result.failureReason, BackupSaveFailureReason.exportFailed);
    expect(fakeStorage.callCount, 0);
  });

  test('l\'intera pipeline (export + storage fake) non scrive mai sul '
      'database (Backup.3, sola lettura, sezione 17)', () async {
    Future<int> countProfiles() async =>
        (await db.userProfileDao.getAllProfiles()).length;

    final before = await countProfiles();
    final orchestrator = CreateExternalBackup(
      exportService: exportService,
      fileStorage: fakeStorage,
    );
    await orchestrator.call();
    final after = await countProfiles();

    expect(after, before);
  });
}
