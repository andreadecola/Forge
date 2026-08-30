import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';

import '../data/workout_test_helpers.dart';
import 'exercise_test_fixtures.dart' show disposeCleanly;

const _miniCatalogJson = '''
{
  "catalogType": "ESERCIZI",
  "catalogVersion": 1,
  "categories": [
    {"code": "TEST", "name": "Categoria di test", "description": null, "displayOrder": 1, "active": true}
  ],
  "muscleGroups": [
    {"code": "CORE", "name": "Core", "active": true}
  ],
  "equipment": [
    {"code": "NONE", "name": "Nessuna", "priority": 0, "active": true}
  ],
  "exercises": [
    {
      "code": "EX-TEST",
      "name": "Esercizio di test",
      "categoryCode": "TEST",
      "description": "desc",
      "instructions": "1. Passo.",
      "minimumLevel": 1,
      "impactLevel": "LOW",
      "defaultSets": 2,
      "defaultReps": 10,
      "defaultRestSeconds": 30,
      "equipmentCodes": [{"code": "NONE", "required": true}],
      "primaryMuscleCodes": ["CORE"],
      "secondaryMuscleCodes": [],
      "alternativeCodes": [],
      "images": []
    }
  ]
}
''';

/// Test widget del flusso "Genera con Forge" nel Piano Settimanale
/// (Milestone 8.4): catalogo reale seedato (stesso helper di
/// `forge_real_catalog_flow_test.dart`), nessuna chiamata diretta ai use
/// case — solo interazione UI reale.
class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

void main() {
  final fixedNow = DateTime(2026, 8, 26, 12); // mercoledì, settimana 24-30/8

  late AppDatabase database;
  late int profileId;

  Future<void> seedRealCatalog(AppDatabase db) async {
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await seedRealCatalog(database);
    profileId = await insertProfilo(database);
    await EquipmentRepositoryImpl(
      database.userEquipmentDao,
    ).saveInitialEquipment(profileId: profileId, owned: const {});
    await SettingsRepositoryImpl(
      database.appSettingsDao,
    ).setOnboardingCompleted(true);
  });

  tearDown(() => database.close());

  Future<void> pumpWeeklyPlan(WidgetTester tester, {DateTime? now}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(_FixedClock(now ?? fixedNow)),
        ],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Piano settimanale'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    tester
        .widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Piano settimanale'),
        )
        .onPressed!();
    await tester.pumpAndSettle();
  }

  void openSheet(WidgetTester tester) {
    tester
        .widget<InkWell>(find.widgetWithText(InkWell, 'Genera con Forge'))
        .onTap!();
  }

  void tapGeneratePreview(WidgetTester tester) {
    tester
        .widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Genera anteprima'),
        )
        .onPressed!();
  }

  void tapConfirm(WidgetTester tester) {
    tester
        .widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Conferma piano'),
        )
        .onPressed!();
  }

  testWidgets('entry point nascosto per una settimana interamente passata', (
    tester,
  ) async {
    await pumpWeeklyPlan(tester, now: DateTime(2026, 9, 15));
    await tester.tap(find.byTooltip('Settimana precedente'));
    await tester.pumpAndSettle();

    expect(find.text('Genera con Forge'), findsNothing);

    await disposeCleanly(tester);
  });

  testWidgets(
    'settimana già con attività Forge: entry point mostra il messaggio di '
    'blocco, non apre il flusso',
    (tester) async {
      final repository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      await AddPlannedActivity(repository)(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.recovery,
          origin: PlannedActivityOrigin.forgeEngine,
        ),
      );

      await pumpWeeklyPlan(tester);

      expect(
        find.textContaining('contiene già attività generate da Forge'),
        findsOneWidget,
      );
      expect(find.widgetWithText(InkWell, 'Genera con Forge'), findsNothing);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'genera 2 allenamenti, conferma -> 2 PlannedActivity FORGE_ENGINE con '
    'Workout reali, nessuna sessione creata',
    (tester) async {
      await pumpWeeklyPlan(tester);
      openSheet(tester);
      await tester.pumpAndSettle();

      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '2').last)
          .onSelected!(true);
      await tester.pumpAndSettle();
      tapGeneratePreview(tester);
      await tester.pumpAndSettle();

      expect(find.text('2 allenamenti proposti'), findsOneWidget);

      tapConfirm(tester);
      await tester.pumpAndSettle();

      expect(find.text('Piano generato'), findsOneWidget);

      final plannedActivityRepository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      final activities = await plannedActivityRepository.getForWeek(
        profileId: profileId,
        weekStart: DateTime(2026, 8, 24),
        weekEnd: DateTime(2026, 8, 30),
      );
      expect(activities, hasLength(2));
      final workoutRepository = DriftWorkoutRepository(database);
      for (final activity in activities) {
        expect(activity.origin, PlannedActivityOrigin.forgeEngine);
        expect(activity.type, PlannedActivityType.workout);
        final workout = await workoutRepository.getWorkoutById(
          activity.workoutId!,
        );
        expect(workout, isNotNull);
      }

      final sessions = await database.sessioniAllenamentoDao
          .getHistoryByProfile(profileId);
      expect(sessions, isEmpty);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'annulla la preview: nessuna PlannedActivity né Workout persistiti',
    (tester) async {
      await pumpWeeklyPlan(tester);
      openSheet(tester);
      await tester.pumpAndSettle();
      tapGeneratePreview(tester);
      await tester.pumpAndSettle();

      expect(find.text('3 allenamenti proposti'), findsOneWidget);

      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Annulla'),
          )
          .onPressed!();
      await tester.pumpAndSettle();

      final workoutRepository = DriftWorkoutRepository(database);
      final workouts = await workoutRepository.getWorkouts(
        profileId: profileId,
      );
      expect(workouts, isEmpty);

      final plannedActivityRepository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      final activities = await plannedActivityRepository.getForWeek(
        profileId: profileId,
        weekStart: DateTime(2026, 8, 24),
        weekEnd: DateTime(2026, 8, 30),
      );
      expect(activities, isEmpty);

      await disposeCleanly(tester);
    },
  );

  testWidgets('doppio tap su "Conferma piano" non crea attività duplicate', (
    tester,
  ) async {
    await pumpWeeklyPlan(tester);
    openSheet(tester);
    await tester.pumpAndSettle();
    tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '1').last)
        .onSelected!(true);
    await tester.pumpAndSettle();
    tapGeneratePreview(tester);
    await tester.pumpAndSettle();

    final confirmButtonFinder = find.widgetWithText(
      ElevatedButton,
      'Conferma piano',
    );
    tester.widget<ElevatedButton>(confirmButtonFinder).onPressed!();
    tester.widget<ElevatedButton>(confirmButtonFinder).onPressed!();
    await tester.pumpAndSettle();

    final plannedActivityRepository = DriftPlannedActivityRepository(
      database.attivitaPianificateDao,
    );
    final activities = await plannedActivityRepository.getForWeek(
      profileId: profileId,
      weekStart: DateTime(2026, 8, 24),
      weekEnd: DateTime(2026, 8, 30),
    );
    expect(activities, hasLength(1));

    await disposeCleanly(tester);
  });

  testWidgets('attività USER esistente resta invariata dopo la generazione', (
    tester,
  ) async {
    final repository = DriftPlannedActivityRepository(
      database.attivitaPianificateDao,
    );
    await AddPlannedActivity(repository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.user,
      ),
    );

    await pumpWeeklyPlan(tester);
    openSheet(tester);
    await tester.pumpAndSettle();
    tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '1').last)
        .onSelected!(true);
    await tester.pumpAndSettle();
    tapGeneratePreview(tester);
    await tester.pumpAndSettle();
    tapConfirm(tester);
    await tester.pumpAndSettle();

    final activities = await repository.getForWeek(
      profileId: profileId,
      weekStart: DateTime(2026, 8, 24),
      weekEnd: DateTime(2026, 8, 30),
    );
    expect(activities, hasLength(2));
    expect(
      activities.where((a) => a.origin == PlannedActivityOrigin.user),
      hasLength(1),
    );
    expect(
      activities.where((a) => a.origin == PlannedActivityOrigin.forgeEngine),
      hasLength(1),
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'nessun esercizio eleggibile (catalogo minimo): mostra errore reale, '
    'permette di modificare la configurazione',
    (tester) async {
      final miniDb = AppDatabase(NativeDatabase.memory());
      addTearDown(miniDb.close);
      await ExerciseCatalogSeeder(miniDb).seedFromString(_miniCatalogJson);
      final miniProfileId = await insertProfilo(miniDb);
      await EquipmentRepositoryImpl(
        miniDb.userEquipmentDao,
      ).saveInitialEquipment(profileId: miniProfileId, owned: const {});
      await SettingsRepositoryImpl(
        miniDb.appSettingsDao,
      ).setOnboardingCompleted(true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(miniDb),
            clockProvider.overrideWithValue(_FixedClock(fixedNow)),
          ],
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Piano settimanale'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Piano settimanale'),
          )
          .onPressed!();
      await tester.pumpAndSettle();
      openSheet(tester);
      await tester.pumpAndSettle();
      tapGeneratePreview(tester);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(OutlinedButton, 'Modifica configurazione'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Conferma piano'),
        findsNothing,
      );

      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Modifica configurazione'),
          )
          .onPressed!();
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(ElevatedButton, 'Genera anteprima'),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets('responsive 320x480: nessun overflow nel flusso di generazione', (
    tester,
  ) async {
    await pumpWeeklyPlan(tester);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 480));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    openSheet(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tapGeneratePreview(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });

  testWidgets('testo grande (TextScaler 2.0): nessun crash', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            clockProvider.overrideWithValue(_FixedClock(fixedNow)),
          ],
          child: const ForgeApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Piano settimanale'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    tester
        .widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Piano settimanale'),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    openSheet(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });
}
