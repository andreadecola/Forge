import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/walking/presentation/walking_metrics.dart';

void main() {
  group('parseWalkingDistanceKm', () {
    test('supporta virgola e punto e converte in metri', () {
      expect(parseWalkingDistanceKm('3,5'), 3500);
      expect(parseWalkingDistanceKm('3.5'), 3500);
    });

    test('zero e vuoto', () {
      expect(parseWalkingDistanceKm('0'), 0);
      expect(parseWalkingDistanceKm(''), isNull);
    });

    test('rifiuta valori non validi', () {
      expect(parseWalkingDistanceKm('-1'), isNull);
      expect(parseWalkingDistanceKm('abc'), isNull);
    });
  });

  group('parseWalkingSteps', () {
    test('accetta solo interi non negativi', () {
      expect(parseWalkingSteps('4200'), 4200);
      expect(parseWalkingSteps('0'), 0);
      expect(parseWalkingSteps(''), isNull);
      expect(parseWalkingSteps('-1'), isNull);
      expect(parseWalkingSteps('4.2'), isNull);
    });
  });

  test('formatWalkingDistance usa metri sotto il chilometro', () {
    expect(formatWalkingDistance(850), '850 m');
    expect(formatWalkingDistance(1000), '1,0 km');
    expect(formatWalkingDistance(3500), '3,5 km');
  });

  test('formatWalkingSteps usa separatore delle migliaia italiano', () {
    expect(formatWalkingSteps(4200), '4.200');
    expect(formatWalkingSteps(0), '0');
  });

  test('prefill distanza mantiene la precisione al metro', () {
    expect(formatWalkingDistanceForInput(850), '0,85');
    expect(formatWalkingDistanceForInput(3500), '3,5');
  });
}
