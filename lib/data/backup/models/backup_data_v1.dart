import 'backup_app_settings.dart';
import 'backup_body_measurement.dart';
import 'backup_planned_activity.dart';
import 'backup_pressure_measurement.dart';
import 'backup_profile.dart';
import 'backup_session_exercise.dart';
import 'backup_user_equipment.dart';
import 'backup_walking_session.dart';
import 'backup_workout.dart';
import 'backup_workout_exercise.dart';
import 'backup_workout_session.dart';
import '../backup_json_helpers.dart';

/// Corpo dati del backup v1 (Backup.1, sezione 13): le 11 aree dato
/// utente/storiche incluse, il catalogo esercizi escluso (Backup.1,
/// sezione 13). Ogni collezione è ordinata in modo deterministico dal
/// mapper (Backup.2, sezione 40), mai nell'ordine restituito da SQLite.
class BackupDataV1 {
  const BackupDataV1({
    required this.profiles,
    required this.userEquipment,
    required this.bodyMeasurements,
    required this.pressureMeasurements,
    required this.appSettings,
    required this.workouts,
    required this.workoutExercises,
    required this.workoutSessions,
    required this.workoutSessionExercises,
    required this.walkingSessions,
    required this.plannedActivities,
  });

  final List<BackupProfile> profiles;
  final List<BackupUserEquipment> userEquipment;
  final List<BackupBodyMeasurement> bodyMeasurements;
  final List<BackupPressureMeasurement> pressureMeasurements;
  final BackupAppSettings appSettings;
  final List<BackupWorkout> workouts;
  final List<BackupWorkoutExercise> workoutExercises;
  final List<BackupWorkoutSession> workoutSessions;
  final List<BackupSessionExercise> workoutSessionExercises;
  final List<BackupWalkingSession> walkingSessions;
  final List<BackupPlannedActivity> plannedActivities;

  Map<String, dynamic> toJson() => {
    'profiles': profiles.map((e) => e.toJson()).toList(),
    'userEquipment': userEquipment.map((e) => e.toJson()).toList(),
    'bodyMeasurements': bodyMeasurements.map((e) => e.toJson()).toList(),
    'pressureMeasurements': pressureMeasurements
        .map((e) => e.toJson())
        .toList(),
    'appSettings': appSettings.toJson(),
    'workouts': workouts.map((e) => e.toJson()).toList(),
    'workoutExercises': workoutExercises.map((e) => e.toJson()).toList(),
    'workoutSessions': workoutSessions.map((e) => e.toJson()).toList(),
    'workoutSessionExercises': workoutSessionExercises
        .map((e) => e.toJson())
        .toList(),
    'walkingSessions': walkingSessions.map((e) => e.toJson()).toList(),
    'plannedActivities': plannedActivities.map((e) => e.toJson()).toList(),
  };

  static BackupDataV1 fromJson(Map<String, dynamic> json, String path) {
    List<T> parseList<T>(
      String key,
      T Function(Map<String, dynamic>, String) parseItem,
    ) {
      final items = requireObjectList(json, key, path);
      return [
        for (var i = 0; i < items.length; i++)
          parseItem(items[i], '$path.$key[$i]'),
      ];
    }

    return BackupDataV1(
      profiles: parseList('profiles', BackupProfile.fromJson),
      userEquipment: parseList('userEquipment', BackupUserEquipment.fromJson),
      bodyMeasurements: parseList(
        'bodyMeasurements',
        BackupBodyMeasurement.fromJson,
      ),
      pressureMeasurements: parseList(
        'pressureMeasurements',
        BackupPressureMeasurement.fromJson,
      ),
      appSettings: BackupAppSettings.fromJson(
        requireObject(json, 'appSettings', path),
        '$path.appSettings',
      ),
      workouts: parseList('workouts', BackupWorkout.fromJson),
      workoutExercises: parseList(
        'workoutExercises',
        BackupWorkoutExercise.fromJson,
      ),
      workoutSessions: parseList(
        'workoutSessions',
        BackupWorkoutSession.fromJson,
      ),
      workoutSessionExercises: parseList(
        'workoutSessionExercises',
        BackupSessionExercise.fromJson,
      ),
      walkingSessions: parseList(
        'walkingSessions',
        BackupWalkingSession.fromJson,
      ),
      plannedActivities: parseList(
        'plannedActivities',
        BackupPlannedActivity.fromJson,
      ),
    );
  }
}
