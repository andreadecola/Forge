import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/repository_providers.dart';
import 'package:forge/core/theme/theme_mode_provider.dart';
import 'package:forge/core/routing/app_router.dart';
import 'package:forge/core/routing/app_routes.dart';
import 'exercise_test_fixtures.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'Home et Profilo: tema $dark, schermo stretto e caratteri grandi',
      (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await tester.runAsync(() => seedAppWith(db));
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        await tester.runAsync(
          () => container
              .read(settingsRepositoryProvider)
              .setThemeMode(dark ? 'dark' : 'light'),
        );
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const ForgeApp(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          container.read(forgeThemeModeProvider).valueOrNull,
          dark ? ThemeMode.dark : ThemeMode.light,
        );
        container.read(appRouterProvider).go(AppRoutes.profile);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(
          () =>
              container.read(settingsRepositoryProvider).setThemeMode('system'),
        );
        await tester.pumpAndSettle();
        expect(
          container.read(forgeThemeModeProvider).valueOrNull,
          ThemeMode.system,
        );
        expect(tester.takeException(), isNull);
        await disposeCleanly(tester);
        container.dispose();
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  }
}
