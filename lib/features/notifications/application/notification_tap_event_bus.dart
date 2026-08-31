import 'dart:async';

import '../domain/notification_tap_event.dart';

class NotificationTapEventBus {
  NotificationTapEventBus() : _controller = StreamController.broadcast();

  final StreamController<NotificationTapEvent> _controller;
  NotificationTapEvent? _pending;

  Stream<NotificationTapEvent> get stream => _controller.stream;

  void emit(NotificationTapEvent event) {
    if (!_controller.isClosed) {
      _pending = event;
      _controller.add(event);
    }
  }

  NotificationTapEvent? takePending() {
    final event = _pending;
    _pending = null;
    return event;
  }

  Future<void> dispose() => _controller.close();
}
