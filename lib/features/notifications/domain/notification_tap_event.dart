import 'notification_payload.dart';

class NotificationTapEvent {
  const NotificationTapEvent({
    required this.rawPayload,
    required this.payload,
    this.actionId,
  });

  final String? rawPayload;
  final NotificationPayload? payload;
  final String? actionId;
}
