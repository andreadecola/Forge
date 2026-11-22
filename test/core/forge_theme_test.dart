import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/theme/forge_theme.dart';
import 'package:forge/core/theme/theme_mode_provider.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

void main() {
  test('tema legacy e scelta Sistema restano distinti', () {
    expect(forgeThemeModeFromStorage(null), ThemeMode.dark);
    expect(forgeThemeModeFromStorage('dark'), ThemeMode.dark);
    expect(forgeThemeModeFromStorage('light'), ThemeMode.light);
    expect(forgeThemeModeFromStorage('system'), ThemeMode.system);
  });
  for (final dark in [false, true]) {
    test('tema ${dark ? 'scuro' : 'chiaro'}: contrasto testi e azioni', () {
      final theme = dark ? ForgeTheme.dark : ForgeTheme.light;
      final c = theme.colorScheme;
      expect(contrast(c.onSurface, c.surface), greaterThanOrEqualTo(4.5));
      expect(
        contrast(c.onSurfaceVariant, c.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(c.onSurfaceVariant, theme.scaffoldBackgroundColor),
        greaterThanOrEqualTo(4.5),
      );
      expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
      final actionText = theme.textButtonTheme.style!.foregroundColor!.resolve(
        {},
      )!;
      expect(contrast(actionText, c.surface), greaterThanOrEqualTo(4.5));
      expect(
        contrast(c.onPrimaryContainer, c.primaryContainer),
        greaterThanOrEqualTo(4.5),
      );
    });
    testWidgets('azioni leggibili a 320 px e testo 200%, tema $dark', (
      tester,
    ) async {
      tester.view.resetPhysicalSize();
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? ForgeTheme.dark : ForgeTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: ListView(
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Inizia allenamento'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Pianifica allenamento'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
    });
  }
}
