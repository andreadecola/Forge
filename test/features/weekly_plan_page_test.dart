import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';

import 'exercise_test_fixtures.dart';

/// Test widget del Piano Settimanale (Milestone 8.2): vista settimana,
/// navigazione, aggiunta/modifica/eliminazione di attività pianificate,
/// cambio tipo con normalizzazione dei campi, allenamento eliminato dopo la
/// pianificazione, isolamento profilo, responsive e testo grande.
///
/// `fixedNow` è un mercoledì (2026-08-26): la settimana Lunedì -> Domenica
/// contenente questa data è 24 - 30 agosto 2026, stessa settimana già usata
/// da `weekly_planning_date_service_test.dart` (Milestone 8.1).
void main() {
  final fixedNow = DateTime(2026, 8, 26, 12);

  late AppDatabase database;
  late int profileId;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
    profileId = (await ProfileRepositoryImpl(
      database.userProfileDao,
    ).getCurrentProfile())!.id!;
  });

  tearDown(() => database.close());

  Future<int> createWorkout(String name) {
    return DriftWorkoutRepository(database).createWorkout(
      Workout(
        profileId: profileId,
        name: name,
        type: WorkoutType.lowerBody,
        level: 1,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
      ),
    );
  }

  Future<int> createWorkoutWithExercise(String name) async {
    final repo = DriftWorkoutRepository(database);
    final workoutId = await repo.createWorkout(
      Workout(
        profileId: profileId,
        name: name,
        type: WorkoutType.lowerBody,
        level: 1,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
      ),
    );
    final exerciseId = (await database.eserciziDao.getByCode(
      'EX-AVAILABLE',
    ))!.id;
    await repo.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 1,
        sets: 1,
        repetitions: 10,
      ),
    );
    return workoutId;
  }

  Future<void> pumpWeeklyPlanPage(WidgetTester tester, {DateTime? now}) async {
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

  /// Card del giorno identificata dalla sua abbreviazione (univoca nella
  /// settimana, es. "MER"), non da un indice di scroll — evita di dipendere
  /// da quali card sono già montate dalla `ListView.builder`.
  Finder dayCardFinder(String weekdayShort) =>
      find.ancestor(of: find.text(weekdayShort), matching: find.byType(Card));

  Future<void> tapAddForDay(WidgetTester tester, String weekdayShort) async {
    await tester.scrollUntilVisible(
      find.text(weekdayShort),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    tester
        .widget<IconButton>(
          find.descendant(
            of: dayCardFinder(weekdayShort),
            matching: find.widgetWithIcon(IconButton, Icons.add),
          ),
        )
        .onPressed!();
    await tester.pumpAndSettle();
  }

  Future<void> tapActivityTile(
    WidgetTester tester,
    String weekdayShort,
    String activityTitle,
  ) async {
    final tile = find.descendant(
      of: dayCardFinder(weekdayShort),
      matching: find.widgetWithText(ListTile, activityTitle),
    );
    tester.widget<ListTile>(tile).onTap!();
    await tester.pumpAndSettle();
  }

  /// Le azioni per attività (Sposta/Salta/Rinvia/Ripristina/Elimina,
  /// Milestone 8.6) vivono in un `PopupMenuButton`: apre il menu tramite il
  /// suo tooltip, poi seleziona la voce per testo — a differenza degli
  /// altri controlli di questo file, un `PopupMenuButton` non espone un
  /// callback diretto invocabile senza un vero `tester.tap` (il menu è
  /// renderizzato in overlay tramite `showMenu`).
  Future<void> tapActivityMenuAction(
    WidgetTester tester,
    String weekdayShort,
    String actionLabel,
  ) async {
    await tester.scrollUntilVisible(
      find.text(weekdayShort),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: dayCardFinder(weekdayShort),
        matching: find.byTooltip('Altre azioni'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(actionLabel).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapDeleteForDay(WidgetTester tester, String weekdayShort) =>
      tapActivityMenuAction(tester, weekdayShort, 'Elimina');

  void selectType(WidgetTester tester, String label) {
    tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label))
        .onSelected!(true);
  }

  void tapSave(WidgetTester tester) {
    tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Salva'))
        .onPressed!();
  }

  void clearSnackBar(WidgetTester tester) {
    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).clearSnackBars();
  }

  testWidgets('settimana vuota: ogni giorno mostra lo stato vuoto', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester);

    expect(find.text('24 – 30 agosto 2026'), findsOneWidget);
    expect(find.text('Nessuna attività pianificata'), findsNWidgets(7));
    for (final day in ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM']) {
      expect(find.text(day), findsOneWidget);
    }

    await disposeCleanly(tester);
  });

  testWidgets('il giorno corrente è evidenziato con il badge "Oggi"', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester);

    expect(find.text('Oggi'), findsOneWidget);
    expect(
      find.descendant(of: dayCardFinder('MER'), matching: find.text('Oggi')),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'aggiunge un\'attività WORKOUT scegliendo una scheda esistente, nessuna '
    'WorkoutSession creata',
    (tester) async {
      final workoutId = await createWorkout('Scheda gambe');
      await pumpWeeklyPlanPage(tester);

      await tapAddForDay(tester, 'MER');
      expect(find.text('Nuova attività'), findsOneWidget);

      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Scegli un allenamento'),
          )
          .onPressed!();
      await tester.pumpAndSettle();
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Scheda gambe'))
          .onTap!();
      await tester.pumpAndSettle();

      tapSave(tester);
      await tester.pumpAndSettle();

      expect(find.text('Attività pianificata'), findsOneWidget);
      expect(
        find.descendant(
          of: dayCardFinder('MER'),
          matching: find.text('Scheda gambe'),
        ),
        findsOneWidget,
      );

      final sessions = await database.sessioniAllenamentoDao
          .getHistoryByProfile(profileId);
      expect(sessions, isEmpty);
      final workout = await DriftWorkoutRepository(
        database,
      ).getWorkoutById(workoutId);
      expect(workout, isNotNull);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'aggiunge una CAMMINATA con durata pianificata, nessuna WalkingSession '
    'creata',
    (tester) async {
      await pumpWeeklyPlanPage(tester);

      await tapAddForDay(tester, 'VEN');
      selectType(tester, 'Camminata');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '45');
      tapSave(tester);
      await tester.pumpAndSettle();

      expect(find.text('Attività pianificata'), findsOneWidget);
      expect(
        find.descendant(
          of: dayCardFinder('VEN'),
          matching: find.text('45 min'),
        ),
        findsOneWidget,
      );

      final walks = await database.camminateDao.getByProfile(profileId);
      expect(walks, isEmpty);

      await disposeCleanly(tester);
    },
  );

  testWidgets('aggiunge un RECUPERO senza campi aggiuntivi', (tester) async {
    await pumpWeeklyPlanPage(tester);

    await tapAddForDay(tester, 'SAB');
    selectType(tester, 'Recupero');
    await tester.pumpAndSettle();
    expect(
      find.text('Giorno di recupero: nessuna scheda o sessione collegata.'),
      findsOneWidget,
    );
    tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('Attività pianificata'), findsOneWidget);
    expect(
      find.descendant(
        of: dayCardFinder('SAB'),
        matching: find.text('Giorno di recupero'),
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('più attività nello stesso giorno sono mostrate tutte', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester);

    await tapAddForDay(tester, 'LUN');
    selectType(tester, 'Recupero');
    tapSave(tester);
    await tester.pumpAndSettle();
    clearSnackBar(tester);

    await tapAddForDay(tester, 'LUN');
    selectType(tester, 'Camminata');
    await tester.pumpAndSettle();
    tapSave(tester);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: dayCardFinder('LUN'),
        matching: find.text('Giorno di recupero'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dayCardFinder('LUN'),
        matching: find.text('Camminata pianificata'),
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('modifica: seleziona un altro allenamento mantenendo lo stesso '
      'id', (tester) async {
    await createWorkout('Scheda A');
    await createWorkout('Scheda B');
    await pumpWeeklyPlanPage(tester);

    await tapAddForDay(tester, 'GIO');
    tester
        .widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Scegli un allenamento'),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    tester.widget<ListTile>(find.widgetWithText(ListTile, 'Scheda A')).onTap!();
    await tester.pumpAndSettle();
    tapSave(tester);
    await tester.pumpAndSettle();
    clearSnackBar(tester);

    await tapActivityTile(tester, 'GIO', 'Allenamento');
    expect(find.text('Modifica attività'), findsOneWidget);
    // `.last`: lo stesso testo "Scheda A" compare anche nel sottotitolo
    // della riga attività della settimana sottostante (ancora montata sotto
    // il bottom sheet) — l'ultimo match è quello del form aperto sopra.
    tester
        .widget<ListTile>(find.widgetWithText(ListTile, 'Scheda A').last)
        .onTap!();
    await tester.pumpAndSettle();
    tester.widget<ListTile>(find.widgetWithText(ListTile, 'Scheda B')).onTap!();
    await tester.pumpAndSettle();
    tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('Pianificazione aggiornata'), findsOneWidget);
    expect(
      find.descendant(
        of: dayCardFinder('GIO'),
        matching: find.text('Scheda B'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dayCardFinder('GIO'),
        matching: find.widgetWithText(ListTile, 'Allenamento'),
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('modifica: cambia la data pianificata mantenendo lo stesso id', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester);

    await tapAddForDay(tester, 'MER');
    selectType(tester, 'Recupero');
    tapSave(tester);
    await tester.pumpAndSettle();
    clearSnackBar(tester);

    await tapActivityTile(tester, 'MER', 'Recupero');
    tester
        .widget<ListTile>(find.widgetWithText(ListTile, '26 agosto 2026'))
        .onTap!();
    await tester.pumpAndSettle();

    final okLabel = MaterialLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    ).okButtonLabel;
    await tester.tap(find.text('27'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(okLabel));
    await tester.pumpAndSettle();

    tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('Pianificazione aggiornata'), findsOneWidget);
    expect(
      find.descendant(
        of: dayCardFinder('GIO'),
        matching: find.text('Giorno di recupero'),
      ),
      findsOneWidget,
    );
    expect(find.text('Nessuna attività pianificata'), findsNWidgets(6));

    await disposeCleanly(tester);
  });

  testWidgets(
    'cambio tipo WORKOUT -> WALK rimuove il riferimento alla scheda',
    (tester) async {
      await createWorkout('Scheda gambe');
      await pumpWeeklyPlanPage(tester);

      await tapAddForDay(tester, 'LUN');
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Scegli un allenamento'),
          )
          .onPressed!();
      await tester.pumpAndSettle();
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Scheda gambe'))
          .onTap!();
      await tester.pumpAndSettle();
      tapSave(tester);
      await tester.pumpAndSettle();
      clearSnackBar(tester);

      await tapActivityTile(tester, 'LUN', 'Allenamento');
      selectType(tester, 'Camminata');
      await tester.pumpAndSettle();
      // Il form ora mostra il campo durata (Camminata), non più il
      // riferimento al Workout: la normalizzazione ha già rimosso il campo
      // non pertinente prima ancora del salvataggio.
      expect(
        find.text('Durata pianificata (minuti, facoltativa)'),
        findsOneWidget,
      );
      tapSave(tester);
      await tester.pumpAndSettle();

      expect(find.text('Pianificazione aggiornata'), findsOneWidget);
      expect(
        find.descendant(
          of: dayCardFinder('LUN'),
          matching: find.text('Camminata pianificata'),
        ),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets('cambio tipo WALK -> RECOVERY rimuove la durata pianificata', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester);

    await tapAddForDay(tester, 'MAR');
    selectType(tester, 'Camminata');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '30');
    tapSave(tester);
    await tester.pumpAndSettle();
    clearSnackBar(tester);

    await tapActivityTile(tester, 'MAR', 'Camminata');
    selectType(tester, 'Recupero');
    await tester.pumpAndSettle();
    expect(find.text('30'), findsNothing);
    tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('Pianificazione aggiornata'), findsOneWidget);
    expect(
      find.descendant(
        of: dayCardFinder('MAR'),
        matching: find.text('Giorno di recupero'),
      ),
      findsOneWidget,
    );
    expect(find.text('30 min'), findsNothing);

    await disposeCleanly(tester);
  });

  testWidgets(
    'cambio tipo RECOVERY -> WORKOUT richiede la scelta di una scheda',
    (tester) async {
      final workoutId = await createWorkout('Scheda braccia');
      await pumpWeeklyPlanPage(tester);

      await tapAddForDay(tester, 'DOM');
      selectType(tester, 'Recupero');
      tapSave(tester);
      await tester.pumpAndSettle();
      clearSnackBar(tester);

      await tapActivityTile(tester, 'DOM', 'Recupero');
      selectType(tester, 'Allenamento');
      await tester.pumpAndSettle();
      tapSave(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Indica la scheda da collegare all\'allenamento pianificato.',
        ),
        findsOneWidget,
      );
      // Il form resta aperto: nessun pop dopo l'errore di validazione.
      expect(find.text('Modifica attività'), findsOneWidget);

      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Scegli un allenamento'),
          )
          .onPressed!();
      await tester.pumpAndSettle();
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Scheda braccia'))
          .onTap!();
      await tester.pumpAndSettle();
      tapSave(tester);
      await tester.pumpAndSettle();

      expect(find.text('Pianificazione aggiornata'), findsOneWidget);
      final workout = await DriftWorkoutRepository(
        database,
      ).getWorkoutById(workoutId);
      expect(workout, isNotNull);

      await disposeCleanly(tester);
    },
  );

  testWidgets('elimina un\'attività pianificata dopo conferma', (tester) async {
    await pumpWeeklyPlanPage(tester);

    await tapAddForDay(tester, 'SAB');
    selectType(tester, 'Recupero');
    tapSave(tester);
    await tester.pumpAndSettle();
    clearSnackBar(tester);

    await tapDeleteForDay(tester, 'SAB');
    expect(find.text('Eliminare questa attività pianificata?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
    await tester.pumpAndSettle();

    expect(find.text('Attività rimossa'), findsOneWidget);
    expect(
      find.descendant(
        of: dayCardFinder('SAB'),
        matching: find.text('Nessuna attività pianificata'),
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('annullare l\'eliminazione non rimuove l\'attività', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester);

    await tapAddForDay(tester, 'SAB');
    selectType(tester, 'Recupero');
    tapSave(tester);
    await tester.pumpAndSettle();
    clearSnackBar(tester);

    await tapDeleteForDay(tester, 'SAB');
    await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: dayCardFinder('SAB'),
        matching: find.text('Giorno di recupero'),
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'allenamento eliminato dopo la pianificazione: mostra stato neutro senza '
    'crash, resta modificabile ed eliminabile',
    (tester) async {
      final workoutId = await createWorkout('Scheda da eliminare');
      final repository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      await AddPlannedActivity(repository)(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 8, 28),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
          origin: PlannedActivityOrigin.user,
        ),
      );
      await DriftWorkoutRepository(database).deleteWorkout(workoutId);

      await pumpWeeklyPlanPage(tester);
      expect(tester.takeException(), isNull);

      expect(
        find.descendant(
          of: dayCardFinder('VEN'),
          matching: find.text('Allenamento non più disponibile'),
        ),
        findsOneWidget,
      );

      await tapActivityTile(tester, 'VEN', 'Allenamento');
      expect(find.text('Allenamento non più disponibile.'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Scegli un allenamento'),
        findsOneWidget,
      );
      // Chiude il bottom sheet senza salvare (nessun BackButton dentro un
      // bottom sheet: qui il pop equivalente è la topmost route sullo
      // stesso Navigator, esattamente come un tap fuori dal foglio o il
      // gesto Indietro di sistema).
      Navigator.of(
        tester.element(find.text('Allenamento non più disponibile.')),
      ).pop();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tapDeleteForDay(tester, 'VEN');
      await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
      await tester.pumpAndSettle();
      expect(find.text('Attività rimossa'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await disposeCleanly(tester);
    },
  );

  testWidgets('doppio tap su Salva non crea attività duplicate', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester);

    await tapAddForDay(tester, 'LUN');
    selectType(tester, 'Recupero');
    await tester.pumpAndSettle();

    final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Salva');
    await tester.tap(saveButtonFinder);
    await tester.tap(saveButtonFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: dayCardFinder('LUN'),
        matching: find.widgetWithText(ListTile, 'Recupero'),
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'un\'attività di un altro profilo non compare nel piano corrente',
    (tester) async {
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
      // Un secondo profilo, creato dopo, diventa quello "corrente"
      // (id più alto): la UI deve mostrare la SUA settimana, senza
      // l'attività appena creata per il profilo precedente.
      await ProfileRepositoryImpl(database.userProfileDao).saveProfile(
        UserProfile(
          name: 'Sam',
          birthDate: DateTime(1992, 1, 1),
          heightCm: 170,
          initialWeightKg: 70,
          preferredWalkMinutes: 20,
          equipmentBudgetLimit: 0,
          startDate: DateTime(2026, 1, 1),
        ),
      );

      await pumpWeeklyPlanPage(tester);

      expect(find.text('Nessuna attività pianificata'), findsNWidgets(7));

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'naviga tra settimane: precedente, successiva e torna alla corrente',
    (tester) async {
      await pumpWeeklyPlanPage(tester);

      expect(find.text('24 – 30 agosto 2026'), findsOneWidget);

      await tester.tap(find.byTooltip('Settimana successiva'));
      await tester.pumpAndSettle();
      expect(find.text('31 agosto – 6 settembre 2026'), findsOneWidget);

      await tester.tap(find.byTooltip('Settimana precedente'));
      await tester.tap(find.byTooltip('Settimana precedente'));
      await tester.pumpAndSettle();
      expect(find.text('17 – 23 agosto 2026'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(TextButton, 'Vai alla settimana corrente'),
      );
      await tester.pumpAndSettle();
      expect(find.text('24 – 30 agosto 2026'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('navigazione cross-year: dicembre 2026 -> gennaio 2027', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester, now: DateTime(2026, 12, 30, 12));

    expect(find.text('28 dicembre 2026 – 3 gennaio 2027'), findsOneWidget);

    await tester.tap(find.byTooltip('Settimana successiva'));
    await tester.pumpAndSettle();
    expect(find.text('4 – 10 gennaio 2027'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('responsive 320x480: nessun overflow su vista settimana e form', (
    tester,
  ) async {
    await pumpWeeklyPlanPage(tester);

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 480));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tapAddForDay(tester, 'LUN');
    expect(tester.takeException(), isNull);
    selectType(tester, 'Camminata');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '20');
    tapSave(tester);
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

    await tapAddForDay(tester, 'MER');
    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'con la tastiera aperta il campo durata e Salva restano raggiungibili',
    (tester) async {
      await pumpWeeklyPlanPage(tester);

      await tapAddForDay(tester, 'MER');
      selectType(tester, 'Camminata');
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(const Size(400, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.widgetWithText(ElevatedButton, 'Salva'), findsOneWidget);
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Salva'));
      expect(tester.takeException(), isNull);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'route: da Home a Piano settimanale e ritorno con il tasto Indietro',
    (tester) async {
      await pumpWeeklyPlanPage(tester);
      expect(find.widgetWithText(AppBar, 'Piano settimanale'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      // "FORGE" (AppBar, sempre visibile senza scroll) invece del saluto,
      // che vive nel corpo scrollabile della Dashboard.
      expect(find.widgetWithText(AppBar, 'FORGE'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'mostra "In corso"/"Completata" quando l\'attività è collegata a una '
    'sessione reale (Milestone 8.5)',
    (tester) async {
      final workoutId = await createWorkoutWithExercise('Scheda gambe');
      final repository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      final activityId = await AddPlannedActivity(repository)(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
          origin: PlannedActivityOrigin.user,
        ),
      );
      final details = await DriftWorkoutRepository(
        database,
      ).getWorkoutDetails(workoutId);
      final sessionRepository = DriftWorkoutSessionRepository(database);
      final sessionId = await sessionRepository.createSession(
        profileId: profileId,
        details: details!,
        startedAt: DateTime(2026, 8, 26, 8),
      );
      await repository.linkWorkoutSession(
        activityId: activityId,
        workoutSessionId: sessionId,
      );

      await pumpWeeklyPlanPage(tester);

      expect(
        find.descendant(
          of: dayCardFinder('MER'),
          matching: find.text('Scheda gambe · In corso'),
        ),
        findsOneWidget,
      );

      await sessionRepository.completeSession(
        sessionId: sessionId,
        endedAt: DateTime(2026, 8, 26, 9),
      );
      // `persistedWorkoutSessionProvider` è un `FutureProvider.family`: non
      // si aggiorna da solo su un cambiamento nel DB. Un vero remount (come
      // un riavvio dell'app) è l'unico modo per verificare che lo stato
      // "Completata" venga letto correttamente al prossimo avvio.
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpWeeklyPlanPage(tester);

      expect(
        find.descendant(
          of: dayCardFinder('MER'),
          matching: find.text('Scheda gambe · Completata'),
        ),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'eliminazione bloccata con una sessione allenamento attiva collegata '
    '(Milestone 8.5)',
    (tester) async {
      final workoutId = await createWorkoutWithExercise('Scheda gambe');
      final repository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      final activityId = await AddPlannedActivity(repository)(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
          origin: PlannedActivityOrigin.user,
        ),
      );
      final details = await DriftWorkoutRepository(
        database,
      ).getWorkoutDetails(workoutId);
      final sessionId = await DriftWorkoutSessionRepository(database)
          .createSession(
            profileId: profileId,
            details: details!,
            startedAt: DateTime(2026, 8, 26, 8),
          );
      await repository.linkWorkoutSession(
        activityId: activityId,
        workoutSessionId: sessionId,
      );

      await pumpWeeklyPlanPage(tester);

      await tapDeleteForDay(tester, 'MER');
      expect(
        find.text('Eliminare questa attività pianificata?'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Termina o interrompi prima la sessione di allenamento in corso.',
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dayCardFinder('MER'),
          matching: find.text('Scheda gambe · In corso'),
        ),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    },
  );

  group('Milestone 8.6: salta/rinvia/ripristina/sposta', () {
    testWidgets(
      'Salta: badge "Saltata", il menu offre poi "Ripristina nel piano"',
      (tester) async {
        await pumpWeeklyPlanPage(tester);
        await tapAddForDay(tester, 'SAB');
        selectType(tester, 'Recupero');
        tapSave(tester);
        await tester.pumpAndSettle();
        clearSnackBar(tester);

        await tapActivityMenuAction(tester, 'SAB', 'Salta');
        expect(
          find.text('Segnare questa attività come saltata?'),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(TextButton, 'Conferma'));
        await tester.pumpAndSettle();

        expect(find.text('Attività segnata come saltata'), findsOneWidget);
        expect(
          find.descendant(
            of: dayCardFinder('SAB'),
            matching: find.text('Giorno di recupero · Saltata'),
          ),
          findsOneWidget,
        );

        // Il menu ora offre "Ripristina", non più "Salta"/"Rinvia".
        await tester.tap(
          find.descendant(
            of: dayCardFinder('SAB'),
            matching: find.byTooltip('Altre azioni'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Ripristina nel piano'), findsOneWidget);
        expect(find.text('Salta'), findsNothing);
        expect(find.text('Rinvia'), findsNothing);

        await disposeCleanly(tester);
      },
    );

    testWidgets('Rinvia: badge "Rinviata", scheduledDate invariata', (
      tester,
    ) async {
      await pumpWeeklyPlanPage(tester);
      await tapAddForDay(tester, 'SAB');
      selectType(tester, 'Recupero');
      tapSave(tester);
      await tester.pumpAndSettle();
      clearSnackBar(tester);

      await tapActivityMenuAction(tester, 'SAB', 'Rinvia');
      expect(find.text('Rinviare questa attività?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Conferma'));
      await tester.pumpAndSettle();

      expect(find.text('Attività rinviata'), findsOneWidget);
      expect(
        find.descendant(
          of: dayCardFinder('SAB'),
          matching: find.text('Giorno di recupero · Rinviata'),
        ),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    });

    testWidgets('Ripristina: torna PLANNED, nessun suffisso', (tester) async {
      await pumpWeeklyPlanPage(tester);
      await tapAddForDay(tester, 'SAB');
      selectType(tester, 'Recupero');
      tapSave(tester);
      await tester.pumpAndSettle();
      clearSnackBar(tester);
      await tapActivityMenuAction(tester, 'SAB', 'Salta');
      await tester.tap(find.widgetWithText(TextButton, 'Conferma'));
      await tester.pumpAndSettle();
      clearSnackBar(tester);

      await tapActivityMenuAction(tester, 'SAB', 'Ripristina nel piano');
      expect(
        find.text('Ripristinare questa attività nel piano?'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Conferma'));
      await tester.pumpAndSettle();

      expect(find.text('Attività ripristinata nel piano'), findsOneWidget);
      expect(
        find.descendant(
          of: dayCardFinder('SAB'),
          matching: find.text('Giorno di recupero'),
        ),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    });

    testWidgets('Sposta: scompare dal vecchio giorno, compare nel nuovo', (
      tester,
    ) async {
      await pumpWeeklyPlanPage(tester);
      await tapAddForDay(tester, 'MER');
      selectType(tester, 'Recupero');
      tapSave(tester);
      await tester.pumpAndSettle();
      clearSnackBar(tester);

      await tapActivityMenuAction(tester, 'MER', 'Sposta');
      await tester.tap(find.text('27'));
      await tester.pumpAndSettle();
      final okLabel = MaterialLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      ).okButtonLabel;
      await tester.tap(find.text(okLabel));
      await tester.pumpAndSettle();

      expect(find.text('Attività spostata'), findsOneWidget);
      expect(
        find.descendant(
          of: dayCardFinder('MER'),
          matching: find.text('Giorno di recupero'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: dayCardFinder('GIO'),
          matching: find.text('Giorno di recupero'),
        ),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    });

    testWidgets('Sposta attraverso il confine di settimana: scompare dalla '
        'settimana corrente, compare in quella successiva', (tester) async {
      await pumpWeeklyPlanPage(tester);
      await tapAddForDay(tester, 'DOM');
      selectType(tester, 'Recupero');
      tapSave(tester);
      await tester.pumpAndSettle();
      clearSnackBar(tester);

      // DOM di questa settimana è il 30 agosto 2026: spostarla al 31
      // agosto (lunedì) la porta nella settimana successiva (31 agosto
      // - 6 settembre).
      await tapActivityMenuAction(tester, 'DOM', 'Sposta');
      await tester.tap(find.text('31'));
      await tester.pumpAndSettle();
      final okLabel = MaterialLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      ).okButtonLabel;
      await tester.tap(find.text(okLabel));
      await tester.pumpAndSettle();

      expect(find.text('Attività spostata'), findsOneWidget);
      expect(find.text('Nessuna attività pianificata'), findsNWidgets(7));

      await tester.tap(find.byTooltip('Settimana successiva'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: dayCardFinder('LUN'),
          matching: find.text('Giorno di recupero'),
        ),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    });

    testWidgets(
      'Sposta un\'attività Saltata la riporta a PLANNED nella nuova data',
      (tester) async {
        await pumpWeeklyPlanPage(tester);
        await tapAddForDay(tester, 'MER');
        selectType(tester, 'Recupero');
        tapSave(tester);
        await tester.pumpAndSettle();
        clearSnackBar(tester);
        await tapActivityMenuAction(tester, 'MER', 'Salta');
        await tester.tap(find.widgetWithText(TextButton, 'Conferma'));
        await tester.pumpAndSettle();
        clearSnackBar(tester);

        await tapActivityMenuAction(tester, 'MER', 'Sposta');
        await tester.tap(find.text('27'));
        await tester.pumpAndSettle();
        final okLabel = MaterialLocalizations.of(
          tester.element(find.byType(Scaffold).first),
        ).okButtonLabel;
        await tester.tap(find.text(okLabel));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: dayCardFinder('GIO'),
            matching: find.text('Giorno di recupero'),
          ),
          findsOneWidget,
        );

        await disposeCleanly(tester);
      },
    );
  });

  group('Milestone 8.7: riepilogo settimana', () {
    testWidgets('settimana vuota: nessuna card riepilogo', (tester) async {
      await pumpWeeklyPlanPage(tester);

      expect(find.text('Questa settimana'), findsNothing);
      expect(find.text('Riepilogo'), findsNothing);
      expect(find.text('Piano della settimana'), findsNothing);

      await disposeCleanly(tester);
    });

    testWidgets(
      'settimana corrente con stati misti: "Questa settimana", percentuale '
      'solo sulle attività mature',
      (tester) async {
        final workoutId = await createWorkoutWithExercise('Scheda gambe');
        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        // LUN (24 agosto, passata): completata realmente.
        final completedId = await AddPlannedActivity(repository)(
          PlannedActivity(
            profileId: profileId,
            scheduledDate: DateTime(2026, 8, 24),
            type: PlannedActivityType.workout,
            workoutId: workoutId,
            origin: PlannedActivityOrigin.user,
          ),
        );
        final completedActivity = (await repository.getById(completedId))!;
        final details = await DriftWorkoutRepository(
          database,
        ).getWorkoutDetails(workoutId);
        final sessionRepository = DriftWorkoutSessionRepository(database);
        final sessionId = await sessionRepository.createSession(
          profileId: profileId,
          details: details!,
          startedAt: DateTime(2026, 8, 24, 8),
        );
        await repository.linkWorkoutSession(
          activityId: completedId,
          workoutSessionId: sessionId,
        );
        await sessionRepository.completeSession(
          sessionId: sessionId,
          endedAt: DateTime(2026, 8, 24, 9),
        );
        // MAR (25 agosto, passata): ancora da fare.
        await AddPlannedActivity(repository)(
          PlannedActivity(
            profileId: profileId,
            scheduledDate: DateTime(2026, 8, 25),
            type: PlannedActivityType.recovery,
            origin: PlannedActivityOrigin.user,
          ),
        );
        // GIO (27 agosto, futura): ancora da fare, non deve abbassare la
        // percentuale matura (LUN+MAR).
        await AddPlannedActivity(repository)(
          PlannedActivity(
            profileId: profileId,
            scheduledDate: DateTime(2026, 8, 27),
            type: PlannedActivityType.recovery,
            origin: PlannedActivityOrigin.user,
          ),
        );

        await pumpWeeklyPlanPage(tester);

        expect(find.text('Questa settimana'), findsOneWidget);
        expect(
          find.text('Completate 1 su 2 considerate · 2 da fare'),
          findsOneWidget,
        );
        expect(completedActivity.type, PlannedActivityType.workout);

        await disposeCleanly(tester);
      },
    );

    testWidgets(
      'settimana futura: "Piano della settimana", nessuna percentuale',
      (tester) async {
        await pumpWeeklyPlanPage(tester);
        await tester.tap(find.byTooltip('Settimana successiva'));
        await tester.pumpAndSettle();

        await tapAddForDay(tester, 'LUN');
        selectType(tester, 'Camminata');
        await tester.pumpAndSettle();
        tapSave(tester);
        await tester.pumpAndSettle();

        expect(find.text('Piano della settimana'), findsOneWidget);
        expect(
          find.text(
            '1 attività pianificate (0 allenamenti, 1 camminate, 0 recuperi)',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('Completate'), findsNothing);

        await disposeCleanly(tester);
      },
    );

    testWidgets(
      'settimana passata: "Riepilogo", conclusivo su tutta la settimana',
      (tester) async {
        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        await AddPlannedActivity(repository)(
          PlannedActivity(
            profileId: profileId,
            scheduledDate: DateTime(2026, 8, 17),
            type: PlannedActivityType.recovery,
            status: PlannedActivityStatus.skipped,
            origin: PlannedActivityOrigin.user,
          ),
        );

        await pumpWeeklyPlanPage(tester);
        await tester.tap(find.byTooltip('Settimana precedente'));
        await tester.pumpAndSettle();

        expect(find.text('Riepilogo'), findsOneWidget);
        expect(
          find.text('Completate 0 su 1 considerate · 1 saltate'),
          findsOneWidget,
        );

        await disposeCleanly(tester);
      },
    );

    testWidgets('reattivo: Salta aggiorna subito il riepilogo, senza riavvio', (
      tester,
    ) async {
      await pumpWeeklyPlanPage(tester);
      await tapAddForDay(tester, 'MER');
      selectType(tester, 'Recupero');
      tapSave(tester);
      await tester.pumpAndSettle();
      clearSnackBar(tester);

      expect(
        find.text('Completate 0 su 1 considerate · 1 da fare'),
        findsOneWidget,
      );

      await tapActivityMenuAction(tester, 'MER', 'Salta');
      await tester.tap(find.widgetWithText(TextButton, 'Conferma'));
      await tester.pumpAndSettle();

      expect(
        find.text('Completate 0 su 1 considerate · 1 saltate'),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    });
  });

  group('Milestone 8.7 patch: reattività sessioni reali senza riavvio', () {
    testWidgets(
      'sessione Workout completata mentre la pagina resta montata: il '
      'riepilogo si aggiorna senza riavvio',
      (tester) async {
        final workoutId = await createWorkoutWithExercise('Scheda gambe');
        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        final activityId = await AddPlannedActivity(repository)(
          PlannedActivity(
            profileId: profileId,
            scheduledDate: DateTime(2026, 8, 24),
            type: PlannedActivityType.workout,
            workoutId: workoutId,
            origin: PlannedActivityOrigin.user,
          ),
        );
        final details = await DriftWorkoutRepository(
          database,
        ).getWorkoutDetails(workoutId);
        final sessionRepository = DriftWorkoutSessionRepository(database);
        final sessionId = await sessionRepository.createSession(
          profileId: profileId,
          details: details!,
          startedAt: DateTime(2026, 8, 24, 8),
        );
        await repository.linkWorkoutSession(
          activityId: activityId,
          workoutSessionId: sessionId,
        );

        await pumpWeeklyPlanPage(tester);

        expect(
          find.text('Completate 0 su 1 considerate · 1 in corso'),
          findsOneWidget,
        );

        // Nessun riavvio: la sessione completa "da un'altra parte"
        // dell'app (es. la pagina di sessione) mentre WeeklyPlanPage
        // resta montata.
        await sessionRepository.completeSession(
          sessionId: sessionId,
          endedAt: DateTime(2026, 8, 24, 9),
        );
        await tester.pumpAndSettle();

        expect(find.text('Completate 1 su 1 considerate'), findsOneWidget);
        expect(
          find.descendant(
            of: dayCardFinder('LUN'),
            matching: find.text('Scheda gambe · Completata'),
          ),
          findsOneWidget,
        );

        await disposeCleanly(tester);
      },
    );

    testWidgets(
      'sessione Workout abbandonata mentre la pagina resta montata: non '
      'viene mai considerata completata',
      (tester) async {
        final workoutId = await createWorkoutWithExercise('Scheda gambe');
        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        final activityId = await AddPlannedActivity(repository)(
          PlannedActivity(
            profileId: profileId,
            scheduledDate: DateTime(2026, 8, 24),
            type: PlannedActivityType.workout,
            workoutId: workoutId,
            origin: PlannedActivityOrigin.user,
          ),
        );
        final details = await DriftWorkoutRepository(
          database,
        ).getWorkoutDetails(workoutId);
        final sessionRepository = DriftWorkoutSessionRepository(database);
        final sessionId = await sessionRepository.createSession(
          profileId: profileId,
          details: details!,
          startedAt: DateTime(2026, 8, 24, 8),
        );
        await repository.linkWorkoutSession(
          activityId: activityId,
          workoutSessionId: sessionId,
        );

        await pumpWeeklyPlanPage(tester);

        await sessionRepository.abortSession(
          sessionId: sessionId,
          endedAt: DateTime(2026, 8, 24, 9),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Completate 0 su 1 considerate · 1 da fare'),
          findsOneWidget,
        );
        expect(find.textContaining('Completata'), findsNothing);

        await disposeCleanly(tester);
      },
    );

    testWidgets('sessione Walk completata mentre la pagina resta montata: il '
        'riepilogo si aggiorna senza riavvio', (tester) async {
      final repository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      final activityId = await AddPlannedActivity(repository)(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 8, 24),
          type: PlannedActivityType.walk,
          origin: PlannedActivityOrigin.user,
        ),
      );
      final walkingSessionRepository = DriftWalkingSessionRepository(database);
      final sessionId = await walkingSessionRepository.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: DateTime(2026, 8, 24, 8),
          status: WalkingSessionStatus.inProgress,
        ),
      );
      await repository.linkWalkingSession(
        activityId: activityId,
        walkingSessionId: sessionId,
      );

      await pumpWeeklyPlanPage(tester);

      expect(
        find.text('Completate 0 su 1 considerate · 1 in corso'),
        findsOneWidget,
      );

      await walkingSessionRepository.completeWalkingSession(
        sessionId: sessionId,
        endedAt: DateTime(2026, 8, 24, 9),
      );
      await tester.pumpAndSettle();

      expect(find.text('Completate 1 su 1 considerate'), findsOneWidget);

      await disposeCleanly(tester);
    });
  });
}

class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
