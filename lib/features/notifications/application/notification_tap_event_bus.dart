import 'dart:async';

import '../domain/notification_tap_event.dart';

class NotificationTapEventBus {
  NotificationTapEventBus() : _controller = StreamController.broadcast();

  final StreamController<NotificationTapEvent> _controller;

  Stream<NotificationTapEvent> get stream => _controller.stream;

  void emit(NotificationTapEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  Future<void> dispose() => _controller.close();
}
