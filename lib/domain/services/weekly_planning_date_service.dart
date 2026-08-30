/// Semantica pura della settimana per il Piano Settimanale (Milestone 8.1).
///
/// Puro: nessun accesso a DB/clock/Flutter — chi lo chiama passa sempre una
/// data di riferimento già ottenuta da un `Clock` iniettato (mai
/// `DateTime.now()` diretto qui o nei chiamanti). Settimana Lunedì →
/// Domenica (UX italiana, sezione 24), indipendente da qualunque stringa
/// localizzata: usa solo `DateTime.weekday` (ISO 8601, 1 = lunedì, 7 =
/// domenica) — la UI futura formatterà il testo, questo servizio non lo
/// tocca (sezione 65).
abstract final class WeeklyPlanningDateService {
  /// Il lunedì (mezzanotte locale) della settimana che contiene [reference].
  static DateTime weekStart(DateTime reference) {
    final day = _atMidnight(reference);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// La domenica (mezzanotte locale, sezione 48: non fine giornata) della
  /// settimana che contiene [reference] — [dataPianificata] è sempre
  /// troncata a mezzanotte, quindi un confronto `<= weekEnd` include
  /// correttamente la domenica stessa senza bisogno di 23:59:59.
  static DateTime weekEnd(DateTime reference) {
    final start = weekStart(reference);
    return start.add(const Duration(days: DateTime.daysPerWeek - 1));
  }

  /// Tronca [date] al giorno (mezzanotte locale), per confronti/persistenza
  /// coerenti (sezione 25/48): due orari diversi nello stesso giorno devono
  /// produrre lo stesso [scheduledDate].
  static DateTime atMidnight(DateTime date) => _atMidnight(date);

  static DateTime _atMidnight(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
