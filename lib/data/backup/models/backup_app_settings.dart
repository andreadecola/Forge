import '../backup_json_helpers.dart';

/// Selezione delle 3 chiavi note di `impostazioni_app` (Backup.1, sezione
/// 6): non un dump generico della tabella chiave/valore. `notificationsEnabled`
/// è la sola **intenzione** dichiarata dall'utente, non il permesso OS
/// reale del device di destinazione (Backup.1, sezione 6 — avvertenza
/// esplicita, da tenere presente in una futura UI di restore).
class BackupAppSettings {
  const BackupAppSettings({
    required this.onboardingCompleted,
    required this.themeMode,
    required this.notificationsEnabled,
  });

  final bool onboardingCompleted;
  final String themeMode;
  final bool notificationsEnabled;

  Map<String, dynamic> toJson() => {
    'onboardingCompleted': onboardingCompleted,
    'themeMode': themeMode,
    'notificationsEnabled': notificationsEnabled,
  };

  static BackupAppSettings fromJson(Map<String, dynamic> json, String path) {
    return BackupAppSettings(
      onboardingCompleted: requireBool(json, 'onboardingCompleted', path),
      themeMode: requireString(json, 'themeMode', path),
      notificationsEnabled: requireBool(json, 'notificationsEnabled', path),
    );
  }
}
