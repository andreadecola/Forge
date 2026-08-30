import 'dart:convert';

import 'backup_format_exception.dart';
import 'models/forge_backup_v1.dart';

/// Codifica/decodifica tra [ForgeBackupV1] e JSON (Backup.2, sezioni
/// 41-46). Output **pretty-printed** (Backup.2, sezione 42): il backup è
/// un file che l'utente può ispezionare manualmente, e il costo
/// dell'indentazione è trascurabile per volumi di dati non hot-path
/// (Backup.1, sezione 65) — decisione esplicita, non un default
/// accidentale.
///
/// Il parsing ignora silenziosamente eventuali chiavi JSON sconosciute
/// (Backup.2, sezione 44 — forward compatibility): ogni modello legge
/// solo le chiavi che conosce, senza validare l'assenza di chiavi extra.
abstract final class BackupJsonCodec {
  static const JsonEncoder _prettyEncoder = JsonEncoder.withIndent('  ');

  static String encode(ForgeBackupV1 backup) {
    return _prettyEncoder.convert(backup.toJson());
  }

  /// Lancia [BackupFormatException] per qualunque problema strutturale:
  /// JSON non valido, campo obbligatorio assente, tipo errato, data in
  /// formato non valido (Backup.2, sezioni 45/46) — mai un'eccezione
  /// grezza di `dart:convert` o un cast error non gestito.
  static ForgeBackupV1 decode(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException catch (e) {
      throw BackupFormatException(r'$', 'JSON non valido: ${e.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      throw BackupFormatException(
        r'$',
        'Documento di backup di tipo errato: atteso un object JSON alla '
            'radice, trovato ${decoded.runtimeType}.',
      );
    }
    return ForgeBackupV1.fromJson(decoded);
  }
}
