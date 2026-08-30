abstract final class AppConstants {
  static const String appName = 'Forge';
  static const String databaseName = 'forge_db';

  /// Versione applicativa esposta nei metadata di backup (Backup.2,
  /// sezione 7). Il progetto non ha `package_info_plus` (nessuna
  /// dipendenza aggiunta per questo campo puramente informativo): questa
  /// costante rispecchia manualmente il campo `version:` di
  /// `pubspec.yaml` (senza il build number `+N`) e va aggiornata insieme
  /// ad esso. Un valore disallineato non comprometterebbe la correttezza
  /// del restore (mai usato per decisioni strutturali, solo diagnostico),
  /// ma l'adozione di un meccanismo automatico resta un miglioramento
  /// aperto per una fase successiva.
  static const String appVersion = '1.0.0';
}
