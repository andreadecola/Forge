class ScheduledLocalNotification {
  const ScheduledLocalNotification({
    required this.id,
    required this.scheduledAt,
    required this.title,
    required this.body,
    this.payload,
  });

  final int id;
  final DateTime scheduledAt;
  final String title;
  final String body;
  final String? payload;
}
