import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/core/constants/activity_level.dart';
import 'package:forge/core/utils/age_calculator.dart';
import 'package:forge/data/backup/backup_file_reader.dart';
import 'package:forge/data/backup/backup_providers.dart';
import 'package:forge/data/backup/backup_read_result.dart';
import 'package:forge/data/backup/backup_restore_service.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/catalog_providers.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/domain/entities/biological_sex.dart';
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/services/body_metrics_service.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/features/weight/application/weight_providers.dart';

import 'exercise_test_fixtures.dart';

class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 11, 22, 12);
}

class _BackupReader implements BackupFileReader {
  String? content;

  @override
  Future<BackupReadResult> pickAndReadBackup() async =>
      BackupReadResult.success(content!);
}

void main() {
  late AppDatabase database;
  late BodyMetricsRepositoryImpl measurements;
  late UserProfile profile;
  late _BackupReader reader;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
    final profiles = ProfileRepositoryImpl(database.userProfileDao);
    profile = (await profiles.getCurrentProfile())!.copyWith(
      initialWeightKg: 150.5,
      biologicalSexForFormula: () => BiologicalSexForFormula.male,
    );
    await profiles.saveProfile(profile);
    measurements = BodyMetricsRepositoryImpl(database.bodyMeasurementsDao);
    reader = _BackupReader();
  });

  tearDown(() => database.close());

  Future<int> add(double? weight, DateTime date, {double? waist}) =>
      measurements.addMeasurement(
        BodyMeasurement(
          profileId: profile.id!,
          measuredAt: date,
          weightKg: weight,
          waistCm: waist,
        ),
      );

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(_FixedClock()),
          backupFileReaderProvider.overrideWithValue(reader),
          // Il test usa il restore SQLite reale; la riconciliazione dei plugin
          // nativi di notifica viene collaudata nei test dedicati alle notifiche.
          backupRestoreServiceProvider.overrideWith(
            (ref) => BackupRestoreService(
              database: database,
              exerciseRepository: ref.watch(exerciseRepositoryProvider),
              exportService: ref.watch(backupExportServiceProvider),
            ),
          ),
        ],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> showHome(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Peso attuale'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  void expectMetric(String label, String expected) {
    final row = find
        .ancestor(of: find.text(label), matching: find.byType(Row))
        .first;
    expect(
      find.descendant(of: row, matching: find.text(expected)),
      findsOneWidget,
    );
  }

  void expectWeight(double? weight) {
    expectMetric(
      'Peso attuale',
      weight == null ? 'Non disponibile' : '${weight.toStringAsFixed(1)} kg',
    );
    if (weight == null) {
      for (final label in [
        'Variazione',
        'BMI',
        'BMR stimato',
        'TDEE stimato',
      ]) {
        expectMetric(label, 'Non disponibile');
      }
      return;
    }
    final delta = weight - profile.initialWeightKg;
    expectMetric(
      'Variazione',
      '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
    );
    expectMetric(
      'BMI',
      BodyMetricsService.calculateBmi(
        weightKg: weight,
        heightCm: profile.heightCm,
      ).toStringAsFixed(1),
    );
    final bmr = BodyMetricsService.calculateBmr(
      weightKg: weight,
      heightCm: profile.heightCm,
      age: calculateAge(profile.birthDate),
      biologicalSexForFormula: profile.biologicalSexForFormula,
    )!;
    expectMetric('BMR stimato', '${bmr.toStringAsFixed(0)} kcal/giorno');
    expectMetric(
      'TDEE stimato',
      '${(bmr * ActivityFactors.factorFor(profile.activityLevel)).toStringAsFixed(0)} kcal/giorno',
    );
  }

  Future<void> saveWeight(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextFormField).first, value);
    final save = find.widgetWithText(ElevatedButton, 'Salva');
    ScaffoldMessenger.of(tester.element(save)).removeCurrentSnackBar();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'BUG-001: Home già aperta si aggiorna dopo inserimento, modifica ed eliminazione da Progressi',
    (tester) async {
      await add(151, DateTime(2026, 11, 20, 8));
      await pumpApp(tester);
      await showHome(tester);
      expectWeight(151);

      await tester.tap(find.text('Progressi'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await saveWeight(tester, '150,4');
      await showHome(tester);
      expectWeight(150.4);

      await tester.tap(find.text('Progressi'));
      await tester.pumpAndSettle();
      final measurementTile = find.widgetWithText(ListTile, '150,4 kg');
      await tester.ensureVisible(measurementTile);
      await tester.tap(measurementTile);
      await tester.pumpAndSettle();
      await saveWeight(tester, '149,9');
      await showHome(tester);
      expectWeight(149.9);

      await tester.tap(find.text('Progressi'));
      await tester.pumpAndSettle();
      final delete = find.descendant(
        of: find.widgetWithText(ListTile, '149,9 kg'),
        matching: find.byType(IconButton),
      );
      await tester.ensureVisible(delete);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
      await tester.pumpAndSettle();
      await showHome(tester);
      expectWeight(151);
      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'Home reagisce al DB: date, parità, solo girovita e rimozione di tutti i pesi',
    (tester) async {
      final first = await add(151, DateTime(2026, 11, 20, 8));
      await pumpApp(tester);
      await showHome(tester);
      expectWeight(151);
      final earlier = await add(149, DateTime(2026, 11, 19));
      await tester.pumpAndSettle();
      expectWeight(151);
      final latest = await add(150.4, DateTime(2026, 11, 21));
      final tied = await add(150.3, DateTime(2026, 11, 21));
      await add(null, DateTime(2026, 11, 22), waist: 100);
      await tester.pumpAndSettle();
      expectWeight(150.3);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      expect(
        container.read(latestWaistProvider(profile.id!)).valueOrNull?.waistCm,
        100,
      );
      await measurements.deleteMeasurement(tied);
      await tester.pumpAndSettle();
      expectWeight(150.4);
      for (final id in [latest, first, earlier]) {
        await measurements.deleteMeasurement(id);
      }
      await tester.pumpAndSettle();
      expectWeight(null);
      await disposeCleanly(tester);
    },
  );

  testWidgets('Home e metriche aggiornate dopo riapertura dell’app', (
    tester,
  ) async {
    await add(150.4, DateTime(2026, 11, 21));
    await pumpApp(tester);
    await showHome(tester);
    expectWeight(150.4);
    await disposeCleanly(tester);
    await pumpApp(tester);
    await showHome(tester);
    expectWeight(150.4);
    await disposeCleanly(tester);
  });

  testWidgets('Importazione backup aggiorna la Home già montata', (
    tester,
  ) async {
    final id = await add(150.4, DateTime(2026, 11, 21));
    await pumpApp(tester);
    await showHome(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final exported = await container.read(backupExportServiceProvider).export();
    expect(exported.isSuccess, isTrue, reason: '${exported.errors}');
    reader.content = exported.json;
    final old = (await measurements.getById(id))!;
    await measurements.updateMeasurement(old.copyWith(weightKg: () => 151));
    await tester.pumpAndSettle();
    expectWeight(151);

    final result = await container.read(importExternalBackupProvider).call();
    expect(result.isSuccess, isTrue, reason: result.errorMessage);
    await tester.pumpAndSettle();
    await showHome(tester);
    expectWeight(150.4);
    await disposeCleanly(tester);
  });
}
