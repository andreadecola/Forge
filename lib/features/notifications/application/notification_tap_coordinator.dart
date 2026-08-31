import 'dart:async';

import '../domain/notification_tap_event.dart';
import 'notification_tap_event_bus.dart';

typedef NotificationTapHandler =
    Future<void> Function(NotificationTapEvent event);

/// Queues taps until the router is ready and consumes each event once.
/// Routing policy stays outside notification infrastructure.
class NotificationTapCoordinator {
  NotificationTapCoordinator({required this.eventBus});

  final NotificationTapEventBus eventBus;
  StreamSubscription<NotificationTapEvent>? _subscription;
  NotificationTapHandler? _handler;
  NotificationTapEvent? _queuedEvent;
  bool _dispatching = false;

  void start() {
    if (_subscription != null) return;
    final pending = eventBus.takePending();
    if (pending != null) _queuedEvent = pending;
    _subscription = eventBus.stream.listen(_enqueue);
    _drain();
  }

  void setHandler(NotificationTapHandler handler) {
    _handler = handler;
    _drain();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _enqueue(NotificationTapEvent event) {
    eventBus.takePending();
    _queuedEvent = event;
    _drain();
  }

  void _drain() {
    if (_dispatching || _handler == null || _queuedEvent == null) return;
    final event = _queuedEvent!;
    _queuedEvent = null;
    _dispatching = true;
    unawaited(_dispatch(event));
  }

  Future<void> _dispatch(NotificationTapEvent event) async {
    try {
      await _handler!(event);
    } on Object {
      // A stale/invalid tap must never become an unhandled exception.
    } finally {
      _dispatching = false;
      _drain();
    }
  }
}
