import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/core/routing/app_routes.dart';
import 'package:forge/data/backup/backup_export_service.dart';
import 'package:forge/data/backup/backup_file_reader.dart';
import 'package:forge/data/backup/backup_json_codec.dart';
import 'package:forge/data/backup/backup_mapper.dart';
import 'package:forge/data/backup/backup_providers.dart';
import 'package:forge/data/backup/backup_read_result.dart';
import 'package:forge/data/backup/backup_restore_service.dart';
import 'package:forge/data/backup/import_external_backup.dart';
import 'package:forge/data/backup/models/backup_app_settings.dart';
import 'package:forge/data/backup/models/backup_data_v1.dart';
import 'package:forge/data/backup/models/backup_metadata.dart';
import 'package:forge/data/backup/models/backup_profile.dart';
import 'package:forge/data/backup/models/forge_backup_v1.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/data/repositories/catalog_providers.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/repositories/pressure_repository_impl.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('fresh install mostra le due scelte', (tester) async {
    await _pumpOnboarding(tester, database, _CancellingReader());

    expect(find.text('Configura Forge'), findsOneWidget);
    expect(find.text('Ripristina da backup'), findsOneWidget);
  });

  testWidgets(
    'cancel del picker lascia il database vuoto e la scelta visibile',
    (tester) async {
      await _pumpOnboarding(tester, database, _CancellingReader());

      await tester.tap(find.byKey(const ValueKey('onboarding-restore-backup')));
      await tester.pumpAndSettle();

      expect(find.text('Configura Forge'), findsOneWidget);
      expect(find.text('Ripristina da backup'), findsOneWidget);
      expect(await database.userProfileDao.getCurrentProfile(), isNull);
    },
  );

  testWidgets('backup invalido mostra errore senza creare il profilo', (
    tester,
  ) async {
    await _pumpOnboarding(tester, database, _FixedReader('not-json'));

    await tester.tap(find.byKey(const ValueKey('onboarding-restore-backup')));
    await tester.pumpAndSettle();

    expect(find.text('Impossibile ripristinare il backup.'), findsOneWidget);
    expect(await database.userProfileDao.getCurrentProfile(), isNull);
  });

  testWidgets('restore fresh riusa il core e porta direttamente alla Home', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.onboarding,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const Text('HOME'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await _pumpOnboarding(
      tester,
      database,
      _FixedReader(_validBackupJson()),
      child: MaterialApp.router(routerConfig: router),
    );

    await tester.tap(find.byKey(const ValueKey('onboarding-restore-backup')));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(await database.userProfileDao.getCurrentProfile(), isNotNull);
    expect(
      await SettingsRepositoryImpl(
        database.appSettingsDao,
      ).isOnboardingCompleted(),
      isTrue,
    );
  });
}

Future<void> _pumpOnboarding(
  WidgetTester tester,
  AppDatabase database,
  BackupFileReader reader, {
  Widget? child,
}) async {
  final importer = _buildImporter(database, reader);
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      catalogBootstrapProvider.overrideWith(
        (ref) async => const CatalogSeedResult(alreadyImported: true),
      ),
      importExternalBackupProvider.overrideWithValue(importer),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: child ?? const MaterialApp(home: OnboardingPage()),
    ),
  );
  await tester.pump();
}

ImportExternalBackup _buildImporter(
  AppDatabase database,
  BackupFileReader reader,
) {
  final exerciseRepository = DriftExerciseRepository(database);
  final mapper = BackupMapper(
    profileRepository: ProfileRepositoryImpl(database.userProfileDao),
    equipmentRepository: EquipmentRepositoryImpl(database.userEquipmentDao),
    bodyMetricsRepository: BodyMetricsRepositoryImpl(
      database.bodyMeasurementsDao,
    ),
    pressureRepository: PressureRepositoryImpl(
      database.pressureMeasurementsDao,
    ),
    settingsRepository: SettingsRepositoryImpl(database.appSettingsDao),
    workoutRepository: DriftWorkoutRepository(database),
    workoutSessionRepository: DriftWorkoutSessionRepository(database),
    walkingSessionRepository: DriftWalkingSessionRepository(database),
    plannedActivityRepository: DriftPlannedActivityRepository(
      database.attivitaPianificateDao,
    ),
    exerciseRepository: exerciseRepository,
    database: database,
  );
  final exportService = BackupExportService(
    mapper: mapper,
    exerciseRepository: exerciseRepository,
    clock: _FixedClock(DateTime.utc(2026, 8, 30, 12)),
  );
  return ImportExternalBackup(
    fileReader: reader,
    restoreService: BackupRestoreService(
      database: database,
      exerciseRepository: exerciseRepository,
      exportService: exportService,
    ),
  );
}

String _validBackupJson() {
  return BackupJsonCodec.encode(
    ForgeBackupV1(
      metadata: BackupMetadata(
        backupFormatVersion: 1,
        databaseVersion: 11,
        catalogVersion: const {},
        appVersion: '1.0.0',
        exportedAt: DateTime.utc(2026, 8, 30, 12),
      ),
      data: BackupDataV1(
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
        workouts: const [],
        workoutExercises: const [],
        workoutSessions: const [],
        workoutSessionExercises: const [],
        walkingSessions: const [],
        plannedActivities: const [],
      ),
    ),
  );
}

class _CancellingReader implements BackupFileReader {
  @override
  Future<BackupReadResult> pickAndReadBackup() async =>
      BackupReadResult.cancelled();
}

class _FixedReader implements BackupFileReader {
  const _FixedReader(this.content);

  final String content;

  @override
  Future<BackupReadResult> pickAndReadBackup() async =>
      BackupReadResult.success(content);
}

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
