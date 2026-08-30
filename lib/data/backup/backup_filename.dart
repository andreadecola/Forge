/// Nome file del backup (Backup.1, sezione 46; Backup.3, sezione 9/10):
/// `forge_backup_YYYYMMDD_HHMMSS.json`, con i secondi per ridurre la
/// probabilità di collisione tra due backup nello stesso minuto.
///
/// [instant] deve essere lo **stesso** istante logico usato per
/// `BackupMetadata.exportedAt` (stessa chiamata a `Clock.now()`, mai una
/// seconda chiamata separata — Backup.3, sezione 10, evita un mismatch
/// tipo "metadata 11:20:59, filename 11:21:00"). A differenza dei
/// metadata (sempre UTC), il nome file usa la rappresentazione **locale**
/// di quello stesso istante: è pensato per essere letto dall'utente nel
/// picker di destinazione, non per un confronto macchina-a-macchina.
abstract final class BackupFilename {
  static String generate(DateTime instant) {
    final local = instant.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final year = local.year.toString().padLeft(4, '0');
    final month = two(local.month);
    final day = two(local.day);
    final hour = two(local.hour);
    final minute = two(local.minute);
    final second = two(local.second);
    return 'forge_backup_$year$month${day}_$hour$minute$second.json';
  }
}
