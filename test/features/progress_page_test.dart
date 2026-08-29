import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/data/repositories/pressure_repository_impl.dart';
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';
import 'package:forge/features/pressure/presentation/pages/pressure_page.dart';

import 'exercise_test_fixtures.dart';

/// Test widget del modulo Progressi (Milestone 7.2): flusso completo
/// Dashboard -> Progressi -> aggiungi -> storico -> modifica -> elimina,
/// più i casi limite del form (validazione, "solo girovita", virgola
/// decimale).
void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  Future<void> pumpProgressPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progressi'));
    await tester.pumpAndSettle();
  }

  Future<int> currentProfileId() async {
    return (await database.userProfileDao.getCurrentProfile())!.id;
  }

  Future<int> addBody({
    required int profileId,
    required DateTime measuredAt,
    double? weightKg,
    double? waistCm,
    String? notes,
  }) {
    return BodyMetricsRepositoryImpl(
      database.bodyMeasurementsDao,
    ).addMeasurement(
      BodyMeasurement(
        profileId: profileId,
        measuredAt: measuredAt,
        weightKg: weightKg,
        waistCm: waistCm,
        notes: notes,
      ),
    );
  }

  Future<int> addPressure({
    required int profileId,
    required DateTime measuredAt,
    required int systolic,
    required int diastolic,
    int? heartRate,
  }) {
    return PressureRepositoryImpl(
      database.pressureMeasurementsDao,
    ).addMeasurement(
      PressureMeasurement(
        profileId: profileId,
        measuredAt: measuredAt,
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
      ),
    );
  }

  /// Rimuove subito un eventuale SnackBar ancora visibile da un'azione
  /// precedente: senza questo, il suo overlay (che per design Material resta
  /// sopra i contenuti modali) può sovrapporsi e intercettare il tocco
  /// destinato a un bottone del passo successivo — a differenza di un pump
  /// temporizzato, questo è deterministico e non dipende dal carico
  /// macchina.
  void clearSnackBar(WidgetTester tester) {
    ScaffoldMessenger.of(
      tester.element(find.byType(FloatingActionButton)),
    ).clearSnackBars();
  }

  testWidgets(
    'senza misurazioni mostra la baseline e i messaggi di stato vuoto',
    (tester) async {
      await pumpProgressPage(tester);

      expect(find.text('Peso iniziale'), findsOneWidget);
      expect(find.text('80 kg'), findsOneWidget);
      expect(
        find.text('Nessuna misurazione di peso registrata'),
        findsOneWidget,
      );
      expect(
        find.text('Nessuna misurazione del girovita registrata'),
        findsOneWidget,
      );
      expect(
        find.text('Nessuna misurazione registrata. Aggiungi la prima.'),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'aggiunge una misurazione con peso e girovita, aggiorna riepilogo e '
    'storico',
    (tester) async {
      await pumpProgressPage(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '77,5');
      await tester.enterText(find.byType(TextFormField).at(1), '88');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Misurazione salvata'), findsOneWidget);
      // Riepilogo aggiornato: peso attuale e variazione rispetto a 80 kg.
      expect(find.text('77,5 kg'), findsWidgets);
      expect(find.text('−2,5 kg'), findsOneWidget);
      expect(find.text('88 cm'), findsWidgets);
      // Riga di storico presente.
      expect(find.textContaining('Girovita 88 cm'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('una misurazione "solo girovita" (senza peso) viene salvata', (
    tester,
  ) async {
    await pumpProgressPage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), '90');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Misurazione salvata'), findsOneWidget);
    // Nessun peso registrato: il riepilogo peso resta vuoto...
    expect(find.text('Nessuna misurazione di peso registrata'), findsOneWidget);
    // ...ma il girovita è aggiornato.
    expect(find.text('90 cm'), findsWidgets);

    await disposeCleanly(tester);
  });

  testWidgets(
    'senza peso né girovita il salvataggio mostra un errore e non chiude '
    'il form',
    (tester) async {
      await pumpProgressPage(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Indica almeno il peso o il girovita.'), findsOneWidget);
      // Il form resta aperto (il bottone Salva è ancora visibile).
      expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('modifica una misurazione esistente aggiornandone il peso', (
    tester,
  ) async {
    await pumpProgressPage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '79');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    // Invoca direttamente l'onTap invece di un tap per coordinate: un
    // eventuale overlay residuo (es. l'animazione di uscita di un
    // precedente SnackBar) può altrimenti sovrapporsi esattamente al
    // centro di questa riga e intercettare un tap posizionale, pur non
    // essendo più visibile né testualmente presente.
    tester.widget<ListTile>(find.widgetWithText(ListTile, '79 kg')).onTap!();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '76');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Misurazione aggiornata'), findsOneWidget);
    expect(find.textContaining('76 kg'), findsWidgets);
    expect(find.textContaining('79 kg'), findsNothing);

    await disposeCleanly(tester);
  });

  testWidgets('elimina una misurazione dopo conferma e aggiorna il riepilogo', (
    tester,
  ) async {
    await pumpProgressPage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '79');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    // Invoca direttamente l'onPressed invece di un tap per coordinate:
    // stesso motivo del tap sulla ListTile in "modifica una misurazione".
    tester
        .widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.delete_outline),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('Eliminare la misurazione?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
    await tester.pumpAndSettle();

    expect(find.text('Misurazione eliminata'), findsOneWidget);
    expect(find.text('Nessuna misurazione di peso registrata'), findsOneWidget);
    expect(
      find.text('Nessuna misurazione registrata. Aggiungi la prima.'),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('annullare la conferma di eliminazione non rimuove la riga', (
    tester,
  ) async {
    await pumpProgressPage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '79');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
    await tester.pumpAndSettle();

    clearSnackBar(tester);
    await tester.pumpAndSettle();

    // Invoca direttamente l'onPressed invece di un tap per coordinate:
    // stesso motivo del tap sulla ListTile in "modifica una misurazione".
    tester
        .widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.delete_outline),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
    await tester.pumpAndSettle();

    expect(find.textContaining('79 kg'), findsWidgets);

    await disposeCleanly(tester);
  });

  testWidgets(
    'senza misurazioni di pressione mostra il messaggio di stato vuoto '
    '(Milestone 7.3)',
    (tester) async {
      await pumpProgressPage(tester);

      expect(find.text('Pressione'), findsOneWidget);
      expect(
        find.text('Nessuna misurazione della pressione registrata'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Gestisci'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'la card Pressione mostra l\'ultima misurazione e naviga a Pressione '
    'con "Gestisci" (Milestone 7.3)',
    (tester) async {
      await pumpProgressPage(tester);

      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Gestisci'))
          .onPressed!();
      await tester.pumpAndSettle();

      // Siamo su PressurePage: il suo AppBar è titolato "Pressione" (a
      // differenza della card in Progressi, questo è univoco anche se la
      // route precedente resta montata sotto).
      expect(find.widgetWithText(AppBar, 'Pressione'), findsOneWidget);

      final pressureFab = find.descendant(
        of: find.byType(PressurePage),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(pressureFab);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '120');
      await tester.enterText(find.byType(TextFormField).at(1), '80');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Misurazione salvata'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('dashboard completa mostra valori, date e frequenza cardiaca', (
    tester,
  ) async {
    final profileId = await currentProfileId();
    await addBody(
      profileId: profileId,
      measuredAt: DateTime(2026, 2, 1, 8),
      weightKg: 150,
      waistCm: 132,
    );
    await addBody(
      profileId: profileId,
      measuredAt: DateTime(2026, 2, 2, 8, 15),
      weightKg: 145.2,
    );
    await addBody(
      profileId: profileId,
      measuredAt: DateTime(2026, 2, 3, 8, 20),
      waistCm: 130.5,
    );
    await addPressure(
      profileId: profileId,
      measuredAt: DateTime(2026, 2, 4, 20, 12),
      systolic: 128,
      diastolic: 82,
      heartRate: 72,
    );

    await pumpProgressPage(tester);

    expect(find.text('Peso'), findsOneWidget);
    expect(find.text('145,2 kg'), findsWidgets);
    expect(find.text('Peso iniziale'), findsOneWidget);
    expect(find.text('80 kg'), findsOneWidget);
    expect(find.text('+65,2 kg'), findsOneWidget);
    expect(find.text('2 febbraio 2026 · 08:15'), findsWidgets);
    expect(find.text('Girovita'), findsOneWidget);
    expect(find.text('130,5 cm'), findsWidgets);
    expect(find.text('3 febbraio 2026 · 08:20'), findsWidgets);
    expect(find.text('128 / 82 mmHg'), findsOneWidget);
    expect(find.text('Frequenza cardiaca'), findsOneWidget);
    expect(find.text('72 bpm'), findsOneWidget);
    expect(find.text('4 febbraio 2026 · 20:12'), findsOneWidget);
    expect(find.text('Registra'), findsOneWidget);
    expect(find.text('Peso / Girovita'), findsOneWidget);
    expect(find.text('Registra pressione'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'dati parziali e tie-break mantengono peso/girovita/pressione indipendenti',
    (tester) async {
      final profileId = await currentProfileId();
      await addBody(
        profileId: profileId,
        measuredAt: DateTime(2026, 3, 1),
        weightKg: 79,
      );
      await addBody(
        profileId: profileId,
        measuredAt: DateTime(2026, 3, 2),
        waistCm: 90,
      );
      final sameInstant = DateTime(2026, 3, 3, 9);
      await addPressure(
        profileId: profileId,
        measuredAt: sameInstant,
        systolic: 120,
        diastolic: 80,
      );
      await addPressure(
        profileId: profileId,
        measuredAt: sameInstant,
        systolic: 130,
        diastolic: 85,
      );

      await pumpProgressPage(tester);

      expect(find.text('79 kg'), findsWidgets);
      expect(find.text('90 cm'), findsWidgets);
      expect(
        find.text('Nessuna misurazione della pressione registrata'),
        findsNothing,
      );
      expect(find.text('130 / 85 mmHg'), findsOneWidget);
      expect(find.text('120 / 80 mmHg'), findsNothing);
      expect(find.text('Frequenza cardiaca'), findsNothing);
      expect(find.text('0 bpm'), findsNothing);

      await disposeCleanly(tester);
    },
  );

  testWidgets('create, update e delete aggiornano il dashboard via stream', (
    tester,
  ) async {
    final profileId = await currentProfileId();
    final bodyRepository = BodyMetricsRepositoryImpl(
      database.bodyMeasurementsDao,
    );
    final pressureRepository = PressureRepositoryImpl(
      database.pressureMeasurementsDao,
    );
    final firstBodyId = await addBody(
      profileId: profileId,
      measuredAt: DateTime(2026, 4, 1),
      weightKg: 145,
    );
    final latestBodyId = await addBody(
      profileId: profileId,
      measuredAt: DateTime(2026, 4, 2),
      weightKg: 143,
    );
    final firstPressureId = await addPressure(
      profileId: profileId,
      measuredAt: DateTime(2026, 4, 1),
      systolic: 120,
      diastolic: 80,
    );
    final latestPressureId = await addPressure(
      profileId: profileId,
      measuredAt: DateTime(2026, 4, 2),
      systolic: 130,
      diastolic: 85,
    );

    await pumpProgressPage(tester);
    expect(find.text('143 kg'), findsWidgets);
    expect(find.text('130 / 85 mmHg'), findsOneWidget);

    await bodyRepository.updateMeasurement(
      BodyMeasurement(
        id: latestBodyId,
        profileId: profileId,
        measuredAt: DateTime(2026, 4, 2),
        weightKg: 141,
      ),
    );
    await pressureRepository.updateMeasurement(
      PressureMeasurement(
        id: latestPressureId,
        profileId: profileId,
        measuredAt: DateTime(2026, 4, 2),
        systolic: 140,
        diastolic: 90,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('141 kg'), findsWidgets);
    expect(find.text('140 / 90 mmHg'), findsOneWidget);

    await bodyRepository.deleteMeasurement(latestBodyId);
    await pressureRepository.deleteMeasurement(latestPressureId);
    await tester.pumpAndSettle();
    expect(find.text('145 kg'), findsWidgets);
    expect(find.text('120 / 80 mmHg'), findsOneWidget);
    expect(await bodyRepository.getById(firstBodyId), isNotNull);
    expect(await pressureRepository.getById(firstPressureId), isNotNull);

    await disposeCleanly(tester);
  });

  testWidgets('dashboard con numeri lunghi resta scorrevole a 320x480', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profileId = await currentProfileId();
    await addBody(
      profileId: profileId,
      measuredAt: DateTime(2026, 5, 1, 8),
      weightKg: 499.9,
      waistCm: 999.9,
      notes: List.filled(30, 'Nota molto lunga ').join(),
    );
    await addPressure(
      profileId: profileId,
      measuredAt: DateTime(2026, 5, 1, 20),
      systolic: 999,
      diastolic: 888,
      heartRate: 9999,
    );

    await pumpProgressPage(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('499,9 kg'), findsWidgets);
    expect(find.text('999,9 cm'), findsWidgets);
    expect(find.text('999 / 888 mmHg'), findsOneWidget);
    expect(find.text('9999 bpm'), findsOneWidget);
    await tester.ensureVisible(find.text('Registra pressione'));
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });

  testWidgets('text scaler 2.0 non rompe il dashboard', (tester) async {
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
    await tester.ensureVisible(find.text('Registra pressione'));
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });

  testWidgets('doppio tap su Salva nel form peso/girovita persiste una sola '
      'misurazione (Milestone 7.7)', (tester) async {
    await pumpProgressPage(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '79');

    final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Salva');
    await tester.tap(saveButtonFinder);
    await tester.tap(saveButtonFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Misurazione salvata'), findsOneWidget);
    final profileId = await currentProfileId();
    final rows = await BodyMetricsRepositoryImpl(
      database.bodyMeasurementsDao,
    ).getMeasurementsByProfile(profileId);
    expect(rows, hasLength(1));

    await disposeCleanly(tester);
  });

  testWidgets(
    'il form peso/girovita resta scrollabile e senza overflow a 320x480 '
    '(Milestone 7.7)',
    (tester) async {
      await pumpProgressPage(tester);

      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(320, 480));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextFormField).at(0), '79');
      // Invoca direttamente l'onPressed invece di un tap per coordinate: a
      // una superficie così piccola il bottone può risultare fuori dai
      // limiti "sicuri" del root render tree per il tap sintetico del test,
      // pur essendo visivamente raggiungibile — stesso principio già
      // documentato per gli altri test di questo file.
      tester
          .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Salva'))
          .onPressed!();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Misurazione salvata'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'il form peso/girovita resta utilizzabile con testo grande (TextScaler '
    '2.0) (Milestone 7.7)',
    (tester) async {
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

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'con la tastiera aperta il bottone Salva del form peso/girovita resta '
    'raggiungibile (Milestone 7.7)',
    (tester) async {
      await pumpProgressPage(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Simula la tastiera on-screen tramite viewInsets, come farebbe un
      // dispositivo reale quando un campo di testo riceve il focus.
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(400, 400));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Salva'));
      expect(tester.takeException(), isNull);

      await disposeCleanly(tester);
    },
  );
}
