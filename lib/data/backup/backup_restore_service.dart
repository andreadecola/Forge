import 'package:drift/drift.dart';

import '../../domain/entities/planned_activity.dart';
import '../../domain/entities/planned_activity_enums.dart';
import '../../domain/entities/walking_session.dart';
import '../../domain/entities/walking_session_status.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_enums.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../database/app_database.dart';
import '../repositories/planned_activity_mappers.dart';
import '../repositories/settings_repository_impl.dart';
import '../repositories/walking_session_mappers.dart';
import '../repositories/workout_mappers.dart';
import 'backup_export_service.dart';
import 'backup_format_exception.dart';
import 'backup_json_codec.dart';
import 'backup_restore_result.dart';
import 'backup_validation_issue.dart';
import 'backup_validator.dart';
import 'models/backup_app_settings.dart';
import 'models/backup_data_v1.dart';
import 'models/forge_backup_v1.dart';

/// Lanciata internamente per far scattare il rollback Drift quando la
/// verifica post-restore (Backup.4, sezione 50/109) fallisce **mentre la
/// transazione è ancora aperta**: mai un restore dichiarato riuscito su
/// uno stato che la verifica stessa considera sospetto.
class _RestoreVerificationFailedException implements Exception {
  const _RestoreVerificationFailedException(this.issues);
  final List<String> issues;
  @override
  String toString() => 'Verifica post-restore fallita: ${issues.join('; ')}';
}

/// Mapping tipizzati e separati per collezione (Backup.4, sezione 28/29):
/// mai una singola `Map<int,int>` condivisa, perché i `localId` di
/// tabelle diverse non sono comparabili tra loro (potrebbero collidere
/// numericamente senza avere alcuna relazione).
class _RestoreIdMappings {
  final profileIds = <int, int>{};
  final workoutIds = <int, int>{};
  final workoutExerciseIds = <int, int>{};
  final workoutSessionIds = <int, int>{};
  final walkingSessionIds = <int, int>{};
}

/// Restore atomico REPLACE del backup v1 (Backup.4): legge un JSON già
/// letto da file (Backup.4 non fa parsing di file, solo di stringhe già
/// decodificate — quello spetta a [BackupFileReader]), lo valida
/// interamente PRIMA di toccare il database, crea un backup di sicurezza
/// dello stato corrente, poi in un'unica transazione Drift: cancella i
/// dati utente correnti (mai il catalogo), inserisce ogni riga del
/// backup con nuovi ID (Backup.1, sezione 9), rimappando ogni
/// riferimento interno, e verifica il risultato prima di considerare il
/// restore concluso.
class BackupRestoreService {
  const BackupRestoreService({
    required this.database,
    required this.exerciseRepository,
    required this.exportService,
  });

  final AppDatabase database;
  final ExerciseRepository exerciseRepository;

  /// Riusato sia per il backup di sicurezza pre-restore (sezione 6) sia
  /// per la verifica post-restore tramite re-export (sezione 53): stesso
  /// [AppDatabase] dell'app, mai un'istanza separata — nessuna
  /// duplicazione della logica di export (sezione 6).
  final BackupExportService exportService;

  Future<BackupRestoreResult> restore(String backupJson) async {
    final ForgeBackupV1 backup;
    try {
      backup = BackupJsonCodec.decode(backupJson);
    } on BackupFormatException catch (e) {
      return BackupRestoreResult.failure(
        BackupRestoreFailureReason.invalidBackup,
        e.toString(),
      );
    }

    // Politica di versione conservativa (sezione 18/19/20/21): mai uno
    // schema futuro sconosciuto, mai un tentativo best-effort. La
    // compatibilità di `backupFormatVersion` è invece verificata **solo**
    // da `BackupValidator` più sotto (unica fonte di verità, evita di
    // ripetere lo stesso controllo in due punti — hardening Backup.5):
    // `database.schemaVersion` non è invece noto al validator (che resta
    // indipendente dal database), quindi questo confronto resta l'unico
    // posto corretto per farlo.
    if (backup.metadata.databaseVersion > database.schemaVersion) {
      return BackupRestoreResult.failure(
        BackupRestoreFailureReason.incompatibleVersion,
        'Il backup proviene da una versione del database (${backup.metadata.databaseVersion}) '
        'più recente di quella corrente (${database.schemaVersion}).',
      );
    }

    // Validazione semantica completa PRIMA di ogni scrittura (sezione 9/26/49):
    // formato, riferimenti interni, enum, invarianti di dominio, codici
    // catalogo, campi temporali obbligatori.
    final validator = BackupValidator(
      exerciseCodeExists: (code) async =>
          (await exerciseRepository.getExerciseByCode(code)) != null,
    );
    final issues = await validator.validate(backup);
    if (issues.isNotEmpty) {
      final onlyVersionIssue =
          issues.length == 1 &&
          issues.single.code ==
              BackupValidationIssueCode.unsupportedFormatVersion;
      final onlyCatalogIssues = issues.every(
        (i) => i.code == BackupValidationIssueCode.unknownCatalogCode,
      );
      final reason = onlyVersionIssue
          ? BackupRestoreFailureReason.incompatibleVersion
          : onlyCatalogIssues
          ? BackupRestoreFailureReason.catalogMismatch
          : BackupRestoreFailureReason.invalidBackup;
      return BackupRestoreResult.failure(
        reason,
        issues.map((i) => i.toString()).join('; '),
      );
    }

    // Backup di sicurezza dello stato corrente (sezione 6/7/57): mantenuto
    // solo in memoria per questa chiamata, mai scritto su file qui — il
    // rollback tecnico è garantito dalla transazione Drift; questo serve
    // da rete di sicurezza aggiuntiva e da riferimento diagnostico
    // (sezione 8/115), non da meccanismo di rollback esso stesso.
    final safetyExport = await exportService.export();
    if (!safetyExport.isSuccess) {
      return BackupRestoreResult.failure(
        BackupRestoreFailureReason.restoreFailure,
        'Impossibile creare il backup di sicurezza dello stato corrente '
        'prima del restore: ${safetyExport.errors.map((e) => e.toString()).join('; ')}',
      );
    }

    // Risoluzione di TUTTI i codici catalogo verso gli ID numerici
    // attuali (sezione 23/24): già garantita risolvibile dalla
    // validazione sopra, quindi un fallimento qui è un errore interno,
    // non un caso atteso — mai uno skip silenzioso.
    final exerciseIdByCode = <String, int>{};
    for (final code in {
      for (final e in backup.data.workoutExercises) e.exerciseCode,
      for (final e in backup.data.workoutSessionExercises) e.exerciseCode,
    }) {
      final exercise = await exerciseRepository.getExerciseByCode(code);
      if (exercise == null) {
        return BackupRestoreResult.failure(
          BackupRestoreFailureReason.catalogMismatch,
          'Codice esercizio "$code" non risolvibile (verifica catalogo '
          'incoerente con la validazione appena eseguita).',
        );
      }
      exerciseIdByCode[code] = exercise.id;
    }

    try {
      await database.transaction(() async {
        await _clearUserData();
        final mapping = await _insertAll(backup.data, exerciseIdByCode);
        await _restoreSettings(backup.data.appSettings);

        final verificationIssues = await _verifyRestore(backup, mapping);
        if (verificationIssues.isNotEmpty) {
          throw _RestoreVerificationFailedException(verificationIssues);
        }
      });
    } on _RestoreVerificationFailedException catch (e) {
      return BackupRestoreResult.failure(
        BackupRestoreFailureReason.verificationFailure,
        e.toString(),
      );
    } catch (e) {
      return BackupRestoreResult.failure(
        BackupRestoreFailureReason.restoreFailure,
        'Restore fallito, nessuna modifica applicata: $e',
      );
    }

    return BackupRestoreResult.success(
      safetyBackupMetadata: safetyExport.backup!.metadata,
    );
  }

  /// Ordine di cancellazione sicuro rispetto ai vincoli FK reali
  /// (Backup.1, sezione 8; verificato leggendo ogni tabella): le tabelle
  /// con `onDelete` non esplicito verso `profili_utente` (quindi
  /// `NO ACTION`) devono essere svuotate PRIMA dei profili — mai un
  /// affidamento cieco su CASCADE dove lo schema non lo garantisce
  /// (sezione 45). Il catalogo (`esercizi`, `categorie_esercizi`,
  /// `attrezzature`, ecc.) e `versioni_catalogo` non vengono mai toccati
  /// (sezione 44/73/100/101).
  Future<void> _clearUserData() async {
    await database.delete(database.attivitaPianificateTable).go();
    // CASCADE su sessioni_esercizi.
    await database.delete(database.sessioniAllenamentoTable).go();
    await database.delete(database.camminateTable).go();
    // CASCADE su allenamenti_esercizi.
    await database.delete(database.allenamentiTable).go();
    await database.delete(database.bodyMeasurementsTable).go();
    await database.delete(database.pressureMeasurementsTable).go();
    await database.delete(database.userEquipmentTable).go();
    await database.delete(database.userProfilesTable).go();
  }

  /// Ordine di inserimento esatto definito in Backup.1 (sezione 8/31):
  /// profili → attrezzatura utente → misurazioni corporee → pressione →
  /// allenamenti → righe scheda → camminate → sessioni → righe sessione →
  /// piano settimanale. Ogni passo usa solo i mapping già popolati dai
  /// passi precedenti (mai un riferimento in avanti non ancora risolto).
  Future<_RestoreIdMappings> _insertAll(
    BackupDataV1 data,
    Map<String, int> exerciseIdByCode,
  ) async {
    final mapping = _RestoreIdMappings();

    for (final p in data.profiles) {
      final newId = await database
          .into(database.userProfilesTable)
          .insert(
            UserProfilesTableCompanion.insert(
              name: p.name,
              birthDate: p.birthDate,
              biologicalSexForFormula: Value(p.biologicalSexForFormula),
              heightCm: p.heightCm,
              initialWeightKg: p.initialWeightKg,
              targetWeightKg: Value(p.targetWeightKg),
              preferredWalkMinutes: p.preferredWalkMinutes,
              equipmentBudgetLimit: p.equipmentBudgetLimit,
              startDate: p.startDate,
              activityLevel: Value(p.activityLevel),
              createdAt: p.createdAt!,
              updatedAt: p.updatedAt!,
            ),
          );
      mapping.profileIds[p.localId] = newId;
    }

    for (final e in data.userEquipment) {
      await database
          .into(database.userEquipmentTable)
          .insert(
            UserEquipmentTableCompanion.insert(
              profileId: mapping.profileIds[e.profileLocalId]!,
              equipmentCode: e.equipmentCode,
              owned: Value(e.owned),
              acquiredAt: Value(e.acquiredAt),
              notes: Value(e.notes),
            ),
          );
    }

    for (final m in data.bodyMeasurements) {
      await database
          .into(database.bodyMeasurementsTable)
          .insert(
            BodyMeasurementsTableCompanion.insert(
              profileId: mapping.profileIds[m.profileLocalId]!,
              measuredAt: m.measuredAt,
              weightKg: Value(m.weightKg),
              neckCm: Value(m.neckCm),
              chestCm: Value(m.chestCm),
              waistCm: Value(m.waistCm),
              abdomenCm: Value(m.abdomenCm),
              hipsCm: Value(m.hipsCm),
              leftArmCm: Value(m.leftArmCm),
              rightArmCm: Value(m.rightArmCm),
              leftThighCm: Value(m.leftThighCm),
              rightThighCm: Value(m.rightThighCm),
              leftCalfCm: Value(m.leftCalfCm),
              rightCalfCm: Value(m.rightCalfCm),
              notes: Value(m.notes),
            ),
          );
    }

    for (final m in data.pressureMeasurements) {
      await database
          .into(database.pressureMeasurementsTable)
          .insert(
            PressureMeasurementsTableCompanion.insert(
              profileId: mapping.profileIds[m.profileLocalId]!,
              measuredAt: m.measuredAt,
              systolic: m.systolic,
              diastolic: m.diastolic,
              heartRate: Value(m.heartRate),
              measurementContext: Value(m.measurementContext),
              notes: Value(m.notes),
            ),
          );
    }

    for (final w in data.workouts) {
      final domainWorkout = Workout(
        profileId: mapping.profileIds[w.profileLocalId]!,
        name: w.name,
        description: w.description,
        type: WorkoutType.fromCode(w.type),
        level: w.level,
        estimatedDurationMinutes: w.estimatedDurationMinutes,
        status: WorkoutDefinitionStatus.fromCode(w.status),
        origin: WorkoutOrigin.fromCode(w.origin),
        isActive: w.isActive,
        createdAt: w.createdAt,
        updatedAt: w.updatedAt,
      );
      final newId = await database
          .into(database.allenamentiTable)
          .insert(
            WorkoutMappers.workoutToCompanion(domainWorkout, now: w.updatedAt),
          );
      mapping.workoutIds[w.localId] = newId;
    }

    for (final we in data.workoutExercises) {
      final domainExercise = WorkoutExercise(
        workoutId: mapping.workoutIds[we.workoutLocalId]!,
        exerciseId: exerciseIdByCode[we.exerciseCode]!,
        order: we.order,
        sets: we.sets,
        repetitions: we.repetitions,
        durationSeconds: we.durationSeconds,
        restSeconds: we.restSeconds,
        notes: we.notes,
        isActive: we.isActive,
        createdAt: we.createdAt,
        updatedAt: we.updatedAt,
      );
      final newId = await database
          .into(database.allenamentiEserciziTable)
          .insert(
            WorkoutMappers.workoutExerciseToCompanion(
              domainExercise,
              now: we.updatedAt,
            ),
          );
      mapping.workoutExerciseIds[we.localId] = newId;
    }

    for (final ws in data.walkingSessions) {
      final domainWalk = WalkingSession(
        profileId: mapping.profileIds[ws.profileLocalId]!,
        startedAt: ws.startedAt,
        endedAt: ws.endedAt,
        distanceMeters: ws.distanceMeters,
        steps: ws.steps,
        isPaused: ws.isPaused,
        pauseStartedAt: ws.pauseStartedAt,
        accumulatedPauseSeconds: ws.accumulatedPauseSeconds,
        status: WalkingSessionStatus.fromCode(ws.status),
        notes: ws.notes,
        createdAt: ws.createdAt,
        updatedAt: ws.updatedAt,
      );
      final newId = await database
          .into(database.camminateTable)
          .insert(
            WalkingSessionMappers.toCompanion(domainWalk, now: ws.updatedAt!),
          );
      mapping.walkingSessionIds[ws.localId] = newId;
    }

    for (final s in data.workoutSessions) {
      final newId = await database
          .into(database.sessioniAllenamentoTable)
          .insert(
            SessioniAllenamentoTableCompanion.insert(
              idAllenamento: Value(
                s.workoutLocalId == null
                    ? null
                    : mapping.workoutIds[s.workoutLocalId],
              ),
              idProfilo: mapping.profileIds[s.profileLocalId]!,
              nomeAllenamentoSnapshot: s.workoutNameSnapshot,
              stato: s.status,
              indiceEsercizioCorrente: Value(s.currentExerciseIndex),
              dataInizio: s.startedAt,
              dataFine: Value(s.endedAt),
              inPausa: Value(s.isPaused),
              completata: Value(s.isCompleted),
              timerTipo: Value(s.timer?.kind),
              timerStartedAt: Value(s.timer?.startedAt),
              timerTargetSeconds: Value(s.timer?.targetSeconds),
              timerRemainingPaused: Value(s.timer?.remainingPaused),
              dataCreazione: s.createdAt!,
              dataModifica: s.updatedAt!,
            ),
          );
      mapping.workoutSessionIds[s.localId] = newId;
    }

    for (final se in data.workoutSessionExercises) {
      await database
          .into(database.sessioniEserciziTable)
          .insert(
            SessioniEserciziTableCompanion.insert(
              idSessione: mapping.workoutSessionIds[se.sessionLocalId]!,
              idAllenamentoEsercizio: Value(
                se.workoutExerciseLocalId == null
                    ? null
                    : mapping.workoutExerciseIds[se.workoutExerciseLocalId],
              ),
              idEsercizio: exerciseIdByCode[se.exerciseCode]!,
              ordine: se.order,
              serieTotali: se.totalSets,
              serieCompletate: Value(se.completedSets),
              ripetizioni: Value(se.repetitions),
              durataSecondi: Value(se.durationSeconds),
              recuperoSecondi: Value(se.restSeconds),
              saltato: Value(se.isSkipped),
              completato: Value(se.isCompleted),
              dataCreazione: se.createdAt!,
              dataModifica: se.updatedAt!,
            ),
          );
    }

    for (final a in data.plannedActivities) {
      final domainActivity = PlannedActivity(
        profileId: mapping.profileIds[a.profileLocalId]!,
        scheduledDate: a.scheduledDate,
        type: PlannedActivityType.fromCode(a.type),
        workoutId: a.workoutLocalId == null
            ? null
            : mapping.workoutIds[a.workoutLocalId],
        plannedDurationMinutes: a.plannedDurationMinutes,
        status: PlannedActivityStatus.fromCode(a.status),
        origin: PlannedActivityOrigin.fromCode(a.origin),
        notes: a.notes,
        workoutSessionId: a.workoutSessionLocalId == null
            ? null
            : mapping.workoutSessionIds[a.workoutSessionLocalId],
        walkingSessionId: a.walkingSessionLocalId == null
            ? null
            : mapping.walkingSessionIds[a.walkingSessionLocalId],
        createdAt: a.createdAt,
        updatedAt: a.updatedAt,
      );
      await database
          .into(database.attivitaPianificateTable)
          .insert(
            PlannedActivityMappers.toCompanion(
              domainActivity,
              now: a.updatedAt,
            ),
          );
    }

    return mapping;
  }

  /// Solo le 3 chiavi previste dal contratto v1 (sezione 43): nessuna
  /// chiave sconosciuta viene mai importata.
  Future<void> _restoreSettings(BackupAppSettings appSettings) async {
    final repo = SettingsRepositoryImpl(database.appSettingsDao);
    await repo.setOnboardingCompleted(appSettings.onboardingCompleted);
    await repo.setThemeMode(appSettings.themeMode);
    await repo.setNotificationsEnabled(appSettings.notificationsEnabled);
    await repo.setPlannedActivityReminderTimeMinutes(
      appSettings.plannedActivityReminderTimeMinutes,
    );
    await repo.setPlannedActivityRemindersEnabled(
      appSettings.plannedActivityRemindersEnabled,
    );
  }

  /// Verifica post-restore (sezione 50-53, 102-103): confronto
  /// **semantico** tramite i mapping generati durante il restore (non un
  /// confronto cieco vecchio PK/nuovo PK, sezione 51), conteggi esatti
  /// per collezione, valori delle impostazioni, e un controllo di
  /// integrità FK reale via `PRAGMA foreign_key_check`. Ritorna la lista
  /// dei problemi trovati (vuota se tutto è coerente).
  Future<List<String>> _verifyRestore(
    ForgeBackupV1 sourceBackup,
    _RestoreIdMappings mapping,
  ) async {
    final issues = <String>[];

    final reExport = await exportService.export();
    if (!reExport.isSuccess) {
      return [
        'Re-export di verifica post-restore fallito: '
            '${reExport.errors.map((e) => e.toString()).join('; ')}',
      ];
    }
    final restored = reExport.backup!.data;
    final source = sourceBackup.data;

    void checkCount(String label, int expected, int actual) {
      if (expected != actual) {
        issues.add(
          '$label: attesi $expected, trovati $actual dopo il restore.',
        );
      }
    }

    checkCount('profiles', source.profiles.length, restored.profiles.length);
    checkCount(
      'userEquipment',
      source.userEquipment.length,
      restored.userEquipment.length,
    );
    checkCount(
      'bodyMeasurements',
      source.bodyMeasurements.length,
      restored.bodyMeasurements.length,
    );
    checkCount(
      'pressureMeasurements',
      source.pressureMeasurements.length,
      restored.pressureMeasurements.length,
    );
    checkCount('workouts', source.workouts.length, restored.workouts.length);
    checkCount(
      'workoutExercises',
      source.workoutExercises.length,
      restored.workoutExercises.length,
    );
    checkCount(
      'workoutSessions',
      source.workoutSessions.length,
      restored.workoutSessions.length,
    );
    checkCount(
      'workoutSessionExercises',
      source.workoutSessionExercises.length,
      restored.workoutSessionExercises.length,
    );
    checkCount(
      'walkingSessions',
      source.walkingSessions.length,
      restored.walkingSessions.length,
    );
    checkCount(
      'plannedActivities',
      source.plannedActivities.length,
      restored.plannedActivities.length,
    );

    // Confronto semantico via mapping (sezione 51): ogni nuovo ID che
    // pensiamo di aver assegnato deve comparire esattamente nel set di
    // localId letto da un re-export indipendente — non un semplice
    // conteggio, ma la prova che i record inseriti sono realmente
    // leggibili con quegli ID.
    void checkIdSet(
      String label,
      Iterable<int> expected,
      Iterable<int> actual,
    ) {
      final expectedSet = expected.toSet();
      final actualSet = actual.toSet();
      if (expectedSet.length != actualSet.length ||
          !expectedSet.containsAll(actualSet)) {
        issues.add(
          '$label: gli ID restaurati non coincidono con i mapping attesi.',
        );
      }
    }

    checkIdSet(
      'profiles',
      mapping.profileIds.values,
      restored.profiles.map((p) => p.localId),
    );
    checkIdSet(
      'workouts',
      mapping.workoutIds.values,
      restored.workouts.map((w) => w.localId),
    );
    checkIdSet(
      'workoutExercises',
      mapping.workoutExerciseIds.values,
      restored.workoutExercises.map((e) => e.localId),
    );
    checkIdSet(
      'workoutSessions',
      mapping.workoutSessionIds.values,
      restored.workoutSessions.map((s) => s.localId),
    );
    checkIdSet(
      'walkingSessions',
      mapping.walkingSessionIds.values,
      restored.walkingSessions.map((w) => w.localId),
    );

    if (restored.appSettings.onboardingCompleted !=
        source.appSettings.onboardingCompleted) {
      issues.add(
        'appSettings.onboardingCompleted non coerente dopo il restore.',
      );
    }
    if (restored.appSettings.themeMode != source.appSettings.themeMode) {
      issues.add('appSettings.themeMode non coerente dopo il restore.');
    }
    if (restored.appSettings.notificationsEnabled !=
        source.appSettings.notificationsEnabled) {
      issues.add(
        'appSettings.notificationsEnabled non coerente dopo il restore.',
      );
    }
    if (restored.appSettings.plannedActivityRemindersEnabled !=
        source.appSettings.plannedActivityRemindersEnabled) {
      issues.add(
        'appSettings.plannedActivityRemindersEnabled non coerente dopo '
        'il restore.',
      );
    }
    if (restored.appSettings.plannedActivityReminderTimeMinutes !=
        source.appSettings.plannedActivityReminderTimeMinutes) {
      issues.add(
        'appSettings.plannedActivityReminderTimeMinutes non coerente dopo '
        'il restore.',
      );
    }

    final fkViolations = await database
        .customSelect('PRAGMA foreign_key_check')
        .get();
    if (fkViolations.isNotEmpty) {
      issues.add(
        'PRAGMA foreign_key_check ha trovato ${fkViolations.length} '
        'violazioni di integrità referenziale dopo il restore.',
      );
    }

    return issues;
  }
}
