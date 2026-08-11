import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

import 'exercise_test_fixtures.dart';

/// Test widget del generatore Forge (Milestone 5.5). Il mini-catalogo
/// condiviso (categoria "TEST") non soddisfa mai la copertura obbligatoria
/// reale (`GAMBE_GLUTEI`, `PETTO_SPINTA`/... ecc.): la generazione fallisce
/// sempre in modo deterministico, il che lo rende adatto anche a testare lo
/// stato di "generazione non riuscita" senza bisogno del catalogo reale.
Future<void> _pumpAppOnForgeGenerator(
  WidgetTester tester,
  AppDatabase database,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const ForgeApp(),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Programma'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Genera con Forge'));
  await tester.pumpAndSettle();
}

/// Sostituisce `pumpAndSettle` quando la schermata può contenere un
/// `CircularProgressIndicator` indeterminato (es. Dashboard/Programma con
/// profilo permanentemente `null`, un caso limite che in pratica non può
/// accadere — l'onboarding crea sempre un profilo prima di completarsi):
/// quell'animazione non si ferma mai, quindi `pumpAndSettle` andrebbe in
/// timeout. Un numero fisso di frame è sufficiente a far risolvere gli
/// stream/provider asincroni.
Future<void> _pumpBounded(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

bool _isChipSelected(WidgetTester tester, String label) {
  return tester
      .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label))
      .selected;
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets(
    'valori default: tipo Total body, durata 30 min, livello 1, nessun enum tecnico',
    (tester) async {
      await _pumpAppOnForgeGenerator(tester, database);

      expect(find.text('Genera con Forge'), findsWidgets);
      expect(find.text('Genera allenamento'), findsOneWidget);

      expect(_isChipSelected(tester, 'Total body'), isTrue);
      expect(_isChipSelected(tester, '30 min'), isTrue);
      expect(_isChipSelected(tester, '1'), isTrue);

      // Le 6 tipologie supportate sono tutte in italiano; CUSTOM non è
      // mai offerto (sezione 9), né come nome tecnico né come traduzione.
      expect(find.text('Total body'), findsOneWidget);
      expect(find.text('Parte superiore'), findsOneWidget);
      expect(find.text('Parte inferiore'), findsOneWidget);
      expect(find.text('Mobilità'), findsOneWidget);
      expect(find.text('Cardio'), findsOneWidget);
      expect(find.text('Recupero'), findsOneWidget);
      expect(find.text('Personalizzato'), findsNothing);
      expect(find.text('FULL_BODY'), findsNothing);
      expect(find.text('CUSTOM'), findsNothing);

      await disposeCleanly(tester);
    },
  );

  testWidgets('selezionare tipo/durata/livello aggiorna la selezione', (
    tester,
  ) async {
    await _pumpAppOnForgeGenerator(tester, database);

    await tester.tap(find.text('Cardio'));
    await tester.tap(find.text('60 min'));
    await tester.tap(find.text('3'));
    await tester.pump();

    expect(_isChipSelected(tester, 'Cardio'), isTrue);
    expect(_isChipSelected(tester, 'Total body'), isFalse);
    expect(_isChipSelected(tester, '60 min'), isTrue);
    expect(_isChipSelected(tester, '30 min'), isFalse);
    expect(_isChipSelected(tester, '3'), isTrue);
    expect(_isChipSelected(tester, '1'), isFalse);

    await disposeCleanly(tester);
  });

  testWidgets(
    'generazione non riuscita: nessun crash, nessuna navigazione, messaggio comprensibile',
    (tester) async {
      await _pumpAppOnForgeGenerator(tester, database);

      await tester.tap(find.text('Genera allenamento'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Anteprima allenamento'), findsNothing);
      expect(
        find.text(
          'Non è stato possibile creare un allenamento con questa '
          'configurazione.',
        ),
        findsOneWidget,
      );
      expect(find.text('Modifica configurazione'), findsOneWidget);
      // Nessun codice tecnico dell'errore in UI.
      expect(find.textContaining('MISSING_REQUIRED_COVERAGE'), findsNothing);
      expect(find.textContaining('INSUFFICIENT_ELIGIBLE'), findsNothing);

      await tester.tap(find.text('Modifica configurazione'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Non è stato possibile creare un allenamento con questa '
          'configurazione.',
        ),
        findsNothing,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets('doppio tap su Genera non produce due esiti sovrapposti', (
    tester,
  ) async {
    await _pumpAppOnForgeGenerator(tester, database);

    await tester.tap(find.text('Genera allenamento'));
    await tester.tap(find.text('Genera allenamento'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text(
        'Non è stato possibile creare un allenamento con questa '
        'configurazione.',
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'profilo mancante: stato esplicito, nessun crash, CTA verso Profilo',
    (tester) async {
      final freshDb = memoryDatabase();
      final raw = miniCatalogJson;
      await ExerciseCatalogSeeder(freshDb).seedFromString(raw);
      await SettingsRepositoryImpl(
        freshDb.appSettingsDao,
      ).setOnboardingCompleted(true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(freshDb)],
          child: const ForgeApp(),
        ),
      );
      await _pumpBounded(tester);
      await tester.tap(find.text('Programma'));
      await _pumpBounded(tester);
      await tester.tap(find.text('Genera con Forge'));
      await _pumpBounded(tester);

      expect(
        find.text('Completa prima il profilo per usare Forge.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Vai al profilo'));
      await _pumpBounded(tester);
      expect(find.text('Profilo'), findsWidgets);

      await disposeCleanly(tester);
      await freshDb.close();
    },
  );

  testWidgets('schermo piccolo: nessun overflow nel generatore', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpAppOnForgeGenerator(tester, database);

    await tester.tap(find.text('Genera allenamento'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });
}
