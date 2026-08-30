import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/backup/backup_format_exception.dart';
import 'package:forge/data/backup/backup_json_codec.dart';
import 'package:forge/data/backup/models/backup_app_settings.dart';
import 'package:forge/data/backup/models/backup_data_v1.dart';
import 'package:forge/data/backup/models/backup_metadata.dart';
import 'package:forge/data/backup/models/backup_planned_activity.dart';
import 'package:forge/data/backup/models/backup_profile.dart';
import 'package:forge/data/backup/models/backup_workout.dart';
import 'package:forge/data/backup/models/backup_workout_exercise.dart';
import 'package:forge/data/backup/models/forge_backup_v1.dart';

ForgeBackupV1 _sampleBackup() {
  return ForgeBackupV1(
    metadata: BackupMetadata(
      backupFormatVersion: 1,
      databaseVersion: 11,
      catalogVersion: const {'ESERCIZI': 2},
      appVersion: '1.0.0',
      exportedAt: DateTime.utc(2026, 8, 30, 7, 30, 15),
    ),
    data: BackupDataV1(
      profiles: [
        BackupProfile(
          localId: 1,
          name: 'Alex',
          birthDate: DateTime(1990, 1, 1),
          biologicalSexForFormula: null,
          heightCm: 175,
          initialWeightKg: 80.5,
          targetWeightKg: null,
          preferredWalkMinutes: 30,
          equipmentBudgetLimit: 50,
          startDate: DateTime(2026, 1, 1),
          activityLevel: 'sedentary',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
      userEquipment: const [],
      bodyMeasurements: const [],
      pressureMeasurements: const [],
      appSettings: const BackupAppSettings(
        onboardingCompleted: true,
        themeMode: 'dark',
        notificationsEnabled: false,
      ),
      workouts: [
        BackupWorkout(
          localId: 10,
          profileLocalId: 1,
          name: 'Full Body',
          description: null,
          type: 'FULL_BODY',
          level: 1,
          estimatedDurationMinutes: 30,
          status: 'READY',
          origin: 'USER',
          isActive: true,
          createdAt: DateTime.utc(2026, 1, 2),
          updatedAt: DateTime.utc(2026, 1, 2),
        ),
      ],
      workoutExercises: [
        BackupWorkoutExercise(
          localId: 100,
          workoutLocalId: 10,
          exerciseCode: 'EX-TEST',
          order: 1,
          sets: 3,
          repetitions: 10,
          durationSeconds: null,
          restSeconds: 60,
          notes: null,
          isActive: true,
          createdAt: DateTime.utc(2026, 1, 2),
          updatedAt: DateTime.utc(2026, 1, 2),
        ),
      ],
      workoutSessions: const [],
      workoutSessionExercises: const [],
      walkingSessions: const [],
      plannedActivities: [
        BackupPlannedActivity(
          localId: 1000,
          profileLocalId: 1,
          scheduledDate: DateTime(2026, 8, 31),
          type: 'WORKOUT',
          workoutLocalId: 10,
          plannedDurationMinutes: null,
          status: 'PLANNED',
          origin: 'USER',
          notes: null,
          workoutSessionLocalId: null,
          walkingSessionLocalId: null,
          createdAt: DateTime.utc(2026, 8, 24),
          updatedAt: DateTime.utc(2026, 8, 24),
        ),
      ],
    ),
  );
}

void main() {
  group('BackupJsonCodec — round trip', () {
    test('model -> JSON -> model preserva ogni campo', () {
      final original = _sampleBackup();
      final json = BackupJsonCodec.encode(original);
      final decoded = BackupJsonCodec.decode(json);

      expect(decoded.metadata.backupFormatVersion, 1);
      expect(decoded.metadata.databaseVersion, 11);
      expect(decoded.metadata.catalogVersion, {'ESERCIZI': 2});
      expect(decoded.metadata.appVersion, '1.0.0');
      expect(decoded.metadata.exportedAt, original.metadata.exportedAt);

      expect(decoded.data.profiles, hasLength(1));
      final profile = decoded.data.profiles.single;
      expect(profile.localId, 1);
      expect(profile.name, 'Alex');
      expect(profile.birthDate, DateTime(1990, 1, 1));
      expect(profile.biologicalSexForFormula, isNull);
      expect(profile.initialWeightKg, 80.5);
      expect(profile.targetWeightKg, isNull);

      final workout = decoded.data.workouts.single;
      expect(workout.localId, 10);
      expect(workout.type, 'FULL_BODY');
      expect(workout.description, isNull);

      final exercise = decoded.data.workoutExercises.single;
      expect(exercise.exerciseCode, 'EX-TEST');
      expect(exercise.durationSeconds, isNull);
      expect(exercise.sets, 3);

      final activity = decoded.data.plannedActivities.single;
      expect(activity.scheduledDate, DateTime(2026, 8, 31));
      expect(activity.workoutLocalId, 10);
      expect(activity.workoutSessionLocalId, isNull);
    });

    test('output è pretty-printed (indentato, non compatto)', () {
      final json = BackupJsonCodec.encode(_sampleBackup());
      expect(json, contains('\n'));
      expect(json, contains('  "metadata"'));
    });

    test('un campo JSON extra sconosciuto viene ignorato (forward '
        'compatibility)', () {
      final json = BackupJsonCodec.encode(_sampleBackup());
      final withExtra = json.replaceFirst(
        '"metadata": {',
        '"metadata": {\n    "futureField": "qualcosa",',
      );
      expect(() => BackupJsonCodec.decode(withExtra), returnsNormally);
    });

    test('backup precedente senza le nuove preferenze resta compatibile', () {
      final root =
          jsonDecode(BackupJsonCodec.encode(_sampleBackup()))
              as Map<String, dynamic>;
      final appSettings =
          Map<String, dynamic>.from(
              (root['data'] as Map<String, dynamic>)['appSettings']
                  as Map<String, dynamic>,
            )
            ..remove('plannedActivityRemindersEnabled')
            ..remove('plannedActivityReminderTimeMinutes');
      root['data'] = {
        ...root['data'] as Map<String, dynamic>,
        'appSettings': appSettings,
      };
      final reparsed = BackupJsonCodec.decode(jsonEncode(root));
      expect(
        reparsed.data.appSettings.plannedActivityRemindersEnabled,
        isFalse,
      );
      expect(
        reparsed.data.appSettings.plannedActivityReminderTimeMinutes,
        isNull,
      );
    });
  });

  group('BackupJsonCodec — errori strutturali', () {
    test('JSON troncato/non valido lancia BackupFormatException', () {
      expect(
        () => BackupJsonCodec.decode('{"metadata": '),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('root non-object lancia BackupFormatException', () {
      expect(
        () => BackupJsonCodec.decode('[1, 2, 3]'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('metadata assente lancia BackupFormatException', () {
      expect(
        () => BackupJsonCodec.decode('{"data": {}}'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('campo obbligatorio mancante in un profilo lancia '
        'BackupFormatException con path preciso', () {
      final json = BackupJsonCodec.encode(_sampleBackup());
      final corrupted = json.replaceFirst('"name": "Alex",', '');
      expect(
        () => BackupJsonCodec.decode(corrupted),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.path,
            'path',
            contains('profiles[0]'),
          ),
        ),
      );
    });

    test('tipo errato (stringa al posto di numero) lancia '
        'BackupFormatException', () {
      final json = BackupJsonCodec.encode(_sampleBackup());
      final corrupted = json.replaceFirst(
        '"initialWeightKg": 80.5,',
        '"initialWeightKg": "ottanta",',
      );
      expect(
        () => BackupJsonCodec.decode(corrupted),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('data-only in un formato non valido lancia FormatException', () {
      final json = BackupJsonCodec.encode(_sampleBackup());
      final corrupted = json.replaceFirst(
        '"birthDate": "1990-01-01",',
        '"birthDate": "01/01/1990",',
      );
      expect(() => BackupJsonCodec.decode(corrupted), throwsFormatException);
    });

    test('backupFormatVersion di tipo errato lancia BackupFormatException', () {
      final json = BackupJsonCodec.encode(_sampleBackup());
      final corrupted = json.replaceFirst(
        '"backupFormatVersion": 1,',
        '"backupFormatVersion": "uno",',
      );
      expect(
        () => BackupJsonCodec.decode(corrupted),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });
}
