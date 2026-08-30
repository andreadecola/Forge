import '../backup_json_helpers.dart';

/// Selezione delle chiavi note di `impostazioni_app` (Backup.1, sezione
/// 6): non un dump generico della tabella chiave/valore. `notificationsEnabled`
/// è la sola **intenzione** dichiarata dall'utente, non il permesso OS
/// reale del device di destinazione (Backup.1, sezione 6 — avvertenza
/// esplicita, da tenere presente in una futura UI di restore).
class BackupAppSettings {
  const BackupAppSettings({
    required this.onboardingCompleted,
    required this.themeMode,
    required this.notificationsEnabled,
    this.plannedActivityRemindersEnabled = false,
    this.plannedActivityReminderTimeMinutes,
  });

  final bool onboardingCompleted;
  final String themeMode;
  final bool notificationsEnabled;
  final bool plannedActivityRemindersEnabled;
  final int? plannedActivityReminderTimeMinutes;

  Map<String, dynamic> toJson() => {
    'onboardingCompleted': onboardingCompleted,
    'themeMode': themeMode,
    'notificationsEnabled': notificationsEnabled,
    'plannedActivityRemindersEnabled': plannedActivityRemindersEnabled,
    'plannedActivityReminderTimeMinutes': plannedActivityReminderTimeMinutes,
  };

  static BackupAppSettings fromJson(Map<String, dynamic> json, String path) {
    return BackupAppSettings(
      onboardingCompleted: requireBool(json, 'onboardingCompleted', path),
      themeMode: requireString(json, 'themeMode', path),
      notificationsEnabled: requireBool(json, 'notificationsEnabled', path),
      plannedActivityRemindersEnabled:
          optionalBool(json, 'plannedActivityRemindersEnabled', path) ?? false,
      plannedActivityReminderTimeMinutes: optionalInt(
        json,
        'plannedActivityReminderTimeMinutes',
        path,
      ),
    );
  }
}
