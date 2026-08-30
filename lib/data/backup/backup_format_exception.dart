/// Errore strutturale nel formato di backup (Backup.2, sezioni 45/46):
/// campo obbligatorio assente, tipo non corrispondente, enum
/// sconosciuto, data in un formato non valido. Lanciato sempre e solo
/// dalla fase di **parsing** (JSON → modello), mai da un cast/null-check
/// non gestito — [path] individua esattamente il punto del documento
/// (es. `data.workouts[2].origin`), per un messaggio d'errore utile
/// anche fuori da un debugger.
class BackupFormatException implements Exception {
  const BackupFormatException(this.path, this.message);

  final String path;
  final String message;

  @override
  String toString() => 'BackupFormatException: $path — $message';
}
