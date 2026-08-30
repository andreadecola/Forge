class NotificationChannelConfig {
  const NotificationChannelConfig._();

  static const id = 'forge_reminders';
  static const name = 'Promemoria Forge';
  static const description = 'Promemoria locali di Forge';
  static const importance = NotificationChannelImportance.defaultImportance;
}

enum NotificationChannelImportance { defaultImportance }
