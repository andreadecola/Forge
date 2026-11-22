import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/theme/forge_theme.dart';
import 'package:forge/core/theme/forge_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Inter', 'Manrope']) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/preview/$family.ttf'));
      await loader.load();
    }
  });
  test('la build normale conserva la tipografia precedente', () {
    expect(
      ForgeTheme.dark.textTheme.bodyMedium!.fontSize,
      ThemeData(
        useMaterial3: true,
        colorScheme: ForgeTheme.dark.colorScheme,
      ).textTheme.bodyMedium!.fontSize,
    );
    expect(
      ForgeTheme.dark.filledButtonTheme.style!.textStyle!.resolve({})!.fontSize,
      16,
    );
    expect(ForgeTypography.bodySize, 16);
  });
  for (final family in ['Roboto', 'Inter', 'Manrope']) {
    test('scala proposta centralizzata: $family', () {
      final t = ForgeTheme.preview(true, family).textTheme;
      expect(t.headlineMedium!.fontFamily, family);
      expect(t.headlineMedium!.fontSize, 28);
      expect(t.titleLarge!.fontSize, 20);
      expect(t.bodyMedium!.fontSize, 16);
      expect(t.bodySmall!.fontSize, 14);
      expect(t.labelLarge!.fontSize, 16);
      expect(t.displayLarge!.fontSize, 56);
      expect(
        t.displayMedium!.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    });
    for (final dark in [false, true]) {
      testWidgets('$family tema $dark a 320 px e testo 200%', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: ForgeTheme.preview(dark, family),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              appBar: AppBar(title: const Text('Piano settimanale')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Squat libero a escursione confortevole',
                    style: ForgeTheme.preview(
                      dark,
                      family,
                    ).textTheme.titleLarge,
                  ),
                  const Text(
                    'Camminata 50 min · Dopo gli esercizi. È il tuo allenamento di oggi.',
                  ),
                  Text(
                    '00:15',
                    style: ForgeTheme.preview(
                      dark,
                      family,
                    ).textTheme.displayMedium,
                  ),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Inizia allenamento'),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.scrollUntilVisible(find.text('00:15'), 120);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          MediaQuery.textScalerOf(tester.element(find.text('00:15'))).scale(16),
          32,
        );
      });
    }
  }
}
