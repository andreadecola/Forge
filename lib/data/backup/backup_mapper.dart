import '../../domain/entities/body_measurement.dart';
import '../../domain/entities/equipment_item.dart';
import '../../domain/entities/persisted_session_exercise.dart';
import '../../domain/entities/persisted_session_timer.dart';
import '../../domain/entities/persisted_workout_session.dart';
import '../../domain/entities/planned_activity.dart';
import '../../domain/entities/pressure_measurement.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/walking_session.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/repositories/body_metrics_repository.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/repositories/planned_activity_repository.dart';
import '../../domain/repositories/pressure_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/walking_session_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/workout_session_repository.dart';
import '../database/app_database.dart';
import 'backup_export_exceptions.dart';
import 'models/backup_app_settings.dart';
import 'models/backup_body_measurement.dart';
import 'models/backup_data_v1.dart';
import 'models/backup_planned_activity.dart';
import 'models/backup_pressure_measurement.dart';
import 'models/backup_profile.dart';
import 'models/backup_session_exercise.dart';
import 'models/backup_user_equipment.dart';
import 'models/backup_walking_session.dart';
import 'models/backup_workout.dart';
import 'models/backup_workout_exercise.dart';
import 'models/backup_workout_session.dart';

/// Costruisce lo snapshot dati del backup (Backup.1, sezione 13)
/// leggendo dai repository di dominio esistenti — mai da Drift
/// direttamente (eccetto [AppDatabase.currentCatalogVersions], l'unica
/// lettura puramente diagnostica senza controparte a livello dominio,
/// Backup.2 sezione 6).
///
/// Segue il database reale (Backup.2, sezione 64): non presume un
/// singolo profilo, itera su [ProfileRepository.getAllProfiles].
/// Ogni collezione è ordinata per `localId` crescente al termine
/// (Backup.2, sezione 40 — determinismo), indipendentemente dall'ordine
/// restituito dalle query.
class BackupMapper {
  const BackupMapper({
    required this.profileRepository,
    required this.equipmentRepository,
    required this.bodyMetricsRepository,
    required this.pressureRepository,
    required this.settingsRepository,
    required this.workoutRepository,
    required this.workoutSessionRepository,
    required this.walkingSessionRepository,
    required this.plannedActivityRepository,
    required this.exerciseRepository,
    required this.database,
  });

  final ProfileRepository profileRepository;
  final EquipmentRepository equipmentRepository;
  final BodyMetricsRepository bodyMetricsRepository;
  final PressureRepository pressureRepository;
  final SettingsRepository settingsRepository;
  final WorkoutRepository workoutRepository;
  final WorkoutSessionRepository workoutSessionRepository;
  final WalkingSessionRepository walkingSessionRepository;
  final PlannedActivityRepository plannedActivityRepository;
  final ExerciseRepository exerciseRepository;
  final AppDatabase database;

  /// Lancia [BackupExerciseCodeUnresolvedException] se un
  /// `WorkoutExercise`/`PersistedSessionExercise` referenzia un
  /// `exerciseId` assente dal catalogo (Backup.2, sezione 16): nessun
  /// riferimento nullo/inventato silenziosamente.
  Future<BackupDataV1> buildSnapshot() async {
    final profiles = await profileRepository.getAllProfiles();

    final userEquipment = <BackupUserEquipment>[];
    final bodyMeasurements = <BackupBodyMeasurement>[];
    final pressureMeasurements = <BackupPressureMeasurement>[];
    final workouts = <BackupWorkout>[];
    final workoutExercises = <BackupWorkoutExercise>[];
    final workoutSessions = <BackupWorkoutSession>[];
    final workoutSessionExercises = <BackupSessionExercise>[];
    final walkingSessions = <BackupWalkingSession>[];
    final plannedActivities = <BackupPlannedActivity>[];

    final exerciseCodeCache = <int, String>{};
    Future<String> resolveExerciseCode(int exerciseId) async {
      final cached = exerciseCodeCache[exerciseId];
      if (cached != null) return cached;
      final exercise = await exerciseRepository.getExerciseById(exerciseId);
      if (exercise == null) {
        throw BackupExerciseCodeUnresolvedException(exerciseId);
      }
      exerciseCodeCache[exerciseId] = exercise.code;
      return exercise.code;
    }

    for (final profile in profiles) {
      final profileId = profile.id!;

      for (final e in await equipmentRepository.getPersistedEquipmentRecords(
        profileId,
      )) {
        userEquipment.add(_mapUserEquipment(e));
      }

      for (final m in await bodyMetricsRepository.getMeasurementsByProfile(
        profileId,
      )) {
        bodyMeasurements.add(_mapBodyMeasurement(m));
      }

      for (final m in await pressureRepository.getMeasurementsByProfile(
        profileId,
      )) {
        pressureMeasurements.add(_mapPressureMeasurement(m));
      }

      final profileWorkouts = await workoutRepository.getAllWorkouts(
        profileId: profileId,
      );
      for (final workout in profileWorkouts) {
        workouts.add(_mapWorkout(workout));
        final details = await workoutRepository.getWorkoutDetails(workout.id!);
        if (details == null) continue;
        for (final entry in details.exercises) {
          workoutExercises.add(
            await _mapWorkoutExercise(
              entry.workoutExercise,
              resolveExerciseCode,
            ),
          );
        }
      }

      final profileSessions = await workoutSessionRepository.getAllSessions(
        profileId: profileId,
      );
      for (final session in profileSessions) {
        workoutSessions.add(_mapWorkoutSession(session));
        final exercises = await workoutSessionRepository.getSessionExercises(
          session.id!,
        );
        for (final exercise in exercises) {
          workoutSessionExercises.add(
            await _mapSessionExercise(exercise, resolveExerciseCode),
          );
        }
      }

      for (final w in await walkingSessionRepository.getWalkingSessions(
        profileId: profileId,
      )) {
        walkingSessions.add(_mapWalkingSession(w));
      }

      for (final a in await plannedActivityRepository.getAllForProfile(
        profileId: profileId,
      )) {
        plannedActivities.add(_mapPlannedActivity(a));
      }
    }

    int byLocalId(dynamic a, dynamic b) =>
        (a.localId as int).compareTo(b.localId as int);

    profiles.sort((a, b) => a.id!.compareTo(b.id!));
    userEquipment.sort(byLocalId);
    bodyMeasurements.sort(byLocalId);
    pressureMeasurements.sort(byLocalId);
    workouts.sort(byLocalId);
    workoutExercises.sort(byLocalId);
    workoutSessions.sort(byLocalId);
    workoutSessionExercises.sort(byLocalId);
    walkingSessions.sort(byLocalId);
    plannedActivities.sort(byLocalId);

    return BackupDataV1(
      profiles: [for (final p in profiles) _mapProfile(p)],
      userEquipment: userEquipment,
      bodyMeasurements: bodyMeasurements,
      pressureMeasurements: pressureMeasurements,
      appSettings: await _buildAppSettings(),
      workouts: workouts,
      workoutExercises: workoutExercises,
      workoutSessions: workoutSessions,
      workoutSessionExercises: workoutSessionExercises,
      walkingSessions: walkingSessions,
      plannedActivities: plannedActivities,
    );
  }

  Future<Map<String, int>> catalogVersions() =>
      database.currentCatalogVersions();

  int get databaseVersion => database.schemaVersion;

  Future<BackupAppSettings> _buildAppSettings() async {
    return BackupAppSettings(
      onboardingCompleted: await settingsRepository.isOnboardingCompleted(),
      themeMode: await settingsRepository.getThemeMode(),
      notificationsEnabled: await settingsRepository.getNotificationsEnabled(),
      plannedActivityRemindersEnabled: await settingsRepository
          .getPlannedActivityRemindersEnabled(),
      plannedActivityReminderTimeMinutes: await settingsRepository
          .getPlannedActivityReminderTimeMinutes(),
    );
  }

  BackupProfile _mapProfile(UserProfile p) => BackupProfile(
    localId: p.id!,
    name: p.name,
    birthDate: p.birthDate,
    biologicalSexForFormula: p.biologicalSexForFormula?.name,
    heightCm: p.heightCm,
    initialWeightKg: p.initialWeightKg,
    targetWeightKg: p.targetWeightKg,
    preferredWalkMinutes: p.preferredWalkMinutes,
    equipmentBudgetLimit: p.equipmentBudgetLimit,
    startDate: p.startDate,
    activityLevel: p.activityLevel.name,
    createdAt: p.createdAt,
    updatedAt: p.updatedAt,
  );

  BackupUserEquipment _mapUserEquipment(UserEquipmentState e) =>
      BackupUserEquipment(
        localId: e.id!,
        profileLocalId: e.profileId,
        equipmentCode: e.item.code,
        owned: e.owned,
        acquiredAt: e.acquiredAt,
        notes: e.notes,
      );

  BackupBodyMeasurement _mapBodyMeasurement(BodyMeasurement m) =>
      BackupBodyMeasurement(
        localId: m.id!,
        profileLocalId: m.profileId,
        measuredAt: m.measuredAt,
        weightKg: m.weightKg,
        neckCm: m.neckCm,
        chestCm: m.chestCm,
        waistCm: m.waistCm,
        abdomenCm: m.abdomenCm,
        hipsCm: m.hipsCm,
        leftArmCm: m.leftArmCm,
        rightArmCm: m.rightArmCm,
        leftThighCm: m.leftThighCm,
        rightThighCm: m.rightThighCm,
        leftCalfCm: m.leftCalfCm,
        rightCalfCm: m.rightCalfCm,
        notes: m.notes,
      );

  BackupPressureMeasurement _mapPressureMeasurement(PressureMeasurement m) =>
      BackupPressureMeasurement(
        localId: m.id!,
        profileLocalId: m.profileId,
        measuredAt: m.measuredAt,
        systolic: m.systolic,
        diastolic: m.diastolic,
        heartRate: m.heartRate,
        measurementContext: m.measurementContext,
        notes: m.notes,
      );

  BackupWorkout _mapWorkout(Workout w) => BackupWorkout(
    localId: w.id!,
    profileLocalId: w.profileId,
    name: w.name,
    description: w.description,
    type: w.type.code,
    level: w.level,
    estimatedDurationMinutes: w.estimatedDurationMinutes,
    status: w.status.code,
    origin: w.origin.code,
    isActive: w.isActive,
    createdAt: w.createdAt,
    updatedAt: w.updatedAt,
  );

  Future<BackupWorkoutExercise> _mapWorkoutExercise(
    WorkoutExercise e,
    Future<String> Function(int) resolveExerciseCode,
  ) async => BackupWorkoutExercise(
    localId: e.id!,
    workoutLocalId: e.workoutId,
    exerciseCode: await resolveExerciseCode(e.exerciseId),
    order: e.order,
    sets: e.sets,
    repetitions: e.repetitions,
    durationSeconds: e.durationSeconds,
    restSeconds: e.restSeconds,
    notes: e.notes,
    isActive: e.isActive,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );

  BackupWorkoutSession _mapWorkoutSession(PersistedWorkoutSession s) =>
      BackupWorkoutSession(
        localId: s.id!,
        profileLocalId: s.profileId,
        workoutLocalId: s.workoutId,
        workoutNameSnapshot: s.workoutNameSnapshot,
        status: s.status.code,
        currentExerciseIndex: s.currentExerciseIndex,
        startedAt: s.startedAt,
        endedAt: s.endedAt,
        isPaused: s.isPaused,
        isCompleted: s.isCompleted,
        timer: _mapTimer(s.timer),
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
      );

  BackupSessionTimer? _mapTimer(PersistedSessionTimer? t) {
    if (t == null) return null;
    return BackupSessionTimer(
      kind: t.kind.code,
      startedAt: t.startedAt,
      targetSeconds: t.targetSeconds,
      remainingPaused: t.remainingPaused,
    );
  }

  Future<BackupSessionExercise> _mapSessionExercise(
    PersistedSessionExercise e,
    Future<String> Function(int) resolveExerciseCode,
  ) async => BackupSessionExercise(
    localId: e.id!,
    sessionLocalId: e.sessionId,
    workoutExerciseLocalId: e.workoutExerciseId,
    exerciseCode: await resolveExerciseCode(e.exerciseId),
    order: e.order,
    totalSets: e.totalSets,
    completedSets: e.completedSets,
    repetitions: e.repetitions,
    durationSeconds: e.durationSeconds,
    restSeconds: e.restSeconds,
    isSkipped: e.isSkipped,
    isCompleted: e.isCompleted,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );

  BackupWalkingSession _mapWalkingSession(WalkingSession w) =>
      BackupWalkingSession(
        localId: w.id!,
        profileLocalId: w.profileId,
        startedAt: w.startedAt,
        endedAt: w.endedAt,
        distanceMeters: w.distanceMeters,
        steps: w.steps,
        isPaused: w.isPaused,
        pauseStartedAt: w.pauseStartedAt,
        accumulatedPauseSeconds: w.accumulatedPauseSeconds,
        status: w.status.code,
        notes: w.notes,
        createdAt: w.createdAt,
        updatedAt: w.updatedAt,
      );

  BackupPlannedActivity _mapPlannedActivity(PlannedActivity a) =>
      BackupPlannedActivity(
        localId: a.id!,
        profileLocalId: a.profileId,
        scheduledDate: a.scheduledDate,
        type: a.type.code,
        workoutLocalId: a.workoutId,
        plannedDurationMinutes: a.plannedDurationMinutes,
        status: a.status.code,
        origin: a.origin.code,
        notes: a.notes,
        workoutSessionLocalId: a.workoutSessionId,
        walkingSessionLocalId: a.walkingSessionId,
        createdAt: a.createdAt,
        updatedAt: a.updatedAt,
      );
}
