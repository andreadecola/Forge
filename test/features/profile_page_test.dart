import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/core/constants/activity_level.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/repository_providers.dart';
import 'package:forge/domain/entities/biological_sex.dart';
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/repositories/profile_repository.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/features/settings/presentation/pages/profile_page.dart';

import 'exercise_test_fixtures.dart';

void main() {
  final fixedNow = DateTime(2026, 8, 29, 12);

  UserProfile profile({
    BiologicalSexForFormula? sex,
    ActivityLevel activityLevel = ActivityLevel.sedentary,
  }) {
    return UserProfile(
      id: 7,
      name: 'Alex',
      birthDate: DateTime(1990, 1, 1),
      biologicalSexForFormula: sex,
      heightCm: 175,
      initialWeightKg: 150,
      targetWeightKg: 120,
      preferredWalkMinutes: 30,
      equipmentBudgetLimit: 50,
      startDate: DateTime(2026, 1, 1),
      activityLevel: activityLevel,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 8, 1),
    );
  }

  Future<void> pumpEditor(
    WidgetTester tester, {
    required UserProfile initialProfile,
    required _FakeProfileRepository repository,
    MediaQueryData? mediaQuery,
  }) async {
    final app = MaterialApp(home: const ProfilePage());
    final scoped = ProviderScope(
      overrides: [
        currentProfileProvider.overrideWith(
          (ref) => Stream.value(initialProfile),
        ),
        profileRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(_FixedClock(fixedNow)),
      ],
      child: app,
    );
    await tester.pumpWidget(
      mediaQuery == null ? scoped : MediaQuery(data: mediaQuery, child: scoped),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) {
    final key = switch (label) {
      'Nome' => 'profile-name',
      'Altezza' => 'profile-height',
      'Peso iniziale' => 'profile-initial-weight',
      'Peso obiettivo (facoltativo)' => 'profile-target-weight',
      'Durata camminata preferita' => 'profile-walk-minutes',
      'Budget attrezzatura' => 'profile-equipment-budget',
      _ => throw ArgumentError('Campo non previsto: $label'),
    };
    return find.byKey(ValueKey(key));
  }

  Future<void> show(WidgetTester tester, Finder target) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    final list = find.byKey(const ValueKey('profile-form'));
    await tester.drag(list, const Offset(0, 1000));
    await tester.pump();
    for (var i = 0; i < 20 && target.evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -300));
      await tester.pump();
    }
    expect(target, findsOneWidget);
    await tester.ensureVisible(target);
  }

  Future<void> enterField(
    WidgetTester tester,
    String label,
    String value,
  ) async {
    final target = field(label);
    await show(tester, target);
    await tester.enterText(target, value);
  }

  testWidgets('mostra e aggiorna i campi reali del profilo', (tester) async {
    final initial = profile(sex: BiologicalSexForFormula.male);
    final repository = _FakeProfileRepository(initial);
    await pumpEditor(tester, initialProfile: initial, repository: repository);

    expect(find.text('Dati personali'), findsOneWidget);
    expect(find.text('Dati corporei iniziali'), findsOneWidget);
    expect(
      find.text(
        'Il peso iniziale viene usato come riferimento nella sezione Progressi.',
      ),
      findsOneWidget,
    );

    await enterField(tester, 'Nome', 'Bianca');
    await enterField(tester, 'Altezza', '190,5');
    await enterField(tester, 'Peso iniziale', '148,5');
    await enterField(tester, 'Peso obiettivo (facoltativo)', '118,5');
    await enterField(tester, 'Durata camminata preferita', '45');
    await enterField(tester, 'Budget attrezzatura', '1250,5');

    final sexField = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<String>,
    );
    await show(tester, sexField);
    await tester.tap(sexField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Femminile').last);
    await tester.pumpAndSettle();

    final activityField = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<ActivityLevel>,
    );
    await show(tester, activityField);
    await tester.tap(activityField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Molto attivo').last);
    await tester.pumpAndSettle();

    final save = find.byKey(const ValueKey('profile-save'));
    await show(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Dati personali aggiornati'), findsOneWidget);
    final saved = repository.saved!;
    expect(saved.id, initial.id);
    expect(saved.name, 'Bianca');
    expect(saved.birthDate, initial.birthDate);
    expect(saved.heightCm, 190.5);
    expect(saved.initialWeightKg, 148.5);
    expect(saved.targetWeightKg, 118.5);
    expect(saved.preferredWalkMinutes, 45);
    expect(saved.equipmentBudgetLimit, 1250.5);
    expect(saved.biologicalSexForFormula, BiologicalSexForFormula.female);
    expect(saved.activityLevel, ActivityLevel.veryActive);
  });

  testWidgets('riusa la validazione del peso e dell’altezza', (tester) async {
    final initial = profile();
    final repository = _FakeProfileRepository(initial);
    await pumpEditor(tester, initialProfile: initial, repository: repository);

    await enterField(tester, 'Altezza', '');
    final save = find.byKey(const ValueKey('profile-save'));
    await show(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Indica l\'altezza.'), findsOneWidget);
    expect(repository.calls, 0);

    await enterField(tester, 'Altezza', '301');
    await show(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Altezza non plausibile.'), findsOneWidget);
    expect(repository.calls, 0);

    await enterField(tester, 'Altezza', '190,5');
    await enterField(tester, 'Peso iniziale', '148,5');
    await show(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repository.saved!.heightCm, 190.5);
    expect(repository.saved!.initialWeightKg, 148.5);
  });

  testWidgets('il doppio tap durante il salvataggio esegue un solo update', (
    tester,
  ) async {
    final initial = profile();
    final repository = _FakeProfileRepository(initial);
    final gate = Completer<void>();
    repository.gate = gate;
    await pumpEditor(tester, initialProfile: initial, repository: repository);

    final save = find.byKey(const ValueKey('profile-save'));
    await show(tester, save);
    tester.widget<ElevatedButton>(save).onPressed!();
    tester.widget<ElevatedButton>(save).onPressed!();
    await tester.pump();

    expect(repository.calls, 1);
    expect(tester.widget<ElevatedButton>(save).onPressed, isNull);

    gate.complete();
    await tester.pumpAndSettle();
    expect(repository.calls, 1);
  });

  testWidgets('errore repository: feedback e valori del form conservati', (
    tester,
  ) async {
    final initial = profile();
    final repository = _FakeProfileRepository(initial)..shouldFail = true;
    await pumpEditor(tester, initialProfile: initial, repository: repository);

    await enterField(tester, 'Nome', 'Valore conservato');
    final save = find.byKey(const ValueKey('profile-save'));
    await show(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Impossibile aggiornare i dati'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextFormField>(field('Nome')).controller!.text,
      'Valore conservato',
    );
    expect(tester.widget<ElevatedButton>(save).onPressed, isNotNull);

    // Recovery reale (Milestone 7.7, sezione 42): dopo l'errore il form deve
    // restare davvero utilizzabile, non solo "riabilitato" — un secondo
    // tentativo, questa volta senza fallimento, deve avere successo e
    // persistere i valori già inseriti.
    repository.shouldFail = false;
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Dati personali aggiornati'), findsOneWidget);
    expect(repository.saved?.name, 'Valore conservato');
  });

  testWidgets('profilo reale aggiorna Progressi senza cambiare i punti chart', (
    tester,
  ) async {
    final database = memoryDatabase();
    addTearDown(database.close);
    await seedAppWith(database);
    final current = await database.userProfileDao.getCurrentProfile();
    final profileId = current!.id;
    final bodyRepository = BodyMetricsRepositoryImpl(
      database.bodyMeasurementsDao,
    );
    await bodyRepository.addMeasurement(
      BodyMeasurement(
        profileId: profileId,
        measuredAt: fixedNow.subtract(const Duration(days: 1)),
        weightKg: 145,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(_FixedClock(fixedNow)),
        ],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progressi'));
    await tester.pumpAndSettle();
    expect(find.text('1 misurazione nel periodo selezionato'), findsOneWidget);

    await tester.tap(find.text('Profilo'));
    await tester.pumpAndSettle();
    await enterField(tester, 'Peso iniziale', '148');
    final save = find.byKey(const ValueKey('profile-save'));
    await show(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    // Rimuove subito lo SnackBar di conferma appena mostrato: senza questo,
    // il suo overlay può sovrapporsi e intercettare il tap sulla tab
    // "Progressi" subito successivo (stesso principio già documentato in
    // progress_page_test.dart/pressure_page_test.dart).
    ScaffoldMessenger.of(tester.element(save)).clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progressi'));
    await tester.pumpAndSettle();
    expect(find.text('148 kg'), findsOneWidget);
    expect(find.text('1 misurazione nel periodo selezionato'), findsOneWidget);
    expect((await database.userProfileDao.getCurrentProfile())!.id, profileId);
    expect(
      (await database.userProfileDao.getCurrentProfile())!.initialWeightKg,
      148,
    );

    await disposeCleanly(tester);
  });

  testWidgets('form scrollabile a 320x480 con testo grande', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final initial = profile();
    await pumpEditor(
      tester,
      initialProfile: initial,
      repository: _FakeProfileRepository(initial),
      mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(2)),
    );

    final save = find.byKey(const ValueKey('profile-save'));
    await show(tester, save);
    expect(tester.takeException(), isNull);
    expect(find.text('Dati personali'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(save).onPressed, isNotNull);
  });

  testWidgets('con la tastiera aperta il bottone Salva resta raggiungibile '
      '(Milestone 7.7)', (tester) async {
    final initial = profile();
    await pumpEditor(
      tester,
      initialProfile: initial,
      repository: _FakeProfileRepository(initial),
    );

    // Simula la tastiera on-screen tramite un viewport ridotto, come
    // farebbe un dispositivo reale quando un campo di testo riceve il
    // focus — stesso principio già usato per pressione e peso/girovita.
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(400, 400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final save = find.byKey(const ValueKey('profile-save'));
    await show(tester, save);
    expect(save, findsOneWidget);
    expect(tester.widget<ElevatedButton>(save).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  UserProfile? profile;
  UserProfile? saved;
  int calls = 0;
  bool shouldFail = false;
  Completer<void>? gate;

  @override
  Future<UserProfile?> getCurrentProfile() async => profile;

  @override
  Stream<UserProfile?> watchCurrentProfile() => Stream.value(profile);

  @override
  Future<int> saveProfile(UserProfile profile) async {
    calls++;
    if (shouldFail) throw StateError('test failure');
    final currentGate = gate;
    if (currentGate != null) await currentGate.future;
    saved = profile;
    this.profile = profile;
    return profile.id!;
  }
}
