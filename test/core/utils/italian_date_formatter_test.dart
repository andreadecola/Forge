import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/utils/italian_date_formatter.dart';

/// Estensioni del formatter per il Piano Settimanale (Milestone 8.2, sezione
/// 11/57): abbreviazioni dei giorni e intervallo settimanale, incluso il
/// comportamento a cavallo di mese/anno.
void main() {
  group('italianWeekdayShort', () {
    test('lunedì -> LUN', () {
      expect(italianWeekdayShort(DateTime(2026, 8, 24)), 'LUN');
    });

    test('domenica -> DOM', () {
      expect(italianWeekdayShort(DateTime(2026, 8, 30)), 'DOM');
    });

    test('copre i 7 giorni nell\'ordine ISO 8601 (lunedì -> domenica)', () {
      final labels = List.generate(
        7,
        (i) =>
            italianWeekdayShort(DateTime(2026, 8, 24).add(Duration(days: i))),
      );
      expect(labels, ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM']);
    });

    test('ignora l\'orario del riferimento', () {
      expect(
        italianWeekdayShort(DateTime(2026, 8, 24, 23, 59)),
        italianWeekdayShort(DateTime(2026, 8, 24)),
      );
    });
  });

  group('formatItalianWeekRange', () {
    test('stesso mese e anno', () {
      expect(
        formatItalianWeekRange(DateTime(2026, 8, 24), DateTime(2026, 8, 30)),
        '24 – 30 agosto 2026',
      );
    });

    test('mesi diversi, stesso anno (cross-month)', () {
      expect(
        formatItalianWeekRange(DateTime(2026, 8, 31), DateTime(2026, 9, 6)),
        '31 agosto – 6 settembre 2026',
      );
    });

    test('anni diversi (cross-year)', () {
      expect(
        formatItalianWeekRange(DateTime(2026, 12, 28), DateTime(2027, 1, 3)),
        '28 dicembre 2026 – 3 gennaio 2027',
      );
    });
  });
}
