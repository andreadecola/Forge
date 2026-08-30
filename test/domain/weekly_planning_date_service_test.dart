import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/services/weekly_planning_date_service.dart';

/// Test di [WeeklyPlanningDateService] (Milestone 8.1): puro, nessun DB/Clock
/// — verifica la semantica Lunedì → Domenica e la sua tenuta ai boundary
/// (cross-month, cross-year, bisestile) e al determinismo.
void main() {
  group('weekStart', () {
    test('un mercoledì torna il lunedì della stessa settimana', () {
      // 2026-08-26 è un mercoledì.
      final result = WeeklyPlanningDateService.weekStart(DateTime(2026, 8, 26));
      expect(result, DateTime(2026, 8, 24));
      expect(result.weekday, DateTime.monday);
    });

    test('un lunedì resta se stesso', () {
      final monday = DateTime(2026, 8, 24);
      expect(WeeklyPlanningDateService.weekStart(monday), monday);
    });

    test('una domenica torna il lunedì precedente', () {
      // 2026-08-30 è una domenica.
      final result = WeeklyPlanningDateService.weekStart(DateTime(2026, 8, 30));
      expect(result, DateTime(2026, 8, 24));
    });

    test('ignora l\'orario del riferimento (sempre mezzanotte)', () {
      final result = WeeklyPlanningDateService.weekStart(
        DateTime(2026, 8, 26, 23, 59, 59),
      );
      expect(result, DateTime(2026, 8, 24));
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });

  group('weekEnd', () {
    test('è la domenica della stessa settimana, a mezzanotte', () {
      final result = WeeklyPlanningDateService.weekEnd(DateTime(2026, 8, 26));
      expect(result, DateTime(2026, 8, 30));
      expect(result.weekday, DateTime.sunday);
      expect(result.hour, 0);
    });

    test('settimana normale: weekStart e weekEnd distano 6 giorni', () {
      final start = WeeklyPlanningDateService.weekStart(DateTime(2026, 3, 10));
      final end = WeeklyPlanningDateService.weekEnd(DateTime(2026, 3, 10));
      expect(end.difference(start).inDays, 6);
    });
  });

  group('cross-month/cross-year/bisestile', () {
    test('settimana a cavallo tra agosto e settembre', () {
      // 2026-08-31 è un lunedì.
      final start = WeeklyPlanningDateService.weekStart(DateTime(2026, 9, 2));
      final end = WeeklyPlanningDateService.weekEnd(DateTime(2026, 9, 2));
      expect(start, DateTime(2026, 8, 31));
      expect(end, DateTime(2026, 9, 6));
    });

    test('settimana a cavallo tra dicembre e gennaio', () {
      // 2026-12-28 è un lunedì.
      final start = WeeklyPlanningDateService.weekStart(DateTime(2027, 1, 1));
      final end = WeeklyPlanningDateService.weekEnd(DateTime(2027, 1, 1));
      expect(start, DateTime(2026, 12, 28));
      expect(end, DateTime(2027, 1, 3));
    });

    test('29 febbraio di un anno bisestile', () {
      // 2028 è bisestile; 2028-02-29 è un martedì.
      final start = WeeklyPlanningDateService.weekStart(DateTime(2028, 2, 29));
      final end = WeeklyPlanningDateService.weekEnd(DateTime(2028, 2, 29));
      expect(start, DateTime(2028, 2, 28));
      expect(end, DateTime(2028, 3, 5));
    });
  });

  group('atMidnight', () {
    test('tronca ora/minuti/secondi mantenendo il giorno', () {
      final result = WeeklyPlanningDateService.atMidnight(
        DateTime(2026, 8, 26, 14, 30, 15),
      );
      expect(result, DateTime(2026, 8, 26));
    });
  });

  test('determinismo: stesso input, stesso output ripetuto', () {
    final reference = DateTime(2026, 8, 26, 9, 15);
    final first = WeeklyPlanningDateService.weekStart(reference);
    final second = WeeklyPlanningDateService.weekStart(reference);
    expect(first, second);
  });
}
