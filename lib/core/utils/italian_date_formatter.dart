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
