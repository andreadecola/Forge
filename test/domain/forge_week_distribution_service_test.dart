import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/services/forge_week_distribution_service.dart';

/// Test di `ForgeWeekDistributionService` (Milestone 8.4): puro, nessun
/// DB/Clock — chi lo chiama passa sempre `today` già ottenuto da un Clock
/// iniettato. Settimana Lunedì 2026-08-24 -> Domenica 2026-08-30, stessa
/// settimana già usata nei test di M8.1/8.2/8.3.
void main() {
  final weekStart = DateTime(2026, 8, 24);
  final weekEnd = DateTime(2026, 8, 30);

  group('eligibleDays', () {
    test('settimana interamente futura -> tutti i 7 giorni', () {
      final days = ForgeWeekDistributionService.eligibleDays(
        weekStart: weekStart,
        weekEnd: weekEnd,
        today: DateTime(2026, 8, 20),
      );
      expect(days, hasLength(7));
      expect(days!.first, weekStart);
      expect(days.last, weekEnd);
    });

    test('settimana corrente parziale (oggi giovedì) -> solo da oggi in '
        'avanti', () {
      final today = DateTime(2026, 8, 27); // giovedì
      final days = ForgeWeekDistributionService.eligibleDays(
        weekStart: weekStart,
        weekEnd: weekEnd,
        today: today,
      );
      expect(days, [
        DateTime(2026, 8, 27),
        DateTime(2026, 8, 28),
        DateTime(2026, 8, 29),
        DateTime(2026, 8, 30),
      ]);
    });

    test('oggi è l\'ultimo giorno della settimana -> un solo giorno '
        'eleggibile', () {
      final days = ForgeWeekDistributionService.eligibleDays(
        weekStart: weekStart,
        weekEnd: weekEnd,
        today: weekEnd,
      );
      expect(days, [weekEnd]);
    });

    test('settimana interamente passata -> null', () {
      final days = ForgeWeekDistributionService.eligibleDays(
        weekStart: weekStart,
        weekEnd: weekEnd,
        today: DateTime(2026, 9, 1),
      );
      expect(days, isNull);
    });

    test('oggi è il giorno successivo a weekEnd -> ancora null (limite)', () {
      final days = ForgeWeekDistributionService.eligibleDays(
        weekStart: weekStart,
        weekEnd: weekEnd,
        today: weekEnd.add(const Duration(days: 1)),
      );
      expect(days, isNull);
    });

    test('cross-month: 31 agosto -> 6 settembre 2026', () {
      final days = ForgeWeekDistributionService.eligibleDays(
        weekStart: DateTime(2026, 8, 31),
        weekEnd: DateTime(2026, 9, 6),
        today: DateTime(2026, 8, 28),
      );
      expect(days, hasLength(7));
      expect(days!.first, DateTime(2026, 8, 31));
      expect(days.last, DateTime(2026, 9, 6));
    });

    test('cross-year: 28 dicembre 2026 -> 3 gennaio 2027', () {
      final days = ForgeWeekDistributionService.eligibleDays(
        weekStart: DateTime(2026, 12, 28),
        weekEnd: DateTime(2027, 1, 3),
        today: DateTime(2026, 12, 20),
      );
      expect(days, hasLength(7));
      expect(days!.first, DateTime(2026, 12, 28));
      expect(days.last, DateTime(2027, 1, 3));
    });

    test('settimana con 29 febbraio (2028, bisestile)', () {
      final days = ForgeWeekDistributionService.eligibleDays(
        weekStart: DateTime(2028, 2, 28),
        weekEnd: DateTime(2028, 3, 5),
        today: DateTime(2028, 2, 20),
      );
      expect(days, hasLength(7));
      expect(days, contains(DateTime(2028, 2, 29)));
    });
  });

  group('distribute', () {
    final week = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    test('3 su 7 giorni liberi -> equidistanziati (Lun, Mer, Ven)', () {
      final result = ForgeWeekDistributionService.distribute(
        freeDays: week,
        occupiedDays: const [],
        count: 3,
      );
      expect(result, [
        DateTime(2026, 8, 24),
        DateTime(2026, 8, 26),
        DateTime(2026, 8, 28),
      ]);
    });

    test('1 su 7 giorni liberi -> il primo (indice 0)', () {
      final result = ForgeWeekDistributionService.distribute(
        freeDays: week,
        occupiedDays: const [],
        count: 1,
      );
      expect(result, [DateTime(2026, 8, 24)]);
    });

    test('conteggio uguale ai giorni liberi -> tutti i giorni', () {
      final result = ForgeWeekDistributionService.distribute(
        freeDays: week,
        occupiedDays: const [],
        count: 7,
      );
      expect(result, week);
    });

    test('giorni liberi insufficienti -> completa con i giorni occupati', () {
      final free = [DateTime(2026, 8, 24), DateTime(2026, 8, 25)];
      final occupied = [DateTime(2026, 8, 26), DateTime(2026, 8, 27)];
      final result = ForgeWeekDistributionService.distribute(
        freeDays: free,
        occupiedDays: occupied,
        count: 3,
      );
      expect(result.length, 3);
      expect(result.sublist(0, 2), free);
      expect(free.toSet().intersection(occupied.toSet()), isEmpty);
    });

    test('nessun giorno libero né occupato -> lista vuota, nessuna '
        'eccezione', () {
      final result = ForgeWeekDistributionService.distribute(
        freeDays: const [],
        occupiedDays: const [],
        count: 3,
      );
      expect(result, isEmpty);
    });

    test('conteggio 0 o negativo -> lista vuota', () {
      expect(
        ForgeWeekDistributionService.distribute(
          freeDays: week,
          occupiedDays: const [],
          count: 0,
        ),
        isEmpty,
      );
      expect(
        ForgeWeekDistributionService.distribute(
          freeDays: week,
          occupiedDays: const [],
          count: -1,
        ),
        isEmpty,
      );
    });

    test('determinismo: stesso input, stesso esito ripetuto', () {
      final first = ForgeWeekDistributionService.distribute(
        freeDays: week,
        occupiedDays: const [],
        count: 3,
      );
      final second = ForgeWeekDistributionService.distribute(
        freeDays: week,
        occupiedDays: const [],
        count: 3,
      );
      expect(first, second);
    });
  });
}
