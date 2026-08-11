import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/repository_providers.dart';
import 'package:forge/data/repositories/walking_session_providers.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/features/walking/presentation/pages/walking_history_detail_page.dart';
import 'package:forge/features/walking/presentation/pages/walking_history_page.dart';
import 'package:forge/features/walking/presentation/pages/walking_session_page.dart';
import 'package:forge/features/walking/presentation/pages/walking_statistics_page.dart';
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
  bool entry = true,
}) {
  final router = GoRouter(
    initialLocation: entry ? '/' : '/walking/session',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            Scaffold(body: WalkingEntryCard(profileId: _profile.id!)),
      ),
      GoRoute(
        path: '/walking/session',
        builder: (context, state) => const WalkingSessionPage(),
      ),
      GoRoute(
        path: '/walking/history',
        builder: (context, state) => const WalkingHistoryPage(),
      ),
      GoRoute(
        path: '/walking/history/:id',
        builder: (context, state) => WalkingHistoryDetailPage(
          sessionId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/walking/statistics',
        builder: (context, state) => const WalkingStatisticsPage(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(clock),
      walkingSessionRepositoryProvider.overrideWithValue(repository),
      currentProfileProvider.overrideWith((ref) => Stream.value(_profile)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('flusso completo walking resta coerente dopo restore', (
    tester,
  ) async {
    final repository = FakeWalkingSessionRepository();
    final clock = FakeWalkingClock(DateTime(2026, 1, 1, 10));
    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Avvia camminata'));
    await tester.pumpAndSettle();
    clock.advance(const Duration(minutes: 10));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Pausa'));
    await tester.pumpAndSettle();

    // Ricrea l'intero ProviderScope: il record persistito è la fonte del restore.
    clock.advance(const Duration(minutes: 5));
    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();
    expect(find.text('Camminata in corso'), findsOneWidget);
    await tester.tap(find.text('Riprendi'));
    await tester.pumpAndSettle();
    expect(find.text('In pausa'), findsOneWidget);
    expect(find.text('10:00'), findsAtLeastNWidgets(1));
    expect(find.text('15:00'), findsAtLeastNWidgets(1));
    expect(find.text('05:00'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Riprendi'));
    await tester.pumpAndSettle();
    clock.advance(const Duration(minutes: 10));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Registra dati'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '3,5');
    await tester.enterText(find.byType(TextField).at(1), '4200');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Completa'));
    await tester.tap(find.text('Completa'));
    await tester.pumpAndSettle();
    expect(find.text('Camminata completata'), findsOneWidget);
    expect(find.text('20:00'), findsAtLeastNWidgets(1));
    expect(find.text('25:00'), findsAtLeastNWidgets(1));
    expect(find.text('05:00'), findsAtLeastNWidgets(1));
    expect(find.text('3,5 km'), findsOneWidget);
    expect(find.text('4.200'), findsOneWidget);

    await tester.tap(find.text('Fine'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Storico'));
    await tester.pumpAndSettle();
    expect(find.text('Storico camminate'), findsOneWidget);
    expect(find.text('Completata'), findsAtLeastNWidgets(1));
    expect(find.textContaining('3,5 km'), findsOneWidget);

    await tester.tap(find.textContaining('Camminata').last);
    await tester.pumpAndSettle();
    expect(find.text('Dettaglio camminata'), findsOneWidget);
    expect(find.text('Tempo attivo'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Statistiche'));
    await tester.pumpAndSettle();
    expect(find.text('Statistiche camminate'), findsOneWidget);
    expect(find.text('20 min'), findsOneWidget);
    expect(find.text('3,5 km'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
