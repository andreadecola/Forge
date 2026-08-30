import 'backup_read_result.dart';

/// Limite dimensionale del file letto (Backup.4, sezione 14): un backup
/// realistico (migliaia di sessioni/misurazioni) resta dell'ordine di
/// poche centinaia di KB come JSON testuale; 20 MB lascia ampio margine
/// senza permettere un consumo di memoria illimitato da un file
/// arbitrario scelto dall'utente (input non fidato, sezione 9).
const int maxBackupFileSizeBytes = 20 * 1024 * 1024;

/// Astrazione della lettura di un file di backup esistente (Backup.4,
/// sezione 69): complementare a `BackupFileStorage` (Backup.3, scrittura).
/// Nessun dettaglio di piattaforma/plugin filtra oltre questa interfaccia.
abstract class BackupFileReader {
  /// Ritorna il contenuto UTF-8 del file scelto dall'utente, oppure
  /// [BackupReadResult.cancelled] se l'utente ha annullato il picker
  /// (mai un errore, Backup.4 sezione 12), oppure
  /// [BackupReadResult.failure] per ogni altro problema di lettura
  /// (dimensione eccessiva, encoding non valido, errore di piattaforma).
  /// Non fa alcun parsing JSON: quello spetta a `BackupJsonCodec`.
  Future<BackupReadResult> pickAndReadBackup();
}
