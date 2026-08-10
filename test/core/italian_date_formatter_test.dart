import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/utils/italian_date_formatter.dart';

/// Sezione 46: verifica solo con `DateTime` costruiti esplicitamente, mai
/// dipendente dal locale/timezone del dispositivo che esegue il test.
void main() {
  test('formatItalianDate scrive il mese in lettere, in italiano', () {
    expect(formatItalianDate(DateTime(2026, 8, 10)), '10 agosto 2026');
    expect(formatItalianDate(DateTime(2026, 1, 1)), '1 gennaio 2026');
    expect(formatItalianDate(DateTime(2026, 12, 31)), '31 dicembre 2026');
  });

  test('formatItalianTime è sempre a due cifre (mai "6:35")', () {
    expect(formatItalianTime(DateTime(2026, 8, 10, 18, 35)), '18:35');
    expect(formatItalianTime(DateTime(2026, 8, 10, 6, 5)), '06:05');
    expect(formatItalianTime(DateTime(2026, 8, 10, 0, 0)), '00:00');
  });

  group('formatSessionDuration', () {
    test('null se finishedAt non è disponibile (sezione 29)', () {
      expect(
        formatSessionDuration(
          startedAt: DateTime(2026, 1, 1, 10),
          finishedAt: null,
        ),
        isNull,
      );
    });

    test('minuti sotto l\'ora', () {
      expect(
        formatSessionDuration(
          startedAt: DateTime(2026, 1, 1, 10, 0),
          finishedAt: DateTime(2026, 1, 1, 10, 42),
        ),
        '42 min',
      );
    });

    test('ore esatte, senza minuti residui', () {
      expect(
        formatSessionDuration(
          startedAt: DateTime(2026, 1, 1, 10, 0),
          finishedAt: DateTime(2026, 1, 1, 12, 0),
        ),
        '2h',
      );
    });

    test('ore e minuti', () {
      expect(
        formatSessionDuration(
          startedAt: DateTime(2026, 1, 1, 10, 0),
          finishedAt: DateTime(2026, 1, 1, 11, 15),
        ),
        '1h 15min',
      );
    });

    test('include eventuali pause (differenza grezza, sezione 28): una '
        'sessione "durata" 40 minuti anche se solo 20 sono stati attivi '
        'resta comunque 40 min', () {
      expect(
        formatSessionDuration(
          startedAt: DateTime(2026, 1, 1, 10, 0),
          finishedAt: DateTime(2026, 1, 1, 10, 40),
        ),
        '40 min',
      );
    });
  });
}
