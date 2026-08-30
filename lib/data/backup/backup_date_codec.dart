/// Conversioni data/ora condivise dal formato di backup v1 (Backup.1,
/// sezione 7.4): due rappresentazioni distinte, mai intercambiabili.
///
/// - **Date-only** (`scheduledDate`, `birthDate`, `startDate`): il giorno
///   calendariale così come già persistito dal dominio (sempre mezzanotte
///   locale, mai un istante). Si leggono `year`/`month`/`day` direttamente
///   dal [DateTime] ricevuto, senza alcuna conversione UTC/locale: un
///   `toUtc()` qui potrebbe far scivolare il giorno (Backup.1, sezione
///   7.4 — "NON trasformarle accidentalmente in UTC con cambio giorno").
/// - **Timestamp** (`createdAt`, `startedAt`, ecc.): un istante reale,
///   serializzato ISO-8601 UTC esplicito (sempre con suffisso `Z`).
abstract final class BackupDateCodec {
  static String encodeDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime decodeDateOnly(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Data non valida (attesa YYYY-MM-DD): $value');
    }
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static String encodeTimestamp(DateTime dateTime) =>
      dateTime.toUtc().toIso8601String();

  static DateTime decodeTimestamp(String value) =>
      DateTime.parse(value).toUtc();

  static String? encodeTimestampOrNull(DateTime? dateTime) =>
      dateTime == null ? null : encodeTimestamp(dateTime);

  static DateTime? decodeTimestampOrNull(String? value) =>
      value == null ? null : decodeTimestamp(value);
}
