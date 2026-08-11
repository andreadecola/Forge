import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/repository_providers.dart';
import 'package:forge/data/repositories/walking_session_providers.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/features/walking/presentation/pages/walking_session_page.dart';
import 'package:forge/features/walking/presentation/widgets/walking_entry_card.dart';

import 'walking_test_helpers.dart';

final _profile = UserProfile(
  id: 1,
  name: 'Alex',
  birthDate: DateTime(1990, 1, 1),
  heightCm: 175,
  initialWeightKg: 80,
  preferredWalkMinutes: 30,
  equipmentBudgetLimit: 50,
  startDate: DateTime(2026, 1, 1),
);

Widget _app({
  required FakeWalkingSessionRepository repository,
  required FakeWalkingClock clock,
  bool withEntry = false,
  bool largeText = false,
}) {
  final router = GoRouter(
    initialLocation: withEntry ? '/' : '/walking/session',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: withEntry
              ? WalkingEntryCard(profileId: 1)
              : const SizedBox.shrink(),
        ),
      ),
      GoRoute(
        path: '/walking/session',
        builder: (context, state) => const WalkingSessionPage(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(clock),
      walkingSessionRepositoryProvider.overrideWithValue(repository),
      currentProfileProvider.overrideWith((ref) => Stream.value(_profile)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => largeText
          ? MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            )
          : child!,
    ),
  );
}

void main() {
  late FakeWalkingSessionRepository repository;
  late FakeWalkingClock clock;

  setUp(() {
    repository = FakeWalkingSessionRepository();
    clock = FakeWalkingClock();
  });

  testWidgets('entry point mostra Avvia camminata e apre la sessione', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: repository, clock: clock, withEntry: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Avvia camminata'), findsOneWidget);
    await tester.tap(find.text('Avvia camminata'));
    await tester.pumpAndSettle();
    expect(find.text('Camminata'), findsOneWidget);
    expect(find.text('00:00'), findsAtLeastNWidgets(1));
  });

  testWidgets('pagina mostra timer, pausa/riprendi, complete e summary', (
    tester,
  ) async {
    repository.seed(startedAt: clock.now());
    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();
    expect(find.text('In corso'), findsOneWidget);
    expect(find.text('Pausa'), findsOneWidget);
    clock.advance(const Duration(minutes: 10));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('10:00'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Pausa'));
    await tester.pumpAndSettle();
    expect(find.text('In pausa'), findsOneWidget);
    expect(find.text('Riprendi'), findsOneWidget);
    clock.advance(const Duration(minutes: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('10:00'), findsAtLeastNWidgets(1));
    expect(find.text('15:00'), findsAtLeastNWidgets(1));
    expect(find.text('05:00'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Riprendi'));
    await tester.pumpAndSettle();
    clock.advance(const Duration(minutes: 10));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Completa'));
    await tester.pumpAndSettle();
    expect(find.text('Camminata completata'), findsOneWidget);
    expect(find.text('Tempo attivo'), findsOneWidget);
    expect(find.text('20:00'), findsAtLeastNWidgets(1));
    expect(find.text('25:00'), findsAtLeastNWidgets(1));
    expect(find.text('05:00'), findsAtLeastNWidgets(1));
    expect(find.text('Aggiungi dati'), findsOneWidget);
  });

  testWidgets('pagina ripristina una sessione persistita in pausa', (
    tester,
  ) async {
    final startedAt = clock.now();
    repository.seed(
      startedAt: startedAt,
      isPaused: true,
      pauseStartedAt: startedAt.add(const Duration(minutes: 20)),
    );
    clock.advance(const Duration(minutes: 30));
    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();
    expect(find.text('In pausa'), findsOneWidget);
    expect(find.text('20:00'), findsAtLeastNWidgets(1));
    expect(find.text('30:00'), findsAtLeastNWidgets(1));
    expect(find.text('10:00'), findsAtLeastNWidgets(1));
  });

  testWidgets('registra metrics durante la sessione e modifica dal summary', (
    tester,
  ) async {
    repository.seed(startedAt: clock.now());
    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registra dati'));
    await tester.pumpAndSettle();
    expect(find.text('Dati camminata'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '2,4');
    await tester.enterText(find.byType(TextField).at(1), '3200');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('2,4 km'), findsOneWidget);
    expect(find.text('3.200'), findsOneWidget);
    expect(find.text('Dati camminata aggiornati'), findsOneWidget);

    await tester.tap(find.text('Completa'));
    await tester.pumpAndSettle();
    expect(find.text('Modifica'), findsOneWidget);
    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '2,6');
    await tester.enterText(find.byType(TextField).at(1), '3400');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('2,6 km'), findsOneWidget);
    expect(find.text('3.400'), findsOneWidget);
  });

  testWidgets('sheet metriche supporta annullamento e small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    repository.seed(startedAt: clock.now());
    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registra dati'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '3.5');
    await tester.enterText(find.byType(TextField).at(1), '4200');
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('Registra dati'), findsOneWidget);
  });

  testWidgets('abort mostra dialog e back mostra dialog di uscita', (
    tester,
  ) async {
    repository.seed(startedAt: clock.now());
    await tester.pumpWidget(
      _app(repository: repository, clock: clock, withEntry: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riprendi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Interrompi'));
    await tester.pumpAndSettle();
    expect(find.text('Interrompere la camminata?'), findsOneWidget);
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Vuoi uscire dalla schermata?'), findsOneWidget);
  });

  testWidgets(
    'active session mostra Riprendi e pagina non overflowa su schermo piccolo',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      repository.seed(startedAt: clock.now());
      await tester.pumpWidget(
        _app(repository: repository, clock: clock, withEntry: true),
      );
      await tester.pumpAndSettle();
      expect(find.text('Camminata in corso'), findsOneWidget);
      expect(find.text('Riprendi'), findsOneWidget);
      await tester.tap(find.text('Riprendi'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('text scaling alto non causa crash o overflow grave', (
    tester,
  ) async {
    repository.seed(startedAt: clock.now());
    await tester.pumpWidget(
      _app(repository: repository, clock: clock, largeText: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Camminata'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
