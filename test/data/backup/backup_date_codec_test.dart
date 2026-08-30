import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/backup/backup_date_codec.dart';

void main() {
  group('BackupDateCodec — date-only', () {
    test('codifica YYYY-MM-DD senza componente ora', () {
      final encoded = BackupDateCodec.encodeDateOnly(DateTime(2026, 3, 5));
      expect(encoded, '2026-03-05');
    });

    test('non trasforma in UTC: usa year/month/day diretti, mai un giorno '
        'diverso per un DateTime creato in un fuso diverso', () {
      // Un DateTime con orario tardo-serale non deve "scivolare" al giorno
      // successivo se, per assurdo, venisse convertito in UTC — qui non
      // c'è alcuna conversione: il giorno resta quello effettivamente
      // passato (Backup.1, sezione 7.4).
      final lateEvening = DateTime(2026, 12, 31, 23, 59, 59);
      expect(BackupDateCodec.encodeDateOnly(lateEvening), '2026-12-31');
    });

    test('decodeDateOnly è l\'inverso di encodeDateOnly', () {
      final original = DateTime(2024, 1, 1);
      final decoded = BackupDateCodec.decodeDateOnly(
        BackupDateCodec.encodeDateOnly(original),
      );
      expect(decoded, DateTime(2024, 1, 1));
    });

    test('decodeDateOnly rifiuta un formato non valido', () {
      expect(
        () => BackupDateCodec.decodeDateOnly('05-03-2026'),
        throwsFormatException,
      );
    });

    test('leap day (29 febbraio) sopravvive al round-trip', () {
      final leapDay = DateTime(2024, 2, 29);
      final decoded = BackupDateCodec.decodeDateOnly(
        BackupDateCodec.encodeDateOnly(leapDay),
      );
      expect(decoded, leapDay);
    });
  });

  group('BackupDateCodec — timestamp', () {
    test('codifica ISO-8601 UTC con suffisso Z', () {
      final utc = DateTime.utc(2026, 8, 30, 7, 30, 15, 123);
      expect(BackupDateCodec.encodeTimestamp(utc), '2026-08-30T07:30:15.123Z');
    });

    test('un DateTime locale viene normalizzato a UTC in codifica', () {
      final local = DateTime(2026, 1, 1, 12);
      final encoded = BackupDateCodec.encodeTimestamp(local);
      expect(encoded, endsWith('Z'));
      expect(BackupDateCodec.decodeTimestamp(encoded), local.toUtc());
    });

    test('round-trip preserva l\'istante esatto', () {
      final original = DateTime.utc(2025, 6, 15, 18, 45, 30, 500);
      final decoded = BackupDateCodec.decodeTimestamp(
        BackupDateCodec.encodeTimestamp(original),
      );
      expect(decoded, original);
    });

    test('encodeTimestampOrNull/decodeTimestampOrNull preservano il null', () {
      expect(BackupDateCodec.encodeTimestampOrNull(null), isNull);
      expect(BackupDateCodec.decodeTimestampOrNull(null), isNull);
    });
  });
}
