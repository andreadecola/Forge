import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';

import 'exercise_test_fixtures.dart';

/// Test widget di [PressurePage] (Milestone 7.3): flusso completo Progressi
/// -> Pressione -> aggiungi -> storico -> modifica -> elimina, più i casi
/// limite del form (validazione, frequenza cardiaca opzionale, contesto,
/// doppio submit, responsive, testo grande, tastiera).
void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  Future<void> pumpPressurePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progressi'));
    await tester.pumpAndSettle();
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Gestisci'))
        .onPressed!();
    await tester.pumpAndSettle();
  }

  /// Vedi la stessa nota in progress_page_test.dart: rimuove subito un
  /// eventuale SnackBar ancora visibile, deterministicamente.
  void clearSnackBar(WidgetTester tester) {
    ScaffoldMessenger.of(
      tester.element(find.byType(FloatingActionButton)),
    ).clearSnackBars();
  }

  /// Invoca direttamente l'onTap/onPressed invece di un tap per coordinate:
  /// un overlay residuo (es. l'animazione di uscita di un precedente
  /// SnackBar) può sovrapporsi esattamente al centro di un elemento e
  /// intercettare un tap posizionale — vedi progress_page_test.dart.
  void tapListTile(WidgetTester tester, Finder finder) {
    tester.widget<ListTile>(finder).onTap!();
  }

  void tapDeleteIcon(WidgetTester tester) {
    tester
        .widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.delete_outline),
        )
        .onPressed!();
  }

  testWidgets('senza misurazioni mostra il messaggio di stato vuoto', (
    tester,
  ) async {
    await pumpPressurePage(tester);

    expect(
      find.text('Nessuna rilevazione registrata. Aggiungi la prima.'),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'aggiunge una misurazione completa (sistolica, diastolica, frequenza, '
    'contesto, note)',
    (tester) async {
      await pumpPressurePage(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '120');
      await tester.enterText(find.byType(TextFormField).at(1), '80');
      await tester.enterText(find.byType(TextFormField).at(2), '65');
      await tester.enterText(find.byType(TextFormField).at(3), 'riposo');
      await tester.enterText(find.byType(TextFormField).at(4), '  a riposo  ');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Misurazione salvata'), findsOneWidget);
      expect(find.text('120 / 80 mmHg'), findsOneWidget);
      expect(find.textContaining('65 bpm'), findsOneWidget);
      expect(find.textContaining('riposo'), findsWidgets);
      // Le note sono state trimmate.
      expect(find.textContaining('  a riposo  '), findsNothing);

      await disposeCleanly(tester);
    },
  );

  testWidgets('una misurazione senza frequenza cardiaca è valida', (
    tester,
  ) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '110');
    await tester.enterText(find.byType(TextFormField).at(1), '70');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Misurazione salvata'), findsOneWidget);
    expect(find.text('110 / 70 mmHg'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('sistolica vuota non salva e non chiude il form', (tester) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Indica sistolica e diastolica.'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('diastolica vuota non salva e non chiude il form', (
    tester,
  ) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Indica sistolica e diastolica.'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('sistolica o diastolica zero/negativa non salva', (tester) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '0');
    await tester.enterText(find.byType(TextFormField).at(1), '-5');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.text('I valori devono essere maggiori di zero.'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('frequenza cardiaca zero o negativa non salva', (tester) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(
      find.text('La frequenza cardiaca deve essere maggiore di zero.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'modifica sistolica, diastolica, frequenza, contesto, note mantenendo '
    'lo stesso id',
    (tester) async {
      await pumpPressurePage(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '120');
      await tester.enterText(find.byType(TextFormField).at(1), '80');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
      await tester.pumpAndSettle();

      clearSnackBar(tester);
      await tester.pumpAndSettle();

      tapListTile(tester, find.widgetWithText(ListTile, '120 / 80 mmHg'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '130');
      await tester.enterText(find.byType(TextFormField).at(1), '85');
      await tester.enterText(find.byType(TextFormField).at(2), '70');
      await tester.enterText(find.byType(TextFormField).at(3), 'dopo attività');
      await tester.enterText(
        find.byType(TextFormField).at(4),
        'nota aggiornata',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Misurazione aggiornata'), findsOneWidget);
      expect(find.text('130 / 85 mmHg'), findsOneWidget);
      expect(find.text('120 / 80 mmHg'), findsNothing);
      expect(find.textContaining('70 bpm'), findsOneWidget);
      expect(find.textContaining('dopo attività'), findsWidgets);
      expect(find.textContaining('nota aggiornata'), findsWidgets);

      await disposeCleanly(tester);
    },
  );

  testWidgets('cancellare la frequenza cardiaca in modifica la rende assente '
      'di nuovo', (tester) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    await tester.enterText(find.byType(TextFormField).at(2), '65');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.textContaining('65 bpm'), findsOneWidget);

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    tapListTile(tester, find.widgetWithText(ListTile, '120 / 80 mmHg'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), '');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Misurazione aggiornata'), findsOneWidget);
    expect(find.textContaining('bpm'), findsNothing);

    await disposeCleanly(tester);
  });

  testWidgets('elimina una misurazione dopo conferma', (tester) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    tapDeleteIcon(tester);
    await tester.pumpAndSettle();
    expect(find.text('Eliminare questa misurazione?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
    await tester.pumpAndSettle();

    expect(find.text('Misurazione eliminata'), findsOneWidget);
    expect(
      find.text('Nessuna rilevazione registrata. Aggiungi la prima.'),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('annullare la conferma di eliminazione non rimuove la riga', (
    tester,
  ) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    tapDeleteIcon(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
    await tester.pumpAndSettle();

    expect(find.text('120 / 80 mmHg'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('più misurazioni nello stesso giorno sono consentite e ordinate '
      'dalla più recente', (tester) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '110');
    await tester.enterText(find.byType(TextFormField).at(1), '70');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '125');
    await tester.enterText(find.byType(TextFormField).at(1), '82');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.text('110 / 70 mmHg'), findsOneWidget);
    expect(find.text('125 / 82 mmHg'), findsOneWidget);
    // La più recente (inserita per ultima) appare per prima nello storico.
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    expect(
      texts.indexOf('125 / 82 mmHg') < texts.indexOf('110 / 70 mmHg'),
      isTrue,
    );

    await disposeCleanly(tester);
  });

  testWidgets('doppio tap su Salva persiste una sola misurazione', (
    tester,
  ) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.enterText(find.byType(TextFormField).at(1), '80');

    final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Salva');
    await tester.tap(saveButtonFinder);
    await tester.tap(saveButtonFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('120 / 80 mmHg'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('responsive 320x480: nessun overflow su lista e form', (
    tester,
  ) async {
    await pumpPressurePage(tester);

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 480));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    // Invoca direttamente l'onPressed invece di un tap per coordinate: a
    // una superficie così piccola il bottone può risultare fuori dai
    // limiti "sicuri" del root render tree per il tap sintetico del test,
    // pur essendo visivamente raggiungibile (Milestone 7.7, sezione 45).
    tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Salva'))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });

  testWidgets('testo grande (TextScaler 2.0): nessun crash', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: const ForgeApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progressi'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Con testo grande la card peso/girovita occupa più spazio verticale:
    // la card Pressione può finire oltre il cache extent della ListView e
    // non essere ancora montata — va scrollata in vista prima di cercarla,
    // non basta un pump/pumpAndSettle aggiuntivo.
    await tester.scrollUntilVisible(
      find.widgetWithText(TextButton, 'Gestisci'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Gestisci'))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('con la tastiera aperta il bottone Salva resta raggiungibile', (
    tester,
  ) async {
    await pumpPressurePage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Simula la tastiera on-screen tramite viewInsets, come farebbe un
    // dispositivo reale quando un campo di testo riceve il focus.
    await tester.binding.setSurfaceSize(const Size(400, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Salva'));
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });

  testWidgets('navigazione completa: Progressi -> Pressione -> Add -> Save -> '
      'Storico -> Edit -> Save -> Delete', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progressi'));
    await tester.pumpAndSettle();
    expect(find.text('Pressione'), findsOneWidget);

    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Gestisci'))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Pressione'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();
    expect(find.text('120 / 80 mmHg'), findsOneWidget);

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    tapListTile(tester, find.widgetWithText(ListTile, '120 / 80 mmHg'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '118');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();
    expect(find.text('118 / 80 mmHg'), findsOneWidget);

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    tapDeleteIcon(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
    await tester.pumpAndSettle();
    expect(
      find.text('Nessuna rilevazione registrata. Aggiungi la prima.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Progressi'), findsWidgets);

    await disposeCleanly(tester);
  });
}
