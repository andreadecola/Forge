import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

import '../data/workout_test_helpers.dart';

/// Hardening (Milestone 5.6, sezione 79): un allenamento generato da Forge
/// e persistito deve poter essere avviato, interrotto e finire nello
/// storico esattamente come una scheda manuale — nessun ramo di codice
/// speciale per l'origine Forge nella sessione/storico (già garantito per
/// costruzione dalla Milestone 4.4/4.5, qui solo verificato end-to-end).
void main() {
  testWidgets(
    'allenamento Forge: genera -> salva -> inizia -> interrompi -> compare '
    'nello storico come qualunque altra scheda',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final raw = File('assets/data/exercises_v1.json').readAsStringSync();
      await ExerciseCatalogSeeder(db).seedFromString(raw);
      final profileId = await insertProfilo(db);
      await EquipmentRepositoryImpl(
        db.userEquipmentDao,
      ).saveInitialEquipment(profileId: profileId, owned: const {});
      await SettingsRepositoryImpl(
        db.appSettingsDao,
      ).setOnboardingCompleted(true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Programma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Genera con Forge'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Genera allenamento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salva allenamento'));
      await tester.pumpAndSettle();

      expect(find.text('Dettaglio scheda'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Inizia allenamento'),
        findsOneWidget,
        reason:
            'identico al dettaglio di una scheda manuale: nessun ramo '
            'speciale per Forge',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Inizia allenamento'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Esercizio 1 di'), findsOneWidget);

      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();
      expect(find.text('Vuoi uscire dall\'allenamento?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Esci'));
      await tester.pumpAndSettle();
      expect(find.text('Dettaglio scheda'), findsOneWidget);

      // Il tooltip "Storico allenamenti" vive nell'AppBar di
      // WorkoutListPage, non nel dettaglio: lo stack e' [Programma, /forge,
      // /workouts/:id] (il dettaglio ha sostituito /forge/preview) — due
      // pop per tornare alla lista.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Storico allenamenti'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Forge Full Body'), findsOneWidget);
      expect(find.textContaining('Interrotto'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await db.close();
    },
  );
}
