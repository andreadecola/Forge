import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';

void main() {
  testWidgets('App shows dashboard with bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ForgeApp()));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Programma'), findsOneWidget);
    expect(find.text('Progressi'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);
  });

  testWidgets('Tapping a destination navigates to the matching page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ForgeApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Programma'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Il piano di allenamento sarà disponibile nelle prossime milestone.',
      ),
      findsOneWidget,
    );
  });
}
