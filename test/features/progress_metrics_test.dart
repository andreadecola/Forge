import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/progress/presentation/progress_metrics.dart';

/// Test dei formatter/parser puri del modulo Progressi (Milestone 7.2,
/// estesi in Milestone 7.3 con la pressione).
void main() {
  group('parseDecimalInput', () {
    test('accetta la virgola come separatore decimale', () {
      expect(parseDecimalInput('70,5'), 70.5);
    });

    test('accetta il punto come separatore decimale', () {
      expect(parseDecimalInput('70.5'), 70.5);
    });

    test('accetta un intero senza separatore', () {
      expect(parseDecimalInput('70'), 70.0);
    });

    test('ritorna null per input vuoto o solo spazi', () {
      expect(parseDecimalInput(''), isNull);
      expect(parseDecimalInput('   '), isNull);
    });

    test('ritorna null per input non numerico', () {
      expect(parseDecimalInput('abc'), isNull);
    });

    test('ignora gli spazi esterni', () {
      expect(parseDecimalInput('  70,5  '), 70.5);
    });
  });

  group('formatWeightKg', () {
    test('mostra un intero senza decimali', () {
      expect(formatWeightKg(145), '145 kg');
    });

    test('mostra una cifra decimale con la virgola', () {
      expect(formatWeightKg(145.2), '145,2 kg');
    });

    test('arrotonda a una sola cifra decimale', () {
      expect(formatWeightKg(145.25), '145,3 kg');
    });
  });

  group('formatWaistCm', () {
    test('mostra un intero senza decimali', () {
      expect(formatWaistCm(90), '90 cm');
    });

    test('mostra una cifra decimale con la virgola', () {
      expect(formatWaistCm(90.5), '90,5 cm');
    });
  });

  group('formatWeightDeltaKg', () {
    test('zero esatto non mostra segno', () {
      expect(formatWeightDeltaKg(0), '0 kg');
    });

    test('positivo mostra il segno più', () {
      expect(formatWeightDeltaKg(2.5), '+2,5 kg');
    });

    test('negativo mostra il segno meno (non un trattino)', () {
      expect(formatWeightDeltaKg(-1.5), '−1,5 kg');
    });

    test('negativo intero non mostra decimali', () {
      expect(formatWeightDeltaKg(-3), '−3 kg');
    });
  });

  group('formatBloodPressure', () {
    test('mostra sistolica e diastolica separate da uno slash', () {
      expect(formatBloodPressure(120, 80), '120 / 80 mmHg');
    });

    test('nessun colore o giudizio clinico nel testo prodotto', () {
      final result = formatBloodPressure(180, 110);
      expect(result, '180 / 110 mmHg');
      expect(result.toLowerCase(), isNot(contains('alta')));
      expect(result.toLowerCase(), isNot(contains('normale')));
    });
  });

  group('formatHeartRate', () {
    test('mostra il valore seguito da bpm', () {
      expect(formatHeartRate(72), '72 bpm');
    });
  });
}
