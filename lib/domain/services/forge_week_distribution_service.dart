/// Determina in quali giorni della settimana collocare N allenamenti Forge
/// (Milestone 8.4). Puro: nessun accesso a DB/clock — chi lo chiama passa
/// sempre `today` già ottenuto da un `Clock` iniettato (mai `DateTime.now()`
/// diretto qui o nei chiamanti). Nessun `Random()`: la distribuzione è
/// sempre la stessa per lo stesso input (sezione 6/17/80).
///
/// Responsabilità volutamente minima (sezione 73): "in quale giorno della
/// settimana va pianificato l'allenamento?" — mai "quale allenamento
/// generare" (Forge Engine, Milestone 5) né "come persisterlo" (repository).
abstract final class ForgeWeekDistributionService {
  /// I giorni della settimana [weekStart]-[weekEnd] su cui è ammesso
  /// generare (sezione 11/12/13): `null` se l'intera settimana è già
  /// passata rispetto a [today] — nessuna generazione consentita. Se la
  /// settimana contiene oggi, i giorni già trascorsi (Lunedì/Martedì/...
  /// prima di oggi) sono esclusi: si genera solo da oggi in avanti. Una
  /// settimana interamente futura restituisce tutti i 7 giorni.
  static List<DateTime>? eligibleDays({
    required DateTime weekStart,
    required DateTime weekEnd,
    required DateTime today,
  }) {
    if (weekEnd.isBefore(today)) return null;
    final start = weekStart.isBefore(today) ? today : weekStart;
    final days = <DateTime>[];
    var day = start;
    while (!day.isAfter(weekEnd)) {
      days.add(day);
      day = day.add(const Duration(days: 1));
    }
    return days;
  }

  /// Sceglie [count] giorni per gli allenamenti Forge, il più possibile
  /// uniformi (sezione 17): prova prima [freeDays] (nessuna attività
  /// esistente, di alcun tipo/origine — evita di norma di affiancare due
  /// Workout Forge nello stesso giorno, sezione 31), poi completa con
  /// [occupiedDays] solo se [freeDays] non basta a coprire [count].
  static List<DateTime> distribute({
    required List<DateTime> freeDays,
    required List<DateTime> occupiedDays,
    required int count,
  }) {
    if (count <= 0) return const [];
    // `List.of(...)`: `_evenlySpaced` può restituire `const []` (giorni
    // liberi esauriti) — servirà comunque `addAll` sotto, quindi la lista
    // deve restare modificabile a prescindere dal ramo che l'ha prodotta.
    final chosen = List.of(_evenlySpaced(freeDays, count));
    if (chosen.length < count) {
      chosen.addAll(_evenlySpaced(occupiedDays, count - chosen.length));
    }
    return chosen;
  }

  /// Sceglie `min(count, days.length)` elementi di [days] equidistanziati
  /// per indice: es. 7 giorni, 3 richiesti -> indici 0, 2, 4 (Lunedì,
  /// Mercoledì, Venerdì). Nessuna casualità: stesso input, stesso esito.
  static List<DateTime> _evenlySpaced(List<DateTime> days, int count) {
    if (days.isEmpty || count <= 0) return const [];
    final n = count < days.length ? count : days.length;
    return [for (var i = 0; i < n; i++) days[(i * days.length) ~/ n]];
  }
}
