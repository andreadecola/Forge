enum NotificationOperationFailure {
  unsupported,
  permissionDenied,
  invalidSchedule,
  timezoneUnavailable,
  pluginFailure,
}

class NotificationOperationResult {
  const NotificationOperationResult.success() : failure = null;

  const NotificationOperationResult.failure(this.failure);

  final NotificationOperationFailure? failure;

  bool get isSuccess => failure == null;
}

class NotificationGatewayException implements Exception {
  const NotificationGatewayException(this.failure, [this.cause]);

  final NotificationOperationFailure failure;
  final Object? cause;
}
