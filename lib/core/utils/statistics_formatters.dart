/// Formattazione numerica per le statistiche allenamenti (Milestone
/// 4.5.2), centralizzata (sezione 42) — nessuna dipendenza da
/// `package:intl`, stessa scelta già fatta per `italian_date_formatter.dart`.
library;

/// Es. `0.8` -> "80%". Arrotonda alla percentuale intera più vicina
/// (nessun decimale, come nell'esempio dello spec).
String formatPercentage(double ratio) => '${(ratio * 100).round()}%';

/// Durata in ore/minuti, formato "X h Y min" (spazi, come nell'esempio
/// dello spec — distinto da `formatSessionDuration`, Milestone 4.5.1,
/// usato altrove con uno stile diverso "XhYmin": non unificato
/// deliberatamente, per non alterare un formato già in uso/testato).
String formatStatisticsDuration(Duration duration) {
  final totalMinutes = duration.inMinutes;
  if (totalMinutes < 60) return '$totalMinutes min';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return minutes == 0 ? '$hours h' : '$hours h $minutes min';
}

/// Es. `2.34` -> "2,3 / settimana". Virgola italiana, una cifra
/// decimale.
String formatWeeklyFrequency(double sessionsPerWeek) {
  final rounded = (sessionsPerWeek * 10).round() / 10;
  return '${rounded.toStringAsFixed(1).replaceAll('.', ',')} / settimana';
}
