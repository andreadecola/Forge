import '../../domain/entities/biological_sex.dart';
import '../../core/constants/activity_level.dart';
import '../../domain/entities/equipment_item.dart';
import '../../domain/entities/persisted_session_timer_kind.dart';
import '../../domain/entities/planned_activity_enums.dart';
import '../../domain/entities/walking_session_status.dart';
import '../../domain/entities/workout_enums.dart';
import '../../domain/entities/workout_session_persistence_status.dart';
import 'backup_format_version.dart';
import 'backup_validation_issue.dart';
import 'models/backup_planned_activity.dart';
import 'models/backup_workout.dart';
import 'models/backup_workout_session.dart';
import 'models/forge_backup_v1.dart';

/// Verifica un [ForgeBackupV1] già strutturalmente valido (Backup.2,
/// sezione 47): riferimenti interni, ID duplicati, codici di catalogo,
/// enum riconosciuti, invarianti di dominio reali applicabili senza
/// toccare il database. Non ripete i controlli di tipo/campo
/// obbligatorio: quelli sono già garantiti da `BackupJsonCodec.decode`
/// (se il parsing fallisce, il backup non arriva mai qui).
///
/// [exerciseCodeExists] è iniettato (non un `ExerciseRepository`
/// diretto) per restare testabile senza un database reale — l'unico
/// controllo che genuinamente richiede una lettura DB (Backup.1, sezione
/// 5): tutti gli altri sono puramente strutturali sul modello già
/// parsato.
class BackupValidator {
  const BackupValidator({required this.exerciseCodeExists});

  final Future<bool> Function(String code) exerciseCodeExists;

  Future<List<BackupValidationIssue>> validate(ForgeBackupV1 backup) async {
    final issues = <BackupValidationIssue>[];
    _validateFormatVersion(backup, issues);
    _validateDuplicateLocalIds(backup, issues);
    _validateInternalReferences(backup, issues);
    _validateCrossProfileConsistency(backup, issues);
    _validateEnumValues(backup, issues);
    _validatePlannedActivityInvariants(backup, issues);
    _validateRequiredTimestamps(backup, issues);
    await _validateExerciseCodes(backup, issues);
    return issues;
  }

  void _validateFormatVersion(
    ForgeBackupV1 backup,
    List<BackupValidationIssue> issues,
  ) {
    if (!supportedBackupFormatVersions.contains(
      backup.metadata.backupFormatVersion,
    )) {
      issues.add(
        BackupValidationIssue(
          code: BackupValidationIssueCode.unsupportedFormatVersion,
          path: r'$.metadata.backupFormatVersion',
          message:
              'backupFormatVersion ${backup.metadata.backupFormatVersion} '
              'non supportata (supportate: $supportedBackupFormatVersions).',
        ),
      );
    }
  }

  void _validateDuplicateLocalIds(
    ForgeBackupV1 backup,
    List<BackupValidationIssue> issues,
  ) {
    void checkUnique(String collectionPath, Iterable<int> ids) {
      final seen = <int>{};
      for (final id in ids) {
        if (!seen.add(id)) {
          issues.add(
            BackupValidationIssue(
              code: BackupValidationIssueCode.duplicateLocalId,
              path: collectionPath,
              message: 'localId $id duplicato in $collectionPath.',
            ),
          );
        }
      }
    }

    final data = backup.data;
    checkUnique(r'$.data.profiles', data.profiles.map((e) => e.localId));
    checkUnique(
      r'$.data.userEquipment',
      data.userEquipment.map((e) => e.localId),
    );
    checkUnique(
      r'$.data.bodyMeasurements',
      data.bodyMeasurements.map((e) => e.localId),
    );
    checkUnique(
      r'$.data.pressureMeasurements',
      data.pressureMeasurements.map((e) => e.localId),
    );
    checkUnique(r'$.data.workouts', data.workouts.map((e) => e.localId));
    checkUnique(
      r'$.data.workoutExercises',
      data.workoutExercises.map((e) => e.localId),
    );
    checkUnique(
      r'$.data.workoutSessions',
      data.workoutSessions.map((e) => e.localId),
    );
    checkUnique(
      r'$.data.workoutSessionExercises',
      data.workoutSessionExercises.map((e) => e.localId),
    );
    checkUnique(
      r'$.data.walkingSessions',
      data.walkingSessions.map((e) => e.localId),
    );
    checkUnique(
      r'$.data.plannedActivities',
      data.plannedActivities.map((e) => e.localId),
    );
  }

  void _validateInternalReferences(
    ForgeBackupV1 backup,
    List<BackupValidationIssue> issues,
  ) {
    final data = backup.data;
    final profileIds = data.profiles.map((e) => e.localId).toSet();
    final workoutIds = data.workouts.map((e) => e.localId).toSet();
    final sessionIds = data.workoutSessions.map((e) => e.localId).toSet();
    final workoutExerciseIds = data.workoutExercises
        .map((e) => e.localId)
        .toSet();
    final walkingSessionIds = data.walkingSessions
        .map((e) => e.localId)
        .toSet();

    void checkRef(
      String path,
      int? ref,
      Set<int> validIds,
      String targetCollection,
    ) {
      if (ref == null) return;
      if (!validIds.contains(ref)) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.danglingReference,
            path: path,
            message:
                'Riferimento $ref verso $targetCollection inesistente nel '
                'backup.',
          ),
        );
      }
    }

    for (var i = 0; i < data.userEquipment.length; i++) {
      final e = data.userEquipment[i];
      checkRef(
        r'$.data.userEquipment['
            '$i].profileLocalId',
        e.profileLocalId,
        profileIds,
        'data.profiles',
      );
    }
    for (var i = 0; i < data.bodyMeasurements.length; i++) {
      final e = data.bodyMeasurements[i];
      checkRef(
        r'$.data.bodyMeasurements['
            '$i].profileLocalId',
        e.profileLocalId,
        profileIds,
        'data.profiles',
      );
    }
    for (var i = 0; i < data.pressureMeasurements.length; i++) {
      final e = data.pressureMeasurements[i];
      checkRef(
        r'$.data.pressureMeasurements['
            '$i].profileLocalId',
        e.profileLocalId,
        profileIds,
        'data.profiles',
      );
    }
    for (var i = 0; i < data.workouts.length; i++) {
      final e = data.workouts[i];
      checkRef(
        r'$.data.workouts['
            '$i].profileLocalId',
        e.profileLocalId,
        profileIds,
        'data.profiles',
      );
    }
    for (var i = 0; i < data.workoutExercises.length; i++) {
      final e = data.workoutExercises[i];
      checkRef(
        r'$.data.workoutExercises['
            '$i].workoutLocalId',
        e.workoutLocalId,
        workoutIds,
        'data.workouts',
      );
    }
    for (var i = 0; i < data.workoutSessions.length; i++) {
      final e = data.workoutSessions[i];
      checkRef(
        r'$.data.workoutSessions['
            '$i].profileLocalId',
        e.profileLocalId,
        profileIds,
        'data.profiles',
      );
      checkRef(
        r'$.data.workoutSessions['
            '$i].workoutLocalId',
        e.workoutLocalId,
        workoutIds,
        'data.workouts',
      );
    }
    for (var i = 0; i < data.workoutSessionExercises.length; i++) {
      final e = data.workoutSessionExercises[i];
      checkRef(
        r'$.data.workoutSessionExercises['
            '$i].sessionLocalId',
        e.sessionLocalId,
        sessionIds,
        'data.workoutSessions',
      );
      checkRef(
        r'$.data.workoutSessionExercises['
            '$i].workoutExerciseLocalId',
        e.workoutExerciseLocalId,
        workoutExerciseIds,
        'data.workoutExercises',
      );
    }
    for (var i = 0; i < data.walkingSessions.length; i++) {
      final e = data.walkingSessions[i];
      checkRef(
        r'$.data.walkingSessions['
            '$i].profileLocalId',
        e.profileLocalId,
        profileIds,
        'data.profiles',
      );
    }
    for (var i = 0; i < data.plannedActivities.length; i++) {
      final e = data.plannedActivities[i];
      final base =
          r'$.data.plannedActivities['
          '$i]';
      checkRef(
        '$base.profileLocalId',
        e.profileLocalId,
        profileIds,
        'data.profiles',
      );
      checkRef(
        '$base.workoutLocalId',
        e.workoutLocalId,
        workoutIds,
        'data.workouts',
      );
      checkRef(
        '$base.workoutSessionLocalId',
        e.workoutSessionLocalId,
        sessionIds,
        'data.workoutSessions',
      );
      checkRef(
        '$base.walkingSessionLocalId',
        e.walkingSessionLocalId,
        walkingSessionIds,
        'data.walkingSessions',
      );
    }
  }

  /// Verifica che ogni riferimento tra entità appartenga davvero allo
  /// stesso profilo (Backup.4, sezione 25/26/84): [_validateInternalReferences]
  /// controlla solo che l'ID puntato esista da qualche parte nel backup,
  /// non che appartenga al profilo corretto — un `PlannedActivity` del
  /// profilo A che referenzia un `Workout` del profilo B è strutturalmente
  /// "non pendente" ma comunque invalido, e deve essere rifiutato prima
  /// di qualunque scrittura.
  void _validateCrossProfileConsistency(
    ForgeBackupV1 backup,
    List<BackupValidationIssue> issues,
  ) {
    final data = backup.data;
    final profileOfWorkout = {
      for (final w in data.workouts) w.localId: w.profileLocalId,
    };
    final profileOfSession = {
      for (final s in data.workoutSessions) s.localId: s.profileLocalId,
    };
    final profileOfWalk = {
      for (final w in data.walkingSessions) w.localId: w.profileLocalId,
    };

    void checkSameProfile(
      String path,
      int ownerProfileLocalId,
      int? referencedLocalId,
      Map<int, int> profileByLocalId,
      String targetLabel,
    ) {
      if (referencedLocalId == null) return;
      final referencedProfile = profileByLocalId[referencedLocalId];
      // Un riferimento pendente è già segnalato altrove
      // (danglingReference): qui si segnala solo un profilo diverso.
      if (referencedProfile != null &&
          referencedProfile != ownerProfileLocalId) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.domainInvariantViolation,
            path: path,
            message:
                '$targetLabel $referencedLocalId appartiene al profilo '
                '$referencedProfile, non al profilo $ownerProfileLocalId '
                'del riferimento.',
          ),
        );
      }
    }

    for (var i = 0; i < data.workoutSessions.length; i++) {
      final s = data.workoutSessions[i];
      checkSameProfile(
        r'$.data.workoutSessions['
            '$i].workoutLocalId',
        s.profileLocalId,
        s.workoutLocalId,
        profileOfWorkout,
        'Workout',
      );
    }

    for (var i = 0; i < data.plannedActivities.length; i++) {
      final a = data.plannedActivities[i];
      final base =
          r'$.data.plannedActivities['
          '$i]';
      checkSameProfile(
        '$base.workoutLocalId',
        a.profileLocalId,
        a.workoutLocalId,
        profileOfWorkout,
        'Workout',
      );
      checkSameProfile(
        '$base.workoutSessionLocalId',
        a.profileLocalId,
        a.workoutSessionLocalId,
        profileOfSession,
        'WorkoutSession',
      );
      checkSameProfile(
        '$base.walkingSessionLocalId',
        a.profileLocalId,
        a.walkingSessionLocalId,
        profileOfWalk,
        'WalkingSession',
      );
    }
  }

  void _validateEnumValues(
    ForgeBackupV1 backup,
    List<BackupValidationIssue> issues,
  ) {
    void checkEnum(String path, String value, Set<String> allowed) {
      if (!allowed.contains(value)) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.unrecognizedEnumValue,
            path: path,
            message: 'Valore "$value" non riconosciuto (attesi: $allowed).',
          ),
        );
      }
    }

    final workoutTypes = WorkoutType.values.map((e) => e.code).toSet();
    final workoutStatuses = WorkoutDefinitionStatus.values
        .map((e) => e.code)
        .toSet();
    final workoutOrigins = WorkoutOrigin.values.map((e) => e.code).toSet();
    final sessionStatuses = WorkoutSessionPersistenceStatus.values
        .map((e) => e.code)
        .toSet();
    final timerKinds = PersistedSessionTimerKind.values
        .map((e) => e.code)
        .toSet();
    final walkingStatuses = WalkingSessionStatus.values
        .map((e) => e.code)
        .toSet();
    final activityTypes = PlannedActivityType.values.map((e) => e.code).toSet();
    final activityStatuses = PlannedActivityStatus.values
        .map((e) => e.code)
        .toSet();
    final activityOrigins = PlannedActivityOrigin.values
        .map((e) => e.code)
        .toSet();
    final biologicalSexes = BiologicalSexForFormula.values
        .map((e) => e.name)
        .toSet();
    final activityLevels = ActivityLevel.values.map((e) => e.name).toSet();
    final equipmentCodes = EquipmentItem.values.map((e) => e.code).toSet();

    for (var i = 0; i < backup.data.profiles.length; i++) {
      final p = backup.data.profiles[i];
      final base =
          r'$.data.profiles['
          '$i]';
      final sex = p.biologicalSexForFormula;
      if (sex != null) {
        checkEnum('$base.biologicalSexForFormula', sex, biologicalSexes);
      }
      checkEnum('$base.activityLevel', p.activityLevel, activityLevels);
    }
    for (var i = 0; i < backup.data.userEquipment.length; i++) {
      final e = backup.data.userEquipment[i];
      checkEnum(
        r'$.data.userEquipment['
        '$i].equipmentCode',
        e.equipmentCode,
        equipmentCodes,
      );
    }
    for (var i = 0; i < backup.data.workouts.length; i++) {
      final BackupWorkout w = backup.data.workouts[i];
      final base =
          r'$.data.workouts['
          '$i]';
      checkEnum('$base.type', w.type, workoutTypes);
      checkEnum('$base.status', w.status, workoutStatuses);
      checkEnum('$base.origin', w.origin, workoutOrigins);
    }
    for (var i = 0; i < backup.data.workoutSessions.length; i++) {
      final BackupWorkoutSession s = backup.data.workoutSessions[i];
      final base =
          r'$.data.workoutSessions['
          '$i]';
      checkEnum('$base.status', s.status, sessionStatuses);
      final timer = s.timer;
      if (timer != null) {
        checkEnum('$base.timer.kind', timer.kind, timerKinds);
      }
    }
    for (var i = 0; i < backup.data.walkingSessions.length; i++) {
      final w = backup.data.walkingSessions[i];
      checkEnum(
        r'$.data.walkingSessions['
        '$i].status',
        w.status,
        walkingStatuses,
      );
    }
    for (var i = 0; i < backup.data.plannedActivities.length; i++) {
      final BackupPlannedActivity a = backup.data.plannedActivities[i];
      final base =
          r'$.data.plannedActivities['
          '$i]';
      checkEnum('$base.type', a.type, activityTypes);
      checkEnum('$base.status', a.status, activityStatuses);
      checkEnum('$base.origin', a.origin, activityOrigins);
    }
  }

  /// Stesse regole reali di `AddPlannedActivity`/`UpdatePlannedActivity`
  /// (Milestone 8.1/8.5): `workoutLocalId` obbligatorio solo per WORKOUT,
  /// `workoutSessionLocalId` solo per WORKOUT, `walkingSessionLocalId`
  /// solo per WALK.
  void _validatePlannedActivityInvariants(
    ForgeBackupV1 backup,
    List<BackupValidationIssue> issues,
  ) {
    for (var i = 0; i < backup.data.plannedActivities.length; i++) {
      final a = backup.data.plannedActivities[i];
      final base =
          r'$.data.plannedActivities['
          '$i]';
      final isWorkout = a.type == PlannedActivityType.workout.code;
      final isWalk = a.type == PlannedActivityType.walk.code;

      if (isWorkout && a.workoutLocalId == null) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.domainInvariantViolation,
            path: '$base.workoutLocalId',
            message: 'Attività WORKOUT senza workoutLocalId.',
          ),
        );
      }
      if (!isWorkout && a.workoutLocalId != null) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.domainInvariantViolation,
            path: '$base.workoutLocalId',
            message: 'Solo un\'attività WORKOUT può avere workoutLocalId.',
          ),
        );
      }
      if (!isWorkout && a.workoutSessionLocalId != null) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.domainInvariantViolation,
            path: '$base.workoutSessionLocalId',
            message:
                'Solo un\'attività WORKOUT può avere workoutSessionLocalId.',
          ),
        );
      }
      if (!isWalk && a.walkingSessionLocalId != null) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.domainInvariantViolation,
            path: '$base.walkingSessionLocalId',
            message: 'Solo un\'attività WALK può avere walkingSessionLocalId.',
          ),
        );
      }
    }
  }

  /// `createdAt`/`updatedAt` sono nullable nei modelli di backup (per
  /// tollerare in lettura un JSON strutturalmente valido ma con questi
  /// campi assenti), ma le colonne DB reali sono sempre NOT NULL: un
  /// backup genuinamente prodotto da Forge li valorizza sempre.
  /// Rifiutare qui, PRIMA di aprire qualunque transazione (Backup.5,
  /// hardening), un valore null evita che il restore lo scopra solo
  /// all'insert (un cast `!` fallito, intercettato solo dal catch
  /// generico) — un messaggio di errore specifico è preferibile a un
  /// fallimento generico tardivo.
  void _validateRequiredTimestamps(
    ForgeBackupV1 backup,
    List<BackupValidationIssue> issues,
  ) {
    void checkPresent(String path, DateTime? value) {
      if (value == null) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.missingRequiredTimestamp,
            path: path,
            message: 'Campo temporale obbligatorio assente (null).',
          ),
        );
      }
    }

    final data = backup.data;
    for (var i = 0; i < data.profiles.length; i++) {
      final base =
          r'$.data.profiles['
          '$i]';
      checkPresent('$base.createdAt', data.profiles[i].createdAt);
      checkPresent('$base.updatedAt', data.profiles[i].updatedAt);
    }
    for (var i = 0; i < data.workouts.length; i++) {
      final base =
          r'$.data.workouts['
          '$i]';
      checkPresent('$base.createdAt', data.workouts[i].createdAt);
      checkPresent('$base.updatedAt', data.workouts[i].updatedAt);
    }
    for (var i = 0; i < data.workoutExercises.length; i++) {
      final base =
          r'$.data.workoutExercises['
          '$i]';
      checkPresent('$base.createdAt', data.workoutExercises[i].createdAt);
      checkPresent('$base.updatedAt', data.workoutExercises[i].updatedAt);
    }
    for (var i = 0; i < data.workoutSessions.length; i++) {
      final base =
          r'$.data.workoutSessions['
          '$i]';
      checkPresent('$base.createdAt', data.workoutSessions[i].createdAt);
      checkPresent('$base.updatedAt', data.workoutSessions[i].updatedAt);
    }
    for (var i = 0; i < data.workoutSessionExercises.length; i++) {
      final base =
          r'$.data.workoutSessionExercises['
          '$i]';
      checkPresent(
        '$base.createdAt',
        data.workoutSessionExercises[i].createdAt,
      );
      checkPresent(
        '$base.updatedAt',
        data.workoutSessionExercises[i].updatedAt,
      );
    }
    for (var i = 0; i < data.walkingSessions.length; i++) {
      final base =
          r'$.data.walkingSessions['
          '$i]';
      checkPresent('$base.createdAt', data.walkingSessions[i].createdAt);
      checkPresent('$base.updatedAt', data.walkingSessions[i].updatedAt);
    }
    for (var i = 0; i < data.plannedActivities.length; i++) {
      final base =
          r'$.data.plannedActivities['
          '$i]';
      checkPresent('$base.createdAt', data.plannedActivities[i].createdAt);
      checkPresent('$base.updatedAt', data.plannedActivities[i].updatedAt);
    }
  }

  Future<void> _validateExerciseCodes(
    ForgeBackupV1 backup,
    List<BackupValidationIssue> issues,
  ) async {
    final checked = <String, bool>{};
    Future<void> check(String path, String code) async {
      final exists = checked[code] ??= await exerciseCodeExists(code);
      if (!exists) {
        issues.add(
          BackupValidationIssue(
            code: BackupValidationIssueCode.unknownCatalogCode,
            path: path,
            message:
                'Codice esercizio "$code" non presente nel catalogo di '
                'questa installazione.',
          ),
        );
      }
    }

    for (var i = 0; i < backup.data.workoutExercises.length; i++) {
      await check(
        r'$.data.workoutExercises['
        '$i].exerciseCode',
        backup.data.workoutExercises[i].exerciseCode,
      );
    }
    for (var i = 0; i < backup.data.workoutSessionExercises.length; i++) {
      await check(
        r'$.data.workoutSessionExercises['
        '$i].exerciseCode',
        backup.data.workoutSessionExercises[i].exerciseCode,
      );
    }
  }
}
