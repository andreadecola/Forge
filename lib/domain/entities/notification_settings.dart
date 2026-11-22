/// Preferenze persistenti relative alle notifiche di Forge.
///
/// Questo modello rappresenta la volontà dell'utente, non il permesso
/// concesso dal sistema operativo. L'effettiva attivazione richiede anche un
/// permesso OS compatibile e viene valutata nel layer applicativo.
class NotificationSettings {
  const NotificationSettings({
    required this.notificationsEnabled,
    required this.plannedActivityRemindersEnabled,
    required this.plannedActivityReminderTimeMinutes,
  });

  final bool notificationsEnabled;
  final bool plannedActivityRemindersEnabled;
  final int? plannedActivityReminderTimeMinutes;

  bool get hasValidReminderTime =>
      isValidReminderTimeMinutes(plannedActivityReminderTimeMinutes);

  bool get hasDesiredPlannedActivityReminders => notificationsEnabled;

  /// Il vecchio flag di categoria resta leggibile nei backup, ma non blocca
  /// più i promemoria automatici. Senza preferenza precedente si usa 09:00.
  int get effectiveReminderTimeMinutes =>
      plannedActivityReminderTimeMinutes ?? 9 * 60;

  static bool isValidReminderTimeMinutes(int? value) =>
      value != null && value >= 0 && value <= 1439;

  static void validateReminderTimeMinutes(int? value) {
    if (value != null && !isValidReminderTimeMinutes(value)) {
      throw ArgumentError.value(
        value,
        'plannedActivityReminderTimeMinutes',
        'L\'orario deve essere compreso tra 0 e 1439 minuti.',
      );
    }
  }
}
