/// Versione del **formato JSON** di backup (Backup.1, sezione 7.2):
/// indipendente da `AppDatabase.schemaVersion` (`databaseVersion` nei
/// metadata). Incrementata solo quando cambia la struttura del
/// contratto JSON in modo incompatibile, mai ad ogni migration del database.
/// `selectedLevels` è un'estensione opzionale di v1: assente/null usa `level`.
/// (Backup.2, sezione 4).
const int currentBackupFormatVersion = 1;

/// Versioni di formato che questa versione dell'app sa leggere/produrre
/// (Backup.2, sezione 4/101): solo 1 per ora — nessuna versione futura
/// da anticipare senza evidenza.
const List<int> supportedBackupFormatVersions = [currentBackupFormatVersion];
