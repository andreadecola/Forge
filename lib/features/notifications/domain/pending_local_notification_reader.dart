import 'pending_local_notification.dart';

/// Optional gateway capability used only for namespace-scoped reconciliation.
///
/// Keeping this separate preserves compatibility with gateways that can
/// schedule/cancel deterministically but cannot list pending requests.
abstract interface class PendingLocalNotificationReader {
  Future<List<PendingLocalNotification>> pending();
}
