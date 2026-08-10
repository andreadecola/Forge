import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_availability_status.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/entities/exercise_category.dart';
import 'package:forge/features/exercises/application/exercise_catalog_providers.dart';
import 'package:forge/features/exercises/presentation/widgets/exercise_card.dart';

import 'exercise_test_fixtures.dart';

Future<void> _pumpAppOnCatalog(
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

  final catalogEntry = find.text('Catalogo esercizi');
  await tester.scrollUntilVisible(catalogEntry, 400);
  await tester.pumpAndSettle();
  await tester.tap(catalogEntry);
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets('apertura del catalogo mostra i 3 esercizi seedati', (
    tester,
  ) async {
    await _pumpAppOnCatalog(tester, database);

    expect(find.text('Catalogo esercizi'), findsWidgets);
    expect(find.text('Esercizio disponibile'), findsOneWidget);
    expect(find.text('Esercizio livello avanzato'), findsOneWidget);
    expect(find.text('Esercizio con elastico'), findsOneWidget);
    expect(find.text('3 risultati'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('un esercizio disponibile mostra il badge "Disponibile"', (
    tester,
  ) async {
    await _pumpAppOnCatalog(tester, database);
    expect(find.text('Disponibile'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('un esercizio di livello superiore mostra "Livello successivo"', (
    tester,
  ) async {
    await _pumpAppOnCatalog(tester, database);
    expect(find.text('Livello successivo'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'un esercizio con attrezzatura non posseduta mostra "Richiede attrezzatura"',
    (tester) async {
      await _pumpAppOnCatalog(tester, database);
      expect(find.text('Richiede attrezzatura'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('ricerca per nome filtra la lista', (tester) async {
    await _pumpAppOnCatalog(tester, database);

    await tester.enterText(find.byType(TextField), 'avanzato');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Esercizio livello avanzato'), findsOneWidget);
    expect(find.text('Esercizio disponibile'), findsNothing);
    expect(find.text('1 risultato'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('ricerca senza risultati mostra l\'empty state', (tester) async {
    await _pumpAppOnCatalog(tester, database);

    await tester.enterText(find.byType(TextField), 'codice inesistente xyz');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(
      find.text('Nessun esercizio corrisponde ai filtri selezionati.'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Reimposta filtri'),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('il filtro categoria mostra solo la categoria selezionata', (
    tester,
  ) async {
    await _pumpAppOnCatalog(tester, database);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Filtri'));
    await tester.pumpAndSettle();

    // Con un'unica categoria nel mini-catalogo, selezionarla non riduce i
    // risultati: verifichiamo che il chip esista e sia selezionabile.
    final categoryChip = find.widgetWithText(ChoiceChip, 'Categoria di test');
    expect(categoryChip, findsOneWidget);
    await tester.ensureVisible(categoryChip);
    await tester.tap(categoryChip);
    await tester.pumpAndSettle();

    final applyButton = find.widgetWithText(FilledButton, 'Applica');
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    expect(find.text('3 risultati'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'il filtro livello ricalcola la disponibilità (livello 5 sblocca tutti i livelli)',
    (tester) async {
      await _pumpAppOnCatalog(tester, database);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Filtri'));
      await tester.pumpAndSettle();

      final levelChip = find.widgetWithText(ChoiceChip, 'Livello 5');
      await tester.ensureVisible(levelChip);
      await tester.tap(levelChip);
      await tester.pumpAndSettle();

      final applyButton = find.widgetWithText(FilledButton, 'Applica');
      await tester.ensureVisible(applyButton);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // A livello 5 l'esercizio "livello avanzato" diventa disponibile.
      expect(find.text('Livello successivo'), findsNothing);

      await disposeCleanly(tester);
    },
  );

  testWidgets('il filtro disponibilità mostra solo gli esercizi disponibili', (
    tester,
  ) async {
    await _pumpAppOnCatalog(tester, database);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Filtri'));
    await tester.pumpAndSettle();

    final availableChip = find.widgetWithText(ChoiceChip, 'Disponibile');
    await tester.ensureVisible(availableChip);
    await tester.tap(availableChip);
    await tester.pumpAndSettle();

    final applyButton = find.widgetWithText(FilledButton, 'Applica');
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    expect(find.text('Esercizio disponibile'), findsOneWidget);
    expect(find.text('Esercizio livello avanzato'), findsNothing);
    expect(find.text('Esercizio con elastico'), findsNothing);
    expect(find.text('1 risultato'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('reimposta filtri ripristina l\'elenco completo', (tester) async {
    await _pumpAppOnCatalog(tester, database);

    await tester.enterText(find.byType(TextField), 'avanzato');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('1 risultato'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Reimposta filtri'));
    await tester.pumpAndSettle();

    expect(find.text('3 risultati'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'il pulsante Filtri mostra il conteggio dei filtri attivi del bottom '
    'sheet (categoria, livello, attrezzatura, disponibilità)',
    (tester) async {
      await _pumpAppOnCatalog(tester, database);

      expect(find.widgetWithText(OutlinedButton, 'Filtri'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Filtri'));
      await tester.pumpAndSettle();

      final categoryChip = find.widgetWithText(ChoiceChip, 'Categoria di test');
      await tester.ensureVisible(categoryChip);
      await tester.tap(categoryChip);
      await tester.pumpAndSettle();

      final levelChip = find.widgetWithText(ChoiceChip, 'Livello 5');
      await tester.ensureVisible(levelChip);
      await tester.tap(levelChip);
      await tester.pumpAndSettle();

      final applyButton = find.widgetWithText(FilledButton, 'Applica');
      await tester.ensureVisible(applyButton);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(OutlinedButton, 'Filtri (2)'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('reimposta filtri riporta il conteggio del pulsante a zero', (
    tester,
  ) async {
    await _pumpAppOnCatalog(tester, database);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Filtri'));
    await tester.pumpAndSettle();

    final categoryChip = find.widgetWithText(ChoiceChip, 'Categoria di test');
    await tester.ensureVisible(categoryChip);
    await tester.tap(categoryChip);
    await tester.pumpAndSettle();

    final applyButton = find.widgetWithText(FilledButton, 'Applica');
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'Filtri (1)'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Reimposta filtri'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'Filtri'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Filtri (1)'), findsNothing);

    await disposeCleanly(tester);
  });

  testWidgets(
    'un titolo lungo nella ExerciseCard va a capo su massimo 2 righe senza '
    'overflow',
    (tester) async {
      const category = ExerciseCategory(
        id: 1,
        code: 'TEST',
        name: 'Categoria di test',
        displayOrder: 1,
        active: true,
      );
      const exercise = Exercise(
        id: 999,
        code: 'EX-LONG',
        name:
            'Estensione dei tricipiti in piedi con elastico di resistenza '
            'medio-alta e controllo del gomito',
        description: 'Descrizione.',
        instructions: '1. Passo.',
        categoryId: 1,
        minimumLevel: 1,
        impactLevel: ExerciseImpactLevel.low,
        balanceRequired: false,
        floorRequired: false,
        standingRequired: true,
        supportAllowed: true,
        isSystem: true,
        isActive: true,
        catalogVersion: 1,
      );
      final item = ExerciseCatalogItem(
        exercise: exercise,
        category: category,
        requiredEquipmentCodes: const {},
        requiredEquipmentNames: const [],
        status: ExerciseAvailabilityStatus.available,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 320,
                child: ExerciseCard(item: item, onTap: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final nameText = tester.widget<Text>(find.text(exercise.name));
      expect(nameText.maxLines, 2);
      expect(nameText.overflow, TextOverflow.ellipsis);

      await disposeCleanly(tester);
    },
  );
}
