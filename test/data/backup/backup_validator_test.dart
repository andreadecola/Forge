import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/backup/backup_validation_issue.dart';
import 'package:forge/data/backup/backup_validator.dart';
import 'package:forge/data/backup/models/backup_app_settings.dart';
import 'package:forge/data/backup/models/backup_data_v1.dart';
import 'package:forge/data/backup/models/backup_metadata.dart';
import 'package:forge/data/backup/models/backup_planned_activity.dart';
import 'package:forge/data/backup/models/backup_profile.dart';
import 'package:forge/data/backup/models/backup_workout.dart';
import 'package:forge/data/backup/models/backup_workout_exercise.dart';
import 'package:forge/data/backup/models/forge_backup_v1.dart';

BackupProfile _profile({int localId = 1}) => BackupProfile(
  localId: localId,
  name: 'Alex',
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

BackupWorkout _workout({int localId = 10, int profileLocalId = 1}) =>
    BackupWorkout(
      localId: localId,
      profileLocalId: profileLocalId,
      name: 'Full Body',
      description: null,
      type: 'FULL_BODY',
      level: 1,
      estimatedDurationMinutes: 30,
      status: 'READY',
      origin: 'USER',
      isActive: true,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

ForgeBackupV1 _backupWith({
  List<BackupProfile>? profiles,
  List<BackupWorkout>? workouts,
  List<BackupWorkoutExercise>? workoutExercises,
  List<BackupPlannedActivity>? plannedActivities,
  int backupFormatVersion = 1,
}) {
  return ForgeBackupV1(
    metadata: BackupMetadata(
      backupFormatVersion: backupFormatVersion,
      databaseVersion: 11,
      catalogVersion: const {},
      appVersion: '1.0.0',
      exportedAt: DateTime.utc(2026, 8, 30),
    ),
    data: BackupDataV1(
      profiles: profiles ?? [_profile()],
      userEquipment: const [],
      bodyMeasurements: const [],
      pressureMeasurements: const [],
      appSettings: const BackupAppSettings(
        onboardingCompleted: true,
        themeMode: 'dark',
        notificationsEnabled: false,
      ),
      workouts: workouts ?? const [],
      workoutExercises: workoutExercises ?? const [],
      workoutSessions: const [],
      workoutSessionExercises: const [],
      walkingSessions: const [],
      plannedActivities: plannedActivities ?? const [],
    ),
  );
}

void main() {
  final alwaysExists = BackupValidator(exerciseCodeExists: (_) async => true);
  final neverExists = BackupValidator(exerciseCodeExists: (_) async => false);

  test('backup minimo valido non produce alcun problema', () async {
    final issues = await alwaysExists.validate(_backupWith());
    expect(issues, isEmpty);
  });

  test('backupFormatVersion non supportata viene segnalata', () async {
    final issues = await alwaysExists.validate(
      _backupWith(backupFormatVersion: 99),
    );
    expect(
      issues,
      contains(
        isA<BackupValidationIssue>().having(
          (i) => i.code,
          'code',
          BackupValidationIssueCode.unsupportedFormatVersion,
        ),
      ),
    );
  });

  test(
    'due profili con lo stesso localId vengono segnalati come duplicati',
    () async {
      final issues = await alwaysExists.validate(
        _backupWith(profiles: [_profile(localId: 1), _profile(localId: 1)]),
      );
      expect(
        issues,
        contains(
          isA<BackupValidationIssue>().having(
            (i) => i.code,
            'code',
            BackupValidationIssueCode.duplicateLocalId,
          ),
        ),
      );
    },
  );

  test('un workout che referenzia un profileLocalId inesistente è un '
      'riferimento pendente', () async {
    final issues = await alwaysExists.validate(
      _backupWith(workouts: [_workout(profileLocalId: 999)]),
    );
    expect(
      issues,
      contains(
        isA<BackupValidationIssue>().having(
          (i) => i.code,
          'code',
          BackupValidationIssueCode.danglingReference,
        ),
      ),
    );
  });

  test('un workoutExercise che referenzia un workoutLocalId inesistente è '
      'un riferimento pendente', () async {
    final issues = await alwaysExists.validate(
      _backupWith(
        workouts: [_workout()],
        workoutExercises: [
          BackupWorkoutExercise(
            localId: 100,
            workoutLocalId: 999,
            exerciseCode: 'EX-TEST',
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
      ),
    );
    expect(
      issues,
      contains(
        isA<BackupValidationIssue>().having(
          (i) => i.code,
          'code',
          BackupValidationIssueCode.danglingReference,
        ),
      ),
    );
  });

  test('un exerciseCode non presente nel catalogo di destinazione viene '
      'segnalato', () async {
    final issues = await neverExists.validate(
      _backupWith(
        workouts: [_workout()],
        workoutExercises: [
          BackupWorkoutExercise(
            localId: 100,
            workoutLocalId: 10,
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
      ),
    );
    expect(
      issues,
      contains(
        isA<BackupValidationIssue>().having(
          (i) => i.code,
          'code',
          BackupValidationIssueCode.unknownCatalogCode,
        ),
      ),
    );
  });

  test('un enum non riconosciuto (activityLevel) viene segnalato', () async {
    final issues = await alwaysExists.validate(
      _backupWith(
        profiles: [
          BackupProfile(
            localId: 1,
            name: 'Alex',
            birthDate: DateTime(1990, 1, 1),
            biologicalSexForFormula: null,
            heightCm: 175,
            initialWeightKg: 80,
            targetWeightKg: null,
            preferredWalkMinutes: 30,
            equipmentBudgetLimit: 50,
            startDate: DateTime(2026, 1, 1),
            activityLevel: 'iperattivo',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      ),
    );
    expect(
      issues,
      contains(
        isA<BackupValidationIssue>().having(
          (i) => i.code,
          'code',
          BackupValidationIssueCode.unrecognizedEnumValue,
        ),
      ),
    );
  });

  test(
    'un profilo con createdAt/updatedAt assenti (null) viene rifiutato '
    'esplicitamente PRIMA di qualunque scrittura (Backup.5, hardening)',
    () async {
      final issues = await alwaysExists.validate(
        _backupWith(
          profiles: [
            BackupProfile(
              localId: 1,
              name: 'Alex',
              birthDate: DateTime(1990, 1, 1),
              biologicalSexForFormula: null,
              heightCm: 175,
              initialWeightKg: 80,
              targetWeightKg: null,
              preferredWalkMinutes: 30,
              equipmentBudgetLimit: 50,
              startDate: DateTime(2026, 1, 1),
              activityLevel: 'sedentary',
              createdAt: null,
              updatedAt: null,
            ),
          ],
        ),
      );
      expect(
        issues,
        containsAll([
          isA<BackupValidationIssue>().having(
            (i) => i.code,
            'code',
            BackupValidationIssueCode.missingRequiredTimestamp,
          ),
        ]),
      );
      expect(issues, hasLength(2)); // createdAt + updatedAt
    },
  );

  group('invarianti PlannedActivity (stesse regole di AddPlannedActivity)', () {
    BackupPlannedActivity activity({
      required String type,
      int? workoutLocalId,
      int? workoutSessionLocalId,
      int? walkingSessionLocalId,
    }) => BackupPlannedActivity(
      localId: 1000,
      profileLocalId: 1,
      scheduledDate: DateTime(2026, 8, 31),
      type: type,
      workoutLocalId: workoutLocalId,
      plannedDurationMinutes: null,
      status: 'PLANNED',
      origin: 'USER',
      notes: null,
      workoutSessionLocalId: workoutSessionLocalId,
      walkingSessionLocalId: walkingSessionLocalId,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    test('WORKOUT senza workoutLocalId viola l\'invariante', () async {
      final issues = await alwaysExists.validate(
        _backupWith(plannedActivities: [activity(type: 'WORKOUT')]),
      );
      expect(
        issues,
        contains(
          isA<BackupValidationIssue>().having(
            (i) => i.code,
            'code',
            BackupValidationIssueCode.domainInvariantViolation,
          ),
        ),
      );
    });

    test('WALK con workoutLocalId viola l\'invariante', () async {
      final issues = await alwaysExists.validate(
        _backupWith(
          workouts: [_workout()],
          plannedActivities: [activity(type: 'WALK', workoutLocalId: 10)],
        ),
      );
      expect(
        issues,
        contains(
          isA<BackupValidationIssue>().having(
            (i) => i.code,
            'code',
            BackupValidationIssueCode.domainInvariantViolation,
          ),
        ),
      );
    });

    test('RECOVERY con walkingSessionLocalId viola l\'invariante', () async {
      final issues = await alwaysExists.validate(
        _backupWith(
          plannedActivities: [
            activity(type: 'RECOVERY', walkingSessionLocalId: 5),
          ],
        ),
      );
      expect(
        issues,
        contains(
          isA<BackupValidationIssue>().having(
            (i) => i.code,
            'code',
            BackupValidationIssueCode.domainInvariantViolation,
          ),
        ),
      );
    });

    test('WORKOUT valido con workoutLocalId coerente non produce '
        'problemi', () async {
      final issues = await alwaysExists.validate(
        _backupWith(
          workouts: [_workout()],
          plannedActivities: [activity(type: 'WORKOUT', workoutLocalId: 10)],
        ),
      );
      expect(issues, isEmpty);
    });

    test(
      'un\'attività del profilo 1 che referenzia un workout del profilo 2 '
      'viola l\'invariante cross-profilo (Backup.4, sezione 25/84)',
      () async {
        final issues = await alwaysExists.validate(
          _backupWith(
            profiles: [_profile(localId: 1), _profile(localId: 2)],
            workouts: [_workout(localId: 10, profileLocalId: 2)],
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
                createdAt: DateTime.utc(2026, 1, 1),
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ],
          ),
        );
        expect(
          issues,
          contains(
            isA<BackupValidationIssue>().having(
              (i) => i.code,
              'code',
              BackupValidationIssueCode.domainInvariantViolation,
            ),
          ),
        );
      },
    );
  });
}
