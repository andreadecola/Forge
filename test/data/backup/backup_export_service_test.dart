import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/backup/backup_export_result.dart';
import 'package:forge/data/backup/backup_export_service.dart';
import 'package:forge/data/backup/backup_json_codec.dart';
import 'package:forge/data/backup/backup_mapper.dart';
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
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_alternative.dart';
import 'package:forge/domain/entities/exercise_category.dart';
import 'package:forge/domain/entities/exercise_details.dart';
import 'package:forge/domain/entities/exercise_image.dart';
import 'package:forge/domain/entities/exercise_progression.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/repositories/exercise_repository.dart';
import 'package:forge/domain/services/clock.dart';

import '../workout_test_helpers.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._value);
  final DateTime _value;
  @override
  DateTime now() => _value;
}

/// Delega tutto a un [ExerciseRepository] reale tranne
/// [getExerciseByCode], che ritorna sempre `null`: usato per forzare
/// deterministicamente un fallimento della self-validation dell'export
/// (Backup.2, sezione 83) senza dover corrompere il catalogo reale.
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
  late int profileId;
  late int exerciseAId;
  late int exerciseBId;

  late DriftExerciseRepository exerciseRepository;
  late DriftWorkoutRepository workoutRepository;
  late DriftWorkoutSessionRepository workoutSessionRepository;
  late DriftWalkingSessionRepository walkingSessionRepository;
  late DriftPlannedActivityRepository plannedActivityRepository;
  late ProfileRepositoryImpl profileRepository;
  late EquipmentRepositoryImpl equipmentRepository;
  late BodyMetricsRepositoryImpl bodyMetricsRepository;
  late PressureRepositoryImpl pressureRepository;
  late SettingsRepositoryImpl settingsRepository;

  BackupMapper buildMapper() => BackupMapper(
    profileRepository: profileRepository,
    equipmentRepository: equipmentRepository,
    bodyMetricsRepository: bodyMetricsRepository,
    pressureRepository: pressureRepository,
    settingsRepository: settingsRepository,
    workoutRepository: workoutRepository,
    workoutSessionRepository: workoutSessionRepository,
    walkingSessionRepository: walkingSessionRepository,
    plannedActivityRepository: plannedActivityRepository,
    exerciseRepository: exerciseRepository,
    database: db,
  );

  Future<int> createWorkout({
    required WorkoutOrigin origin,
    required bool active,
    required List<int> exerciseIds,
  }) async {
    final now = DateTime(2026, 1, 1);
    final workout = Workout(
      profileId: profileId,
      name: 'Scheda ${origin.code}',
      type: WorkoutType.fullBody,
      level: 1,
      estimatedDurationMinutes: 30,
      status: WorkoutDefinitionStatus.ready,
      origin: origin,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    final exercises = [
      for (var i = 0; i < exerciseIds.length; i++)
        WorkoutExercise(
          workoutId: 0,
          exerciseId: exerciseIds[i],
          order: i + 1,
          sets: 3,
          repetitions: 10,
          restSeconds: 60,
          createdAt: now,
          updatedAt: now,
        ),
    ];
    final id = await workoutRepository.createWorkoutWithExercises(
      workout: workout,
      exercises: exercises,
    );
    if (!active) {
      await workoutRepository.archiveWorkout(id);
    }
    return id;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    profileId = await insertProfilo(db);
    final categoriaId = await insertCategoria(db);
    exerciseAId = await insertEsercizio(
      db,
      codice: 'EX-A',
      idCategoria: categoriaId,
    );
    exerciseBId = await insertEsercizio(
      db,
      codice: 'EX-B',
      idCategoria: categoriaId,
    );

    exerciseRepository = DriftExerciseRepository(db);
    workoutRepository = DriftWorkoutRepository(db);
    workoutSessionRepository = DriftWorkoutSessionRepository(db);
    walkingSessionRepository = DriftWalkingSessionRepository(db);
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    profileRepository = ProfileRepositoryImpl(db.userProfileDao);
    equipmentRepository = EquipmentRepositoryImpl(db.userEquipmentDao);
    bodyMetricsRepository = BodyMetricsRepositoryImpl(db.bodyMeasurementsDao);
    pressureRepository = PressureRepositoryImpl(db.pressureMeasurementsDao);
    settingsRepository = SettingsRepositoryImpl(db.appSettingsDao);
  });

  tearDown(() => db.close());

  /// Popola l'intero dataset rappresentativo pianificato in Backup.1
  /// (sezione 60): profilo, attrezzatura, misurazioni, pressione, 3
  /// Workout (USER/FORGE_ENGINE/archiviato), sessioni COMPLETED/ABORTED,
  /// camminate COMPLETED/ABORTED/IN_PROGRESS, PlannedActivity in ogni
  /// combinazione tipo/stato/origine rilevante, su più settimane.
  Future<void> populateRepresentativeDataset() async {
    await db
        .into(db.userEquipmentTable)
        .insert(
          UserEquipmentTableCompanion.insert(
            profileId: profileId,
            equipmentCode: 'chair',
            owned: const Value(true),
            acquiredAt: Value(DateTime(2025, 12, 1)),
            notes: const Value('Regalo di Natale'),
          ),
        );
    await db
        .into(db.userEquipmentTable)
        .insert(
          UserEquipmentTableCompanion.insert(
            profileId: profileId,
            equipmentCode: 'wall',
            owned: const Value(false),
          ),
        );

    await bodyMetricsRepository.addMeasurement(
      BodyMeasurement(
        profileId: profileId,
        measuredAt: DateTime.utc(2026, 1, 5),
        weightKg: null,
        waistCm: 90,
      ),
    );

    await pressureRepository.addMeasurement(
      PressureMeasurement(
        profileId: profileId,
        measuredAt: DateTime.utc(2026, 1, 5, 8),
        systolic: 120,
        diastolic: 80,
        heartRate: 65,
      ),
    );

    final userWorkoutId = await createWorkout(
      origin: WorkoutOrigin.user,
      active: true,
      exerciseIds: [exerciseAId, exerciseBId],
    );
    final forgeWorkoutId = await createWorkout(
      origin: WorkoutOrigin.forgeEngine,
      active: true,
      exerciseIds: [exerciseAId],
    );
    await createWorkout(
      origin: WorkoutOrigin.user,
      active: false,
      exerciseIds: [exerciseBId],
    );

    final userDetails = await workoutRepository.getWorkoutDetails(
      userWorkoutId,
    );
    final completedSessionId = await workoutSessionRepository.createSession(
      profileId: profileId,
      details: userDetails!,
      startedAt: DateTime.utc(2026, 1, 10, 9),
    );
    await workoutSessionRepository.completeSession(
      sessionId: completedSessionId,
      endedAt: DateTime.utc(2026, 1, 10, 9, 40),
    );

    final forgeDetails = await workoutRepository.getWorkoutDetails(
      forgeWorkoutId,
    );
    final abortedSessionId = await workoutSessionRepository.createSession(
      profileId: profileId,
      details: forgeDetails!,
      startedAt: DateTime.utc(2026, 1, 12, 9),
    );
    await workoutSessionRepository.abortSession(
      sessionId: abortedSessionId,
      endedAt: DateTime.utc(2026, 1, 12, 9, 5),
    );

    final completedWalkId = await walkingSessionRepository.createWalkingSession(
      WalkingSession(
        profileId: profileId,
        startedAt: DateTime.utc(2026, 1, 6, 7),
        status: WalkingSessionStatus.inProgress,
      ),
    );
    await walkingSessionRepository.completeWalkingSession(
      sessionId: completedWalkId,
      endedAt: DateTime.utc(2026, 1, 6, 7, 30),
      distanceMeters: 2500,
      steps: 3200,
    );

    final abortedWalkId = await walkingSessionRepository.createWalkingSession(
      WalkingSession(
        profileId: profileId,
        startedAt: DateTime.utc(2026, 1, 7, 7),
        status: WalkingSessionStatus.inProgress,
      ),
    );
    await walkingSessionRepository.abortWalkingSession(
      sessionId: abortedWalkId,
      endedAt: DateTime.utc(2026, 1, 7, 7, 5),
    );

    await walkingSessionRepository.createWalkingSession(
      WalkingSession(
        profileId: profileId,
        startedAt: DateTime.utc(2026, 1, 20, 7),
        status: WalkingSessionStatus.inProgress,
      ),
    );

    final workoutActivityId = await plannedActivityRepository
        .addPlannedActivity(
          PlannedActivity(
            profileId: profileId,
            scheduledDate: DateTime(2026, 1, 10),
            type: PlannedActivityType.workout,
            workoutId: userWorkoutId,
            origin: PlannedActivityOrigin.user,
          ),
        );
    await plannedActivityRepository.linkWorkoutSession(
      activityId: workoutActivityId,
      workoutSessionId: completedSessionId,
    );

    final walkActivityId = await plannedActivityRepository.addPlannedActivity(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 1, 6),
        type: PlannedActivityType.walk,
        plannedDurationMinutes: 30,
        origin: PlannedActivityOrigin.forgeEngine,
      ),
    );
    await plannedActivityRepository.linkWalkingSession(
      activityId: walkActivityId,
      walkingSessionId: completedWalkId,
    );

    await plannedActivityRepository.addPlannedActivity(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 1, 11),
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.user,
      ),
    );

    await plannedActivityRepository.addPlannedActivity(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 2, 2),
        type: PlannedActivityType.recovery,
        status: PlannedActivityStatus.skipped,
        origin: PlannedActivityOrigin.user,
      ),
    );

    await plannedActivityRepository.addPlannedActivity(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 2, 9),
        type: PlannedActivityType.recovery,
        status: PlannedActivityStatus.postponed,
        origin: PlannedActivityOrigin.user,
      ),
    );

    await settingsRepository.setOnboardingCompleted(true);
    await settingsRepository.setThemeMode('dark');
    await settingsRepository.setNotificationsEnabled(false);
  }

  test('export di un DB fresco (solo profilo, nessun altro dato utente) '
      'produce un backup valido con collezioni vuote', () async {
    final service = BackupExportService(
      mapper: buildMapper(),
      exerciseRepository: exerciseRepository,
    );

    final result = await service.export();

    expect(result.isSuccess, isTrue, reason: '${result.errors}');
    final data = result.backup!.data;
    expect(data.profiles, hasLength(1));
    expect(data.workouts, isEmpty);
    expect(data.workoutExercises, isEmpty);
    expect(data.workoutSessions, isEmpty);
    expect(data.walkingSessions, isEmpty);
    expect(data.plannedActivities, isEmpty);
    expect(data.userEquipment, isEmpty);
    expect(data.bodyMeasurements, isEmpty);
    expect(data.pressureMeasurements, isEmpty);
    // Nessuna tabella catalogo seedata in questo test (nessun
    // ExerciseCatalogSeeder eseguito): la mappa è vuota, non assente.
    expect(result.backup!.metadata.catalogVersion, isEmpty);
    expect(result.backup!.metadata.databaseVersion, 11);
    expect(result.backup!.metadata.backupFormatVersion, 1);
  });

  test('export del dataset rappresentativo (Backup.1, sezione 60) ha successo '
      'e preserva ogni area dato reale', () async {
    await populateRepresentativeDataset();
    final service = BackupExportService(
      mapper: buildMapper(),
      exerciseRepository: exerciseRepository,
      clock: _FixedClock(DateTime.utc(2026, 2, 15, 12)),
    );

    final result = await service.export();
    expect(result.isSuccess, isTrue, reason: '${result.errors}');
    final data = result.backup!.data;

    expect(result.backup!.metadata.exportedAt, DateTime.utc(2026, 2, 15, 12));

    // Attrezzatura: righe realmente persistite, per codice stabile.
    expect(data.userEquipment, hasLength(2));
    final chair = data.userEquipment.firstWhere(
      (e) => e.equipmentCode == 'chair',
    );
    expect(chair.owned, isTrue);
    expect(chair.notes, 'Regalo di Natale');
    final wall = data.userEquipment.firstWhere(
      (e) => e.equipmentCode == 'wall',
    );
    expect(wall.owned, isFalse);

    // Misurazioni: null preservato per weightKg, non convertito in 0.
    expect(data.bodyMeasurements, hasLength(1));
    expect(data.bodyMeasurements.single.weightKg, isNull);
    expect(data.bodyMeasurements.single.waistCm, 90);

    expect(data.pressureMeasurements, hasLength(1));
    expect(data.pressureMeasurements.single.systolic, 120);

    // Workout: USER attivo, FORGE_ENGINE attivo, USER archiviato — tutti
    // e tre inclusi (Backup.1, sezione 62).
    expect(data.workouts, hasLength(3));
    final origins = data.workouts.map((w) => w.origin).toSet();
    expect(origins, {'USER', 'FORGE_ENGINE'});
    final archived = data.workouts.where((w) => !w.isActive);
    expect(archived, hasLength(1));

    // Catalogo: exerciseCode risolto dall'exerciseId numerico, mai un
    // ID grezzo (Backup.1, sezione 5; Backup.2, sezione 16/69).
    expect(data.workoutExercises, hasLength(4));
    final codes = data.workoutExercises.map((e) => e.exerciseCode).toSet();
    expect(codes, {'EX-A', 'EX-B'});

    // Sessioni: COMPLETED e ABORTED entrambe incluse (Backup.1, sezione
    // 63 — non solo record "positivi").
    expect(data.workoutSessions, hasLength(2));
    final sessionStatuses = data.workoutSessions.map((s) => s.status).toSet();
    expect(sessionStatuses, {'COMPLETED', 'ABORTED'});
    expect(data.workoutSessionExercises, isNotEmpty);
    for (final se in data.workoutSessionExercises) {
      expect(codes, contains(se.exerciseCode));
    }

    // Camminate: COMPLETED, ABORTED, IN_PROGRESS tutte incluse.
    expect(data.walkingSessions, hasLength(3));
    final walkStatuses = data.walkingSessions.map((w) => w.status).toSet();
    expect(walkStatuses, {'COMPLETED', 'ABORTED', 'IN_PROGRESS'});

    // Piano settimanale: ogni combinazione tipo/stato/origine, link
    // sessione preservati come riferimenti interni.
    expect(data.plannedActivities, hasLength(5));
    final workoutActivity = data.plannedActivities.firstWhere(
      (a) => a.type == 'WORKOUT',
    );
    expect(workoutActivity.workoutSessionLocalId, isNotNull);
    final completedSessionLocalId = data.workoutSessions
        .firstWhere((s) => s.status == 'COMPLETED')
        .localId;
    expect(workoutActivity.workoutSessionLocalId, completedSessionLocalId);

    final walkActivity = data.plannedActivities.firstWhere(
      (a) => a.type == 'WALK',
    );
    expect(walkActivity.walkingSessionLocalId, isNotNull);
    expect(walkActivity.origin, 'FORGE_ENGINE');

    final statuses = data.plannedActivities.map((a) => a.status).toSet();
    expect(statuses, {'PLANNED', 'SKIPPED', 'POSTPONED'});

    // Impostazioni: solo le 3 chiavi note, valori realmente impostati.
    expect(data.appSettings.onboardingCompleted, isTrue);
    expect(data.appSettings.themeMode, 'dark');
    expect(data.appSettings.notificationsEnabled, isFalse);

    // Round-trip JSON completo: nessuna perdita di dati.
    final reparsed = BackupJsonCodec.decode(result.json!);
    expect(reparsed.data.workouts, hasLength(3));
    expect(reparsed.data.plannedActivities, hasLength(5));
  });

  test('due export consecutivi con lo stesso clock producono JSON '
      'identico (determinismo, Backup.2 sezione 71)', () async {
    await populateRepresentativeDataset();
    final fixedClock = _FixedClock(DateTime.utc(2026, 2, 15, 12));

    final first = await BackupExportService(
      mapper: buildMapper(),
      exerciseRepository: exerciseRepository,
      clock: fixedClock,
    ).export();
    final second = await BackupExportService(
      mapper: buildMapper(),
      exerciseRepository: exerciseRepository,
      clock: fixedClock,
    ).export();

    expect(first.isSuccess, isTrue, reason: '${first.errors}');
    expect(second.isSuccess, isTrue, reason: '${second.errors}');
    expect(first.json, second.json);
  });

  test('l\'export non scrive mai sul database (sola lettura, Backup.2 '
      'sezione 39)', () async {
    await populateRepresentativeDataset();

    Future<Map<String, int>> countRows() async => {
      'workouts': (await db.allenamentiDao.getAllByProfile(profileId)).length,
      'sessions': (await db.sessioniAllenamentoDao.getAllByProfile(
        profileId,
      )).length,
      'walks': (await db.camminateDao.getByProfile(profileId)).length,
      'plans': (await db.attivitaPianificateDao.getAllByProfile(
        profileId,
      )).length,
    };

    final before = await countRows();
    final result = await BackupExportService(
      mapper: buildMapper(),
      exerciseRepository: exerciseRepository,
    ).export();
    final after = await countRows();

    expect(result.isSuccess, isTrue, reason: '${result.errors}');
    expect(after, before);
  });

  test('se un exerciseCode non risolve sul catalogo di questa installazione '
      'la self-validation fallisce e l\'export non è dichiarato riuscito '
      '(Backup.2, sezione 83)', () async {
    await populateRepresentativeDataset();
    final service = BackupExportService(
      mapper: buildMapper(),
      exerciseRepository: _AlwaysMissingCatalogRepository(exerciseRepository),
    );

    final result = await service.export();

    expect(result.isSuccess, isFalse);
    expect(result.backup, isNull);
    expect(result.json, isNull);
    expect(
      result.errors,
      contains(
        isA<BackupExportFailure>().having(
          (f) => f.reason,
          'reason',
          BackupExportFailureReason.selfCheckValidation,
        ),
      ),
    );
  });

  test('con due profili nel DB l\'export include entrambi e i dati di '
      'ciascuno restano correttamente associati, senza contaminazione '
      'incrociata (Backup.3, sezione 3/47/48)', () async {
    // Profilo A: dataset minimo già popolato da populateRepresentativeDataset.
    await populateRepresentativeDataset();

    // Profilo B: un secondo profilo con il proprio workout/sessione/piano
    // distinti, per verificare che il mapper itera davvero su TUTTI i
    // profili (non solo "il corrente") e non mescola mai i dati.
    final now = DateTime(2026, 3, 1);
    final profileBId = await db
        .into(db.userProfilesTable)
        .insert(
          UserProfilesTableCompanion.insert(
            name: 'Sam',
            birthDate: DateTime(1985, 5, 20),
            heightCm: 168,
            initialWeightKg: 65,
            preferredWalkMinutes: 20,
            equipmentBudgetLimit: 30,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    final workoutB = Workout(
      profileId: profileBId,
      name: 'Scheda di Sam',
      type: WorkoutType.mobility,
      level: 1,
      status: WorkoutDefinitionStatus.ready,
      origin: WorkoutOrigin.user,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    final workoutBId = await workoutRepository.createWorkoutWithExercises(
      workout: workoutB,
      exercises: [
        WorkoutExercise(
          workoutId: 0,
          exerciseId: exerciseBId,
          order: 1,
          sets: 2,
          repetitions: 8,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    await plannedActivityRepository.addPlannedActivity(
      PlannedActivity(
        profileId: profileBId,
        scheduledDate: DateTime(2026, 3, 2),
        type: PlannedActivityType.workout,
        workoutId: workoutBId,
        origin: PlannedActivityOrigin.user,
      ),
    );

    final result = await BackupExportService(
      mapper: buildMapper(),
      exerciseRepository: exerciseRepository,
    ).export();

    expect(result.isSuccess, isTrue, reason: '${result.errors}');
    final data = result.backup!.data;

    // Entrambi i profili presenti.
    expect(data.profiles, hasLength(2));
    final profileA = data.profiles.firstWhere((p) => p.name == 'Alex');
    final profileB = data.profiles.firstWhere((p) => p.name == 'Sam');

    // Ogni Workout referenzia il profileLocalId corretto: nessuna
    // contaminazione incrociata.
    final workoutsOfA = data.workouts.where(
      (w) => w.profileLocalId == profileA.localId,
    );
    final workoutsOfB = data.workouts.where(
      (w) => w.profileLocalId == profileB.localId,
    );
    expect(workoutsOfA, hasLength(3)); // dataset rappresentativo del profilo A
    expect(workoutsOfB, hasLength(1));
    expect(workoutsOfB.single.name, 'Scheda di Sam');

    // Il piano di B non compare come attività del profilo A e viceversa.
    final plansOfA = data.plannedActivities.where(
      (a) => a.profileLocalId == profileA.localId,
    );
    final plansOfB = data.plannedActivities.where(
      (a) => a.profileLocalId == profileB.localId,
    );
    expect(plansOfA, hasLength(5));
    expect(plansOfB, hasLength(1));
    expect(
      plansOfB.single.workoutLocalId,
      data.workouts.firstWhere((w) => w.name == 'Scheda di Sam').localId,
    );

    // Nessun workoutExercise di B referenzia (per errore) un workout di A.
    final workoutBLocalId = workoutsOfB.single.localId;
    final exercisesOfB = data.workoutExercises.where(
      (e) => e.workoutLocalId == workoutBLocalId,
    );
    expect(exercisesOfB, hasLength(1));
    expect(exercisesOfB.single.exerciseCode, 'EX-B');
  });
}
