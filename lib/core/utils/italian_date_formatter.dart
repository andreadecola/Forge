/// Formattazione data/ora in italiano per lo storico allenamenti
/// (Milestone 4.5.1). Implementazione manuale (nessuna dipendenza da
/// `package:intl`, non necessaria solo per questo): deterministica e
/// indipendente dal locale/timezone del dispositivo, a differenza di un
/// formatter che leggesse la lingua di sistema — più semplice anche da
/// testare (sezione 46).
library;

const _italianMonths = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

/// Es. "10 agosto 2026".
String formatItalianDate(DateTime date) {
  return '${date.day} ${_italianMonths[date.month - 1]} ${date.year}';
}

/// Es. "18:35". Sempre due cifre, mai "6:35".
String formatItalianTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

const _italianWeekdaysShort = ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM'];

/// Es. "LUN" per lunedì (Milestone 8.2, sezione 11): usa solo
/// `DateTime.weekday` (ISO 8601, 1 = lunedì), mai un nome localizzato di
/// sistema — la logica del Piano Settimanale non dipende da queste stringhe,
/// solo la presentazione le usa.
String italianWeekdayShort(DateTime date) =>
    _italianWeekdaysShort[date.weekday - 1];

/// Intervallo di una settimana (Milestone 8.2, sezione 57), es.
/// "24 – 30 agosto 2026" (stesso mese), "31 agosto – 2 settembre 2026"
/// (mesi diversi, stesso anno), "28 dicembre 2026 – 1 gennaio 2027" (anni
/// diversi). [end] deve essere uguale o posteriore a [start].
String formatItalianWeekRange(DateTime start, DateTime end) {
  if (start.year != end.year) {
    return '${formatItalianDate(start)} – ${formatItalianDate(end)}';
  }
  if (start.month != end.month) {
    return '${start.day} ${_italianMonths[start.month - 1]} – '
        '${formatItalianDate(end)}';
  }
  return '${start.day} – ${end.day} ${_italianMonths[start.month - 1]} '
      '${start.year}';
}

/// Durata totale (`data_fine - data_inizio`, sezione 27/28: include
/// eventuali pause, non è "tempo attivo"). Es. "42 min", "1h 15min".
/// `null` se [finishedAt] non è disponibile (sezione 29 — fallback
/// controllato dal chiamante, questa funzione non decide il testo da
/// mostrare in quel caso).
String? formatSessionDuration({
  required DateTime startedAt,
  required DateTime? finishedAt,
}) {
  if (finishedAt == null) return null;
  final minutes = finishedAt.difference(startedAt).inMinutes;
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  return remainingMinutes == 0
      ? '${hours}h'
      : '${hours}h ${remainingMinutes}min';
}
