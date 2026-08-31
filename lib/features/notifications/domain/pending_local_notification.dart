/// Minimal projection of a pending local notification.
///
/// The application never exposes plugin-specific pending request types. The
/// payload is enough for namespace-scoped reconciliation.
class PendingLocalNotification {
  const PendingLocalNotification({required this.id, this.payload});

  final int id;
  final String? payload;
}
