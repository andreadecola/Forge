import 'notification_payload.dart';

class NotificationTapEvent {
  const NotificationTapEvent({required this.rawPayload, required this.payload});

  final String? rawPayload;
  final NotificationPayload? payload;
}
