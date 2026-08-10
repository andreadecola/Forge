import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';

import 'exercise_test_fixtures.dart';

/// Pompa l'app, apre il catalogo e apre il dettaglio dell'esercizio con
/// [exerciseName] (deve esserci un solo risultato con quel nome in lista).
Future<void> _openDetail(
  WidgetTester tester,
  AppDatabase database,
  String exerciseName,
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

  final card = find.text(exerciseName);
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

/// Scrolla la ListView del dettaglio fino a rendere visibile [finder],
/// aspettando che l'eventuale animazione di scroll residua si assesti
/// (senza questo `pumpAndSettle`, uno `scrollUntilVisible` incatenato
/// subito dopo un altro può cadere in una finestra transitoria in cui il
/// widget target non è ancora costruito, e fallire con "Bad state: No
/// element" pur essendo presente nella pagina).
Future<void> _scrollDetailUntilVisible(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets(
    'il dettaglio di un esercizio disponibile mostra nome, categoria, '
    'muscoli, attrezzatura, istruzioni, respirazione, parametri, errori e '
    'sicurezza',
    (tester) async {
      await _openDetail(tester, database, 'Esercizio disponibile');

      // Nome (header) e categoria/livello: in cima alla pagina, già
      // visibili senza scroll. Il codice tecnico non deve mai apparire.
      expect(find.text('Esercizio disponibile'), findsWidgets);
      expect(find.textContaining('Categoria di test'), findsOneWidget);
      expect(find.text('EX-AVAILABLE'), findsNothing);
      expect(find.text('Disponibile'), findsOneWidget);

      // Il resto del contenuto è sotto la gallery: una ListView (non
      // builder) costruisce comunque gli elementi in modo lazy in base
      // all'area visibile, quindi va scrollato in vista prima di poterlo
      // trovare con i finder. L'ordine di scroll segue il nuovo ordine
      // delle sezioni: descrizione, istruzioni, parametri, attrezzatura,
      // muscoli, respirazione, errori, sicurezza.
      await _scrollDetailUntilVisible(tester, find.text('Primo passaggio.'));
      expect(find.text('Primo passaggio.'), findsOneWidget);
      expect(find.text('Secondo passaggio.'), findsOneWidget);

      // Parametri: solo i valori presenti (niente ripetizioni "null").
      await _scrollDetailUntilVisible(tester, find.text('Serie'));
      // Il valore "2" di Serie è sempre presente; il cerchio del secondo
      // passaggio delle istruzioni (più in alto) può risultare smontato
      // dalla ListView lazy a seconda dello scroll, quindi non si
      // richiede un conteggio esatto.
      expect(find.text('2'), findsAtLeastNWidgets(1));
      expect(find.text('Ripetizioni'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Recupero'), findsOneWidget);
      expect(find.text('45 sec'), findsOneWidget);
      expect(find.text('Durata'), findsNothing);

      await _scrollDetailUntilVisible(
        tester,
        find.text('Nessuna attrezzatura'),
      );
      expect(find.text('Nessuna attrezzatura'), findsOneWidget);

      await _scrollDetailUntilVisible(tester, find.text('Core'));
      expect(find.text('Core'), findsOneWidget);
      expect(find.text('Addominali'), findsOneWidget);
      expect(find.text('Principali'), findsOneWidget);
      expect(find.text('Secondari'), findsOneWidget);

      await _scrollDetailUntilVisible(tester, find.text('Respirazione'));
      expect(find.text('Respira normalmente.'), findsOneWidget);

      await _scrollDetailUntilVisible(tester, find.text('Errori da evitare'));
      expect(
        find.text('Muoversi troppo velocemente; perdere l\'allineamento.'),
        findsOneWidget,
      );

      await _scrollDetailUntilVisible(
        tester,
        find.text('Attenzione durante l\'esecuzione'),
      );
      expect(find.text('Mantieni il controllo del movimento.'), findsOneWidget);

      expect(tester.takeException(), isNull);
      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'il codice tecnico dell\'esercizio non viene mostrato nel dettaglio',
    (tester) async {
      await _openDetail(tester, database, 'Esercizio con elastico');

      // EX-LOCKED-EQUIPMENT è il code interno di questo esercizio: deve
      // restare nel modello/DB ma non deve mai raggiungere la UI.
      expect(find.text('EX-LOCKED-EQUIPMENT'), findsNothing);

      await disposeCleanly(tester);
    },
  );

  testWidgets('le sezioni del dettaglio appaiono nell\'ordine previsto', (
    tester,
  ) async {
    await _openDetail(tester, database, 'Esercizio disponibile');

    // Confrontare le coordinate a schermo tra scroll diversi non è
    // affidabile (la stessa Y assoluta può ricomparire in viewport
    // diversi): si usa invece la posizione di scroll assoluta a cui
    // ogni titolo diventa visibile, che è monotona per costruzione.
    final titlesInOrder = [
      'Descrizione',
      'Come eseguirlo',
      'Parametri',
      'Attrezzatura',
      'Muscoli',
      'Respirazione',
      'Errori da evitare',
      'Attenzione durante l\'esecuzione',
    ];
    final scrollable = find.byType(Scrollable).first;

    double previousOffset = -1;
    for (final title in titlesInOrder) {
      await _scrollDetailUntilVisible(tester, find.text(title));
      final offset = tester.state<ScrollableState>(scrollable).position.pixels;
      expect(
        offset,
        greaterThanOrEqualTo(previousOffset),
        reason: '"$title" dovrebbe apparire dopo la sezione precedente',
      );
      previousOffset = offset;
    }

    await disposeCleanly(tester);
  });

  testWidgets('un esercizio bloccato per livello mostra il motivo', (
    tester,
  ) async {
    await _openDetail(tester, database, 'Esercizio livello avanzato');

    expect(find.text('Livello successivo'), findsOneWidget);
    await _scrollDetailUntilVisible(
      tester,
      find.text('Questo esercizio richiede il livello 5.'),
    );
    expect(
      find.text('Questo esercizio richiede il livello 5.'),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('un esercizio bloccato per attrezzatura mostra il motivo', (
    tester,
  ) async {
    await _openDetail(tester, database, 'Esercizio con elastico');

    expect(find.text('Richiede attrezzatura'), findsOneWidget);
    await _scrollDetailUntilVisible(
      tester,
      find.text('Per questo esercizio ti serve: Elastici.'),
    );
    expect(
      find.text('Per questo esercizio ti serve: Elastici.'),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('la progressione è mostrata ed è cliccabile', (tester) async {
    await _openDetail(tester, database, 'Esercizio con elastico');

    await _scrollDetailUntilVisible(tester, find.text('Progressione'));
    expect(find.text('Progressione'), findsOneWidget);
    expect(find.text('Esercizio disponibile'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('la regressione (variante precedente) è mostrata', (
    tester,
  ) async {
    await _openDetail(tester, database, 'Esercizio disponibile');

    await _scrollDetailUntilVisible(tester, find.text('Variante precedente'));
    expect(find.text('Variante precedente'), findsOneWidget);
    expect(find.text('Esercizio con elastico'), findsWidgets);

    await disposeCleanly(tester);
  });

  testWidgets(
    'le alternative sono mostrate con il motivo tradotto in italiano',
    (tester) async {
      await _openDetail(tester, database, 'Esercizio disponibile');

      await _scrollDetailUntilVisible(tester, find.text('Alternative'));
      expect(find.text('Alternative'), findsOneWidget);
      expect(find.text('Attrezzatura'), findsOneWidget); // motivo tradotto
      expect(find.text('ATTREZZATURA'), findsNothing); // mai l'enum tecnico

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'immagini mancanti non generano errori: viene mostrato il placeholder',
    (tester) async {
      // EX-LOCKED-EQUIPMENT ha 2 riferimenti immagine il cui asset reale
      // non esiste ancora sul disco.
      await _openDetail(tester, database, 'Esercizio con elastico');

      expect(tester.takeException(), isNull);
      expect(
        find.text('Immagine dimostrativa in preparazione'),
        findsOneWidget,
      );
      await _scrollDetailUntilVisible(tester, find.text('1 / 2'));
      expect(find.text('1 / 2'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('un esercizio senza immagini mostra il placeholder unico', (
    tester,
  ) async {
    // EX-AVAILABLE non ha alcun riferimento immagine.
    await _openDetail(tester, database, 'Esercizio disponibile');

    expect(tester.takeException(), isNull);
    expect(find.text('Immagine dimostrativa in preparazione'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'catalogo -> dettaglio -> progressione -> altro dettaglio -> back funziona',
    (tester) async {
      await _openDetail(tester, database, 'Esercizio con elastico');
      expect(find.text('Esercizio con elastico'), findsWidgets);

      final progressionTile = find.text('Esercizio disponibile');
      await _scrollDetailUntilVisible(tester, progressionTile);
      await tester.tap(progressionTile);
      await tester.pumpAndSettle();

      // Ora siamo sul dettaglio di "Esercizio disponibile".
      expect(find.text('Disponibile'), findsOneWidget);
      await _scrollDetailUntilVisible(tester, find.text('Variante precedente'));
      expect(find.text('Variante precedente'), findsOneWidget);

      // Back -> torna al dettaglio di "Esercizio con elastico". La sua
      // ListView è rimasta scrollata in basso (dove avevamo trovato il
      // link alla progressione): risaliamo prima di verificare il badge.
      // L'app è localizzata in italiano: il tooltip del back button
      // dell'AppBar è "Indietro", non l'inglese "Back" che
      // WidgetTester.pageBack() cerca di default.
      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Richiede attrezzatura'),
        -400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Richiede attrezzatura'), findsOneWidget);

      // Back -> torna al catalogo.
      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();
      expect(find.text('3 risultati'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );
}
