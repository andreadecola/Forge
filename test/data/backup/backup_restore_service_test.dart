import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/backup/backup_export_service.dart';
import 'package:forge/data/backup/backup_json_codec.dart';
import 'package:forge/data/backup/backup_mapper.dart';
import 'package:forge/data/backup/backup_restore_result.dart';
import 'package:forge/data/backup/backup_restore_service.dart';
import 'package:forge/data/backup/models/backup_app_settings.dart';
import 'package:forge/data/backup/models/backup_data_v1.dart';
import 'package:forge/data/backup/models/backup_metadata.dart';
import 'package:forge/data/backup/models/backup_planned_activity.dart';
import 'package:forge/data/backup/models/backup_profile.dart';
import 'package:forge/data/backup/models/backup_session_exercise.dart';
import 'package:forge/data/backup/models/backup_workout.dart';
import 'package:forge/data/backup/models/backup_workout_exercise.dart';
import 'package:forge/data/backup/models/backup_workout_session.dart';
import 'package:forge/data/backup/models/forge_backup_v1.dart';
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
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/services/clock.dart';

import '../workout_test_helpers.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._value);
  final DateTime _value;
  @override
  DateTime now() => _value;
}

class _Wiring {
  _Wiring(
    this.db,
    this.exerciseRepository,
    this.exportService,
    this.restoreService,
  );
  final AppDatabase db;
  final DriftExerciseRepository exerciseRepository;
  final BackupExportService exportService;
  final BackupRestoreService restoreService;
}

_Wiring _buildWiring(
  AppDatabase db, {
  Future<void> Function()? onRestoreCommitted,
}) {
  final exerciseRepository = DriftExerciseRepository(db);
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
  final exportService = BackupExportService(
    mapper: mapper,
    exerciseRepository: exerciseRepository,
    clock: _FixedClock(DateTime.utc(2026, 3, 1, 10)),
  );
  final restoreService = BackupRestoreService(
    database: db,
    exerciseRepository: exerciseRepository,
    exportService: exportService,
    onRestoreCommitted: onRestoreCommitted,
  );
  return _Wiring(db, exerciseRepository, exportService, restoreService);
}

/// Popola un dataset rappresentativo su [db] per [profileId], usando gli
/// esercizi [exerciseAId]/[exerciseBId] già seedati — stesso dataset di
/// `backup_export_service_test.dart`, qui riscritto per essere applicabile
/// a un profilo/DB arbitrario (necessario per i test cross-database del
/// restore).
Future<void> _populateDataset(
  AppDatabase db, {
  required int profileId,
  required int exerciseAId,
  required int exerciseBId,
}) async {
  await db
      .into(db.userEquipmentTable)
      .insert(
        UserEquipmentTableCompanion.insert(
          profileId: profileId,
          equipmentCode: 'chair',
          owned: const Value(true),
          notes: const Value('Nonna Renée l\'ha regalata'),
        ),
      );

  await BodyMetricsRepositoryImpl(db.bodyMeasurementsDao).addMeasurement(
    BodyMeasurement(
      profileId: profileId,
      measuredAt: DateTime.utc(2026, 1, 5),
      weightKg: null,
      waistCm: 90,
    ),
  );
  await PressureRepositoryImpl(db.pressureMeasurementsDao).addMeasurement(
    PressureMeasurement(
      profileId: profileId,
      measuredAt: DateTime.utc(2026, 1, 5, 8),
      systolic: 120,
      diastolic: 80,
    ),
  );

  final workoutRepository = DriftWorkoutRepository(db);
  final now = DateTime(2026, 1, 1);
  final workoutId = await workoutRepository.createWorkoutWithExercises(
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
        exerciseId: exerciseAId,
        order: 1,
        sets: 3,
        repetitions: 10,
        createdAt: now,
        updatedAt: now,
      ),
      WorkoutExercise(
        workoutId: 0,
        exerciseId: exerciseBId,
        order: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );

  final sessionRepository = DriftWorkoutSessionRepository(db);
  final details = await workoutRepository.getWorkoutDetails(workoutId);
  final sessionId = await sessionRepository.createSession(
    profileId: profileId,
    details: details!,
    startedAt: DateTime.utc(2026, 1, 10, 9),
  );
  await sessionRepository.completeSession(
    sessionId: sessionId,
    endedAt: DateTime.utc(2026, 1, 10, 9, 40),
  );

  final walkingRepository = DriftWalkingSessionRepository(db);
  final walkId = await walkingRepository.createWalkingSession(
    WalkingSession(
      profileId: profileId,
      startedAt: DateTime.utc(2026, 1, 6, 7),
      status: WalkingSessionStatus.inProgress,
    ),
  );
  await walkingRepository.completeWalkingSession(
    sessionId: walkId,
    endedAt: DateTime.utc(2026, 1, 6, 7, 30),
    distanceMeters: 2500,
    steps: 3200,
  );

  final planRepository = DriftPlannedActivityRepository(
    db.attivitaPianificateDao,
  );
  final workoutActivityId = await planRepository.addPlannedActivity(
    PlannedActivity(
      profileId: profileId,
      scheduledDate: DateTime(2026, 1, 10),
      type: PlannedActivityType.workout,
      workoutId: workoutId,
      origin: PlannedActivityOrigin.user,
    ),
  );
  await planRepository.linkWorkoutSession(
    activityId: workoutActivityId,
    workoutSessionId: sessionId,
  );
  await planRepository.addPlannedActivity(
    PlannedActivity(
      profileId: profileId,
      scheduledDate: DateTime(2026, 2, 2),
      type: PlannedActivityType.recovery,
      status: PlannedActivityStatus.skipped,
      origin: PlannedActivityOrigin.user,
    ),
  );

  final settingsRepository = SettingsRepositoryImpl(db.appSettingsDao);
  await settingsRepository.setOnboardingCompleted(true);
  await settingsRepository.setThemeMode('dark');
  await settingsRepository.setNotificationsEnabled(false);
}

void main() {
  group('Golden round-trip e REPLACE', () {
    test('DB fresco (solo catalogo seedato): restore di un backup completo '
        'ha successo (fresh DB restore)', () async {
      final sourceDb = AppDatabase(NativeDatabase.memory());
      final sourceWiring = _buildWiring(sourceDb);
      final profileId = await insertProfilo(sourceDb);
      final categoriaId = await insertCategoria(sourceDb);
      final exerciseAId = await insertEsercizio(
        sourceDb,
        codice: 'EX-A',
        idCategoria: categoriaId,
      );
      final exerciseBId = await insertEsercizio(
        sourceDb,
        codice: 'EX-B',
        idCategoria: categoriaId,
      );
      await _populateDataset(
        sourceDb,
        profileId: profileId,
        exerciseAId: exerciseAId,
        exerciseBId: exerciseBId,
      );
      final sourceExport = await sourceWiring.exportService.export();
      expect(sourceExport.isSuccess, isTrue, reason: '${sourceExport.errors}');
      await sourceDb.close();

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetCategoriaId = await insertCategoria(targetDb);
      await insertEsercizio(
        targetDb,
        codice: 'EX-A',
        idCategoria: targetCategoriaId,
      );
      await insertEsercizio(
        targetDb,
        codice: 'EX-B',
        idCategoria: targetCategoriaId,
      );
      var callbackCalled = false;
      var committedDataVisible = false;
      final targetWiring = _buildWiring(
        targetDb,
        onRestoreCommitted: () async {
          callbackCalled = true;
          committedDataVisible =
              await targetDb.userProfileDao.getCurrentProfile() != null;
        },
      );

      final result = await targetWiring.restoreService.restore(
        sourceExport.json!,
      );

      expect(result.isSuccess, isTrue, reason: result.errorMessage);
      expect(result.safetyBackupMetadata, isNotNull);
      expect(callbackCalled, isTrue);
      expect(committedDataVisible, isTrue);

      final afterRestore = await targetWiring.exportService.export();
      expect(afterRestore.isSuccess, isTrue);
      expect(afterRestore.backup!.data.profiles, hasLength(1));
      expect(afterRestore.backup!.data.workouts, hasLength(1));
      expect(afterRestore.backup!.data.workoutExercises, hasLength(2));
      expect(afterRestore.backup!.data.workoutSessions, hasLength(1));
      expect(afterRestore.backup!.data.walkingSessions, hasLength(1));
      expect(afterRestore.backup!.data.plannedActivities, hasLength(2));

      await targetDb.close();
    });

    test(
      'DB target non vuoto: REPLACE sostituisce interamente i vecchi dati '
      'con quelli del backup, catalogo invariato (non-empty DB restore)',
      () async {
        final sourceDb = AppDatabase(NativeDatabase.memory());
        final sourceWiring = _buildWiring(sourceDb);
        final sourceProfileId = await insertProfilo(sourceDb);
        final sourceCategoriaId = await insertCategoria(sourceDb);
        final sourceExAId = await insertEsercizio(
          sourceDb,
          codice: 'EX-A',
          idCategoria: sourceCategoriaId,
        );
        final sourceExBId = await insertEsercizio(
          sourceDb,
          codice: 'EX-B',
          idCategoria: sourceCategoriaId,
        );
        await _populateDataset(
          sourceDb,
          profileId: sourceProfileId,
          exerciseAId: sourceExAId,
          exerciseBId: sourceExBId,
        );
        final sourceExport = await sourceWiring.exportService.export();
        expect(sourceExport.isSuccess, isTrue);
        await sourceDb.close();

        // Target: già popolato con uno stato utente B differente, che
        // deve sparire interamente dopo il restore.
        final targetDb = AppDatabase(NativeDatabase.memory());
        final targetCategoriaId = await insertCategoria(targetDb);
        final targetExAId = await insertEsercizio(
          targetDb,
          codice: 'EX-A',
          idCategoria: targetCategoriaId,
        );
        final targetExBId = await insertEsercizio(
          targetDb,
          codice: 'EX-B',
          idCategoria: targetCategoriaId,
        );
        final targetProfileId = await insertProfilo(targetDb);
        await _populateDataset(
          targetDb,
          profileId: targetProfileId,
          exerciseAId: targetExAId,
          exerciseBId: targetExBId,
        );
        // Stato B ha un secondo profilo in più rispetto ad A.
        await targetDb
            .into(targetDb.userProfilesTable)
            .insert(
              UserProfilesTableCompanion.insert(
                name: 'Solo in B',
                birthDate: DateTime(1980, 1, 1),
                heightCm: 180,
                initialWeightKg: 90,
                preferredWalkMinutes: 20,
                equipmentBudgetLimit: 10,
                startDate: DateTime(2020, 1, 1),
                createdAt: DateTime(2020, 1, 1),
                updatedAt: DateTime(2020, 1, 1),
              ),
            );

        final catalogCountsBefore = await Future.wait([
          targetDb.select(targetDb.eserciziTable).get(),
          targetDb.select(targetDb.categorieEserciziTable).get(),
        ]);

        final targetWiring = _buildWiring(targetDb);
        final result = await targetWiring.restoreService.restore(
          sourceExport.json!,
        );
        expect(result.isSuccess, isTrue, reason: result.errorMessage);

        final afterRestore = await targetWiring.exportService.export();
        expect(afterRestore.isSuccess, isTrue);
        // Solo il profilo di A resta: "Solo in B" e' sparito.
        expect(afterRestore.backup!.data.profiles, hasLength(1));
        expect(
          afterRestore.backup!.data.profiles.single.name,
          isNot('Solo in B'),
        );

        // Il catalogo non e' stato toccato dal REPLACE.
        final catalogCountsAfter = await Future.wait([
          targetDb.select(targetDb.eserciziTable).get(),
          targetDb.select(targetDb.categorieEserciziTable).get(),
        ]);
        expect(catalogCountsAfter[0].length, catalogCountsBefore[0].length);
        expect(catalogCountsAfter[1].length, catalogCountsBefore[1].length);

        await targetDb.close();
      },
    );

    test('catalogo con ID numerici diversi tra le due installazioni: '
        'exerciseCode risolve comunque all\'esercizio corretto (CRITICO, '
        'Backup.4 sezione 80)', () async {
      final sourceDb = AppDatabase(NativeDatabase.memory());
      final sourceWiring = _buildWiring(sourceDb);
      final profileId = await insertProfilo(sourceDb);
      final categoriaId = await insertCategoria(sourceDb);
      // In A, EX-A viene inserito PRIMA di EX-B.
      final exAId = await insertEsercizio(
        sourceDb,
        codice: 'EX-A',
        idCategoria: categoriaId,
      );
      final exBId = await insertEsercizio(
        sourceDb,
        codice: 'EX-B',
        idCategoria: categoriaId,
      );
      expect(exAId, isNot(exBId));
      await _populateDataset(
        sourceDb,
        profileId: profileId,
        exerciseAId: exAId,
        exerciseBId: exBId,
      );
      final sourceExport = await sourceWiring.exportService.export();
      expect(sourceExport.isSuccess, isTrue);
      await sourceDb.close();

      // In B, l'ordine di seeding e' INVERTITO: EX-B ottiene l'ID che
      // in A apparteneva a EX-A, e viceversa.
      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetCategoriaId = await insertCategoria(targetDb);
      final targetExBId = await insertEsercizio(
        targetDb,
        codice: 'EX-B',
        idCategoria: targetCategoriaId,
      );
      final targetExAId = await insertEsercizio(
        targetDb,
        codice: 'EX-A',
        idCategoria: targetCategoriaId,
      );
      expect(targetExAId, isNot(exAId));
      expect(targetExBId, isNot(exBId));

      final targetWiring = _buildWiring(targetDb);
      final result = await targetWiring.restoreService.restore(
        sourceExport.json!,
      );
      expect(result.isSuccess, isTrue, reason: result.errorMessage);

      // Verifica diretta sulla tabella reale: la riga allenamenti_esercizi
      // con ordine=1 (EX-A) deve puntare all'ID di EX-A in B (non a
      // quello, diverso, che EX-A aveva in A).
      final rows = await (targetDb.select(
        targetDb.allenamentiEserciziTable,
      )..orderBy([(t) => OrderingTerm.asc(t.ordine)])).get();
      expect(rows, hasLength(2));
      expect(rows[0].idEsercizio, targetExAId);
      expect(rows[1].idEsercizio, targetExBId);

      await targetDb.close();
    });

    test('multi-profilo: entrambi i profili e i dati collegati vengono '
        'ripristinati correttamente', () async {
      final sourceDb = AppDatabase(NativeDatabase.memory());
      final sourceWiring = _buildWiring(sourceDb);
      final categoriaId = await insertCategoria(sourceDb);
      final exAId = await insertEsercizio(
        sourceDb,
        codice: 'EX-A',
        idCategoria: categoriaId,
      );
      final exBId = await insertEsercizio(
        sourceDb,
        codice: 'EX-B',
        idCategoria: categoriaId,
      );
      final profileAId = await insertProfilo(sourceDb);
      await _populateDataset(
        sourceDb,
        profileId: profileAId,
        exerciseAId: exAId,
        exerciseBId: exBId,
      );
      final profileBId = await sourceDb
          .into(sourceDb.userProfilesTable)
          .insert(
            UserProfilesTableCompanion.insert(
              name: 'Sam',
              birthDate: DateTime(1985, 5, 20),
              heightCm: 168,
              initialWeightKg: 65,
              preferredWalkMinutes: 20,
              equipmentBudgetLimit: 30,
              startDate: DateTime(2026, 3, 1),
              createdAt: DateTime(2026, 3, 1),
              updatedAt: DateTime(2026, 3, 1),
            ),
          );
      final workoutBId = await DriftWorkoutRepository(sourceDb)
          .createWorkoutWithExercises(
            workout: Workout(
              profileId: profileBId,
              name: 'Scheda di Sam',
              type: WorkoutType.mobility,
              level: 1,
              status: WorkoutDefinitionStatus.ready,
              origin: WorkoutOrigin.user,
              createdAt: DateTime(2026, 3, 1),
              updatedAt: DateTime(2026, 3, 1),
            ),
            exercises: [
              WorkoutExercise(
                workoutId: 0,
                exerciseId: exBId,
                order: 1,
                createdAt: DateTime(2026, 3, 1),
                updatedAt: DateTime(2026, 3, 1),
              ),
            ],
          );

      final sourceExport = await sourceWiring.exportService.export();
      expect(sourceExport.isSuccess, isTrue);
      await sourceDb.close();

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetCategoriaId = await insertCategoria(targetDb);
      await insertEsercizio(
        targetDb,
        codice: 'EX-A',
        idCategoria: targetCategoriaId,
      );
      await insertEsercizio(
        targetDb,
        codice: 'EX-B',
        idCategoria: targetCategoriaId,
      );
      final targetWiring = _buildWiring(targetDb);
      final result = await targetWiring.restoreService.restore(
        sourceExport.json!,
      );
      expect(result.isSuccess, isTrue, reason: result.errorMessage);

      final afterRestore = await targetWiring.exportService.export();
      expect(afterRestore.backup!.data.profiles, hasLength(2));
      final restoredA = afterRestore.backup!.data.profiles.firstWhere(
        (p) => p.name == 'Alex',
      );
      final restoredB = afterRestore.backup!.data.profiles.firstWhere(
        (p) => p.name == 'Sam',
      );
      final workoutsOfA = afterRestore.backup!.data.workouts.where(
        (w) => w.profileLocalId == restoredA.localId,
      );
      final workoutsOfB = afterRestore.backup!.data.workouts.where(
        (w) => w.profileLocalId == restoredB.localId,
      );
      expect(workoutsOfA, hasLength(1));
      expect(workoutsOfB, hasLength(1));
      expect(workoutsOfB.single.name, 'Scheda di Sam');
      expect(_ignore(workoutBId), workoutBId);

      await targetDb.close();
    });

    test('M8 link (PlannedActivity WORKOUT collegata a una sessione reale) '
        'preservato correttamente dopo il restore', () async {
      final sourceDb = AppDatabase(NativeDatabase.memory());
      final sourceWiring = _buildWiring(sourceDb);
      final profileId = await insertProfilo(sourceDb);
      final categoriaId = await insertCategoria(sourceDb);
      final exAId = await insertEsercizio(
        sourceDb,
        codice: 'EX-A',
        idCategoria: categoriaId,
      );
      final exBId = await insertEsercizio(
        sourceDb,
        codice: 'EX-B',
        idCategoria: categoriaId,
      );
      await _populateDataset(
        sourceDb,
        profileId: profileId,
        exerciseAId: exAId,
        exerciseBId: exBId,
      );
      final sourceExport = await sourceWiring.exportService.export();
      final sourceWorkoutActivity = sourceExport.backup!.data.plannedActivities
          .firstWhere((a) => a.type == 'WORKOUT');
      expect(sourceWorkoutActivity.workoutSessionLocalId, isNotNull);
      await sourceDb.close();

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetCategoriaId = await insertCategoria(targetDb);
      await insertEsercizio(
        targetDb,
        codice: 'EX-A',
        idCategoria: targetCategoriaId,
      );
      await insertEsercizio(
        targetDb,
        codice: 'EX-B',
        idCategoria: targetCategoriaId,
      );
      final targetWiring = _buildWiring(targetDb);
      final result = await targetWiring.restoreService.restore(
        sourceExport.json!,
      );
      expect(result.isSuccess, isTrue, reason: result.errorMessage);

      final afterRestore = await targetWiring.exportService.export();
      final restoredWorkoutActivity = afterRestore
          .backup!
          .data
          .plannedActivities
          .firstWhere((a) => a.type == 'WORKOUT');
      expect(restoredWorkoutActivity.workoutSessionLocalId, isNotNull);
      final restoredSession = afterRestore.backup!.data.workoutSessions
          .firstWhere(
            (s) => s.localId == restoredWorkoutActivity.workoutSessionLocalId,
          );
      expect(restoredSession.status, 'COMPLETED');

      await targetDb.close();
    });

    test('Unicode, null e precisione numerica sopravvivono al round-trip '
        'completo (export -> restore)', () async {
      final sourceDb = AppDatabase(NativeDatabase.memory());
      final sourceWiring = _buildWiring(sourceDb);
      final now = DateTime(2026, 1, 1);
      final profileId = await sourceDb
          .into(sourceDb.userProfilesTable)
          .insert(
            UserProfilesTableCompanion.insert(
              name: 'Renée D\'Angelo — città più bella',
              birthDate: DateTime(1990, 1, 1),
              heightCm: 175.345,
              initialWeightKg: 80.125,
              preferredWalkMinutes: 30,
              equipmentBudgetLimit: 50,
              startDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await BodyMetricsRepositoryImpl(
        sourceDb.bodyMeasurementsDao,
      ).addMeasurement(
        BodyMeasurement(
          profileId: profileId,
          measuredAt: DateTime.utc(2026, 1, 5),
          weightKg: null,
          waistCm: 90.5,
        ),
      );
      final sourceExport = await sourceWiring.exportService.export();
      expect(sourceExport.isSuccess, isTrue);
      await sourceDb.close();

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetWiring = _buildWiring(targetDb);
      final result = await targetWiring.restoreService.restore(
        sourceExport.json!,
      );
      expect(result.isSuccess, isTrue, reason: result.errorMessage);

      final afterRestore = await targetWiring.exportService.export();
      final restoredProfile = afterRestore.backup!.data.profiles.single;
      expect(restoredProfile.name, 'Renée D\'Angelo — città più bella');
      expect(restoredProfile.heightCm, 175.345);
      expect(restoredProfile.initialWeightKg, 80.125);
      final restoredMeasurement =
          afterRestore.backup!.data.bodyMeasurements.single;
      expect(restoredMeasurement.weightKg, isNull);
      expect(restoredMeasurement.waistCm, 90.5);

      await targetDb.close();
    });

    test('impostazioni incluse vengono ripristinate, nessuna chiave '
        'sconosciuta introdotta', () async {
      final sourceDb = AppDatabase(NativeDatabase.memory());
      final sourceWiring = _buildWiring(sourceDb);
      await insertProfilo(sourceDb);
      final settingsRepository = SettingsRepositoryImpl(
        sourceDb.appSettingsDao,
      );
      await settingsRepository.setOnboardingCompleted(true);
      await settingsRepository.setThemeMode('light');
      await settingsRepository.setNotificationsEnabled(true);
      await settingsRepository.setPlannedActivityReminderTimeMinutes(510);
      await settingsRepository.setPlannedActivityRemindersEnabled(true);
      final sourceExport = await sourceWiring.exportService.export();
      await sourceDb.close();

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetWiring = _buildWiring(targetDb);
      final result = await targetWiring.restoreService.restore(
        sourceExport.json!,
      );
      expect(result.isSuccess, isTrue, reason: result.errorMessage);

      final targetSettings = SettingsRepositoryImpl(targetDb.appSettingsDao);
      expect(await targetSettings.isOnboardingCompleted(), isTrue);
      expect(await targetSettings.getThemeMode(), 'light');
      expect(await targetSettings.getNotificationsEnabled(), isTrue);
      expect(await targetSettings.getPlannedActivityRemindersEnabled(), isTrue);
      expect(await targetSettings.getPlannedActivityReminderTimeMinutes(), 510);

      final rawSettingsRows = await targetDb
          .select(targetDb.appSettingsTable)
          .get();
      expect(rawSettingsRows, hasLength(5));

      await targetDb.close();
    });

    test(
      'backup v1 precedente senza le nuove preferenze usa i default',
      () async {
        final sourceDb = AppDatabase(NativeDatabase.memory());
        final sourceWiring = _buildWiring(sourceDb);
        await insertProfilo(sourceDb);
        final sourceExport = await sourceWiring.exportService.export();
        final root = jsonDecode(sourceExport.json!) as Map<String, dynamic>;
        final data = root['data'] as Map<String, dynamic>;
        final settings =
            Map<String, dynamic>.from(
                data['appSettings'] as Map<String, dynamic>,
              )
              ..remove('plannedActivityRemindersEnabled')
              ..remove('plannedActivityReminderTimeMinutes');
        data['appSettings'] = settings;
        await sourceDb.close();

        final targetDb = AppDatabase(NativeDatabase.memory());
        final targetWiring = _buildWiring(targetDb);
        final result = await targetWiring.restoreService.restore(
          jsonEncode(root),
        );

        expect(result.isSuccess, isTrue, reason: result.errorMessage);
        final targetSettings = SettingsRepositoryImpl(targetDb.appSettingsDao);
        expect(
          await targetSettings.getPlannedActivityRemindersEnabled(),
          isFalse,
        );
        expect(
          await targetSettings.getPlannedActivityReminderTimeMinutes(),
          isNull,
        );
        await targetDb.close();
      },
    );
  });

  group('Validazione pre-write (reject, nessuna scrittura)', () {
    late AppDatabase db;
    late _Wiring wiring;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      wiring = _buildWiring(db);
      // Prima riga inserita in un DB vuoto: id garantito 1, riusato come
      // `profileId: 1` in `_minimalBackup` in questo intero gruppo.
      await insertProfilo(db);
      final categoriaId = await insertCategoria(db);
      await insertEsercizio(db, codice: 'EX-A', idCategoria: categoriaId);
    });

    tearDown(() => db.close());

    Future<String> stateSnapshot() async {
      final export = await wiring.exportService.export();
      expect(export.isSuccess, isTrue);
      return export.json!;
    }

    test('JSON corrotto: reject, DB invariato', () async {
      final before = await stateSnapshot();

      final result = await wiring.restoreService.restore('{"metadata": ');

      expect(result.isFailure, isTrue);
      expect(result.failureReason, BackupRestoreFailureReason.invalidBackup);
      expect(await stateSnapshot(), before);
    });

    test('backupFormatVersion futura: reject, DB invariato', () async {
      final before = await stateSnapshot();
      final backup = _minimalBackup(profileId: 1, backupFormatVersion: 99);

      final result = await wiring.restoreService.restore(
        BackupJsonCodec.encode(backup),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureReason,
        BackupRestoreFailureReason.incompatibleVersion,
      );
      expect(await stateSnapshot(), before);
    });

    test('databaseVersion futura (superiore allo schema corrente): reject, '
        'DB invariato', () async {
      final before = await stateSnapshot();
      final backup = _minimalBackup(profileId: 1, databaseVersion: 999999);

      final result = await wiring.restoreService.restore(
        BackupJsonCodec.encode(backup),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureReason,
        BackupRestoreFailureReason.incompatibleVersion,
      );
      expect(await stateSnapshot(), before);
    });

    test('localId duplicato tra due profili: reject, DB invariato', () async {
      final before = await stateSnapshot();
      final backup = _minimalBackup(
        profileId: 1,
        extraProfiles: [_profileModel(localId: 1, name: 'Duplicato')],
      );

      final result = await wiring.restoreService.restore(
        BackupJsonCodec.encode(backup),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureReason, BackupRestoreFailureReason.invalidBackup);
      expect(await stateSnapshot(), before);
    });

    test('riferimento orfano (workoutExercise verso un workout inesistente): '
        'reject, DB invariato', () async {
      final before = await stateSnapshot();
      final backup = _minimalBackup(
        profileId: 1,
        extraWorkoutExercises: [
          BackupWorkoutExercise(
            localId: 900,
            workoutLocalId: 12345,
            exerciseCode: 'EX-A',
            order: 1,
            sets: null,
            repetitions: null,
            durationSeconds: null,
            restSeconds: null,
            notes: null,
            isActive: true,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      final result = await wiring.restoreService.restore(
        BackupJsonCodec.encode(backup),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureReason, BackupRestoreFailureReason.invalidBackup);
      expect(await stateSnapshot(), before);
    });

    test('exerciseCode sconosciuto sul catalogo di questa installazione: '
        'reject (catalogMismatch), DB invariato', () async {
      final before = await stateSnapshot();
      final backup = _minimalBackup(
        profileId: 1,
        extraWorkouts: [_workoutModel(localId: 50, profileLocalId: 1)],
        extraWorkoutExercises: [
          BackupWorkoutExercise(
            localId: 900,
            workoutLocalId: 50,
            exerciseCode: 'EX-SCONOSCIUTO',
            order: 1,
            sets: null,
            repetitions: null,
            durationSeconds: null,
            restSeconds: null,
            notes: null,
            isActive: true,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      final result = await wiring.restoreService.restore(
        BackupJsonCodec.encode(backup),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureReason, BackupRestoreFailureReason.catalogMismatch);
      expect(await stateSnapshot(), before);
    });

    test(
      'enum non riconosciuto (status workout): reject, DB invariato',
      () async {
        final before = await stateSnapshot();
        final backup = _minimalBackup(
          profileId: 1,
          extraWorkouts: [
            BackupWorkout(
              localId: 50,
              profileLocalId: 1,
              name: 'X',
              description: null,
              type: 'FULL_BODY',
              level: 1,
              estimatedDurationMinutes: null,
              status: 'STATO_INESISTENTE',
              origin: 'USER',
              isActive: true,
              createdAt: DateTime.utc(2026, 1, 1),
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          ],
        );

        final result = await wiring.restoreService.restore(
          BackupJsonCodec.encode(backup),
        );

        expect(result.isFailure, isTrue);
        expect(result.failureReason, BackupRestoreFailureReason.invalidBackup);
        expect(await stateSnapshot(), before);
      },
    );

    test('cross-profile non valido (planned activity -> workout di un altro '
        'profilo): reject, DB invariato', () async {
      final before = await stateSnapshot();
      final backup = _minimalBackup(
        profileId: 1,
        extraProfiles: [_profileModel(localId: 2, name: 'Altro')],
        extraWorkouts: [_workoutModel(localId: 50, profileLocalId: 2)],
        extraPlannedActivities: [
          BackupPlannedActivity(
            localId: 700,
            profileLocalId: 1,
            scheduledDate: DateTime(2026, 1, 1),
            type: 'WORKOUT',
            workoutLocalId: 50,
            plannedDurationMinutes: null,
            status: 'PLANNED',
            origin: 'USER',
            notes: null,
            workoutSessionLocalId: null,
            walkingSessionLocalId: null,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      final result = await wiring.restoreService.restore(
        BackupJsonCodec.encode(backup),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureReason, BackupRestoreFailureReason.invalidBackup);
      expect(await stateSnapshot(), before);
    });
  });

  group('Atomicità e rollback', () {
    test('fallimento durante l\'inserimento (CHECK constraint violato più '
        'avanti nel grafo, dopo profilo+workout+sessione): rollback '
        'completo, DB invariato', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final wiring = _buildWiring(db);
      await insertProfilo(db);
      final categoriaId = await insertCategoria(db);
      await insertEsercizio(db, codice: 'EX-A', idCategoria: categoriaId);

      final beforeExport = await wiring.exportService.export();
      expect(beforeExport.isSuccess, isTrue);
      final before = beforeExport.json!;

      // Backup strutturalmente e semanticamente valido per il
      // validatore (nessuna delle sue regole copre `totalSets > 0`),
      // ma che viola un vero CHECK SQLite
      // (`CHECK (serie_totali > 0)` su sessioni_esercizi) — un
      // fallimento reale a metà transazione, non simulato.
      final backup = _minimalBackup(
        profileId: 1,
        extraWorkouts: [_workoutModel(localId: 50, profileLocalId: 1)],
        extraWorkoutExercises: [
          BackupWorkoutExercise(
            localId: 500,
            workoutLocalId: 50,
            exerciseCode: 'EX-A',
            order: 1,
            sets: 3,
            repetitions: 10,
            durationSeconds: null,
            restSeconds: null,
            notes: null,
            isActive: true,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
        extraWorkoutSessions: [
          BackupWorkoutSession(
            localId: 600,
            profileLocalId: 1,
            workoutLocalId: 50,
            workoutNameSnapshot: 'X',
            status: 'COMPLETED',
            currentExerciseIndex: 0,
            startedAt: DateTime.utc(2026, 1, 1),
            endedAt: DateTime.utc(2026, 1, 1, 1),
            isPaused: false,
            isCompleted: true,
            timer: null,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
        extraSessionExercises: [
          BackupSessionExercise(
            localId: 700,
            sessionLocalId: 600,
            workoutExerciseLocalId: 500,
            exerciseCode: 'EX-A',
            order: 1,
            totalSets: 0, // viola CHECK (serie_totali > 0)
            completedSets: 0,
            repetitions: null,
            durationSeconds: null,
            restSeconds: null,
            isSkipped: false,
            isCompleted: false,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      final result = await wiring.restoreService.restore(
        BackupJsonCodec.encode(backup),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureReason, BackupRestoreFailureReason.restoreFailure);

      final afterExport = await wiring.exportService.export();
      expect(afterExport.isSuccess, isTrue);
      expect(afterExport.json, before);

      await db.close();
    });
  });
}

/// Helper per silenziare "unused" senza introdurre un secondo assert
/// ridondante: usato solo per il test multi-profilo, dove l'ID del
/// workout sorgente serve solo a costruire il dataset, non a un'asserzione
/// diretta sul suo valore numerico (che cambia col restore per design).
T _ignore<T>(T value) => value;

BackupProfile _profileModel({required int localId, required String name}) =>
    BackupProfile(
      localId: localId,
      name: name,
      birthDate: DateTime(1990, 1, 1),
      biologicalSexForFormula: null,
      heightCm: 175,
      initialWeightKg: 80,
      targetWeightKg: null,
      preferredWalkMinutes: 30,
      equipmentBudgetLimit: 50,
      startDate: DateTime(2026, 1, 1),
      activityLevel: 'sedentary',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

BackupWorkout _workoutModel({
  required int localId,
  required int profileLocalId,
}) => BackupWorkout(
  localId: localId,
  profileLocalId: profileLocalId,
  name: 'Scheda',
  description: null,
  type: 'FULL_BODY',
  level: 1,
  estimatedDurationMinutes: null,
  status: 'READY',
  origin: 'USER',
  isActive: true,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

/// Backup minimo valido con un solo profilo [profileId], estendibile con
/// entità aggiuntive per costruire scenari di validazione mirati — evita
/// di ripetere l'intera struttura `ForgeBackupV1` in ogni test.
ForgeBackupV1 _minimalBackup({
  required int profileId,
  int backupFormatVersion = 1,
  int databaseVersion = 11,
  List<BackupProfile> extraProfiles = const [],
  List<BackupWorkout> extraWorkouts = const [],
  List<BackupWorkoutExercise> extraWorkoutExercises = const [],
  List<BackupWorkoutSession> extraWorkoutSessions = const [],
  List<BackupSessionExercise> extraSessionExercises = const [],
  List<BackupPlannedActivity> extraPlannedActivities = const [],
}) {
  return ForgeBackupV1(
    metadata: BackupMetadata(
      backupFormatVersion: backupFormatVersion,
      databaseVersion: databaseVersion,
      catalogVersion: const {},
      appVersion: '1.0.0',
      exportedAt: DateTime.utc(2026, 1, 1),
    ),
    data: BackupDataV1(
      profiles: [
        _profileModel(localId: profileId, name: 'Alex'),
        ...extraProfiles,
      ],
      userEquipment: const [],
      bodyMeasurements: const [],
      pressureMeasurements: const [],
      appSettings: const BackupAppSettings(
        onboardingCompleted: true,
        themeMode: 'dark',
        notificationsEnabled: false,
      ),
      workouts: extraWorkouts,
      workoutExercises: extraWorkoutExercises,
      workoutSessions: extraWorkoutSessions,
      workoutSessionExercises: extraSessionExercises,
      walkingSessions: const [],
      plannedActivities: extraPlannedActivities,
    ),
  );
}
