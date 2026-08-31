import 'dart:async';

import '../../../data/seed/exercise_catalog_seeder.dart';
import '../../../domain/repositories/profile_repository.dart';
import 'notification_bootstrap_service.dart';
import 'planned_activity_reminder_sync_service.dart';
import '../infrastructure/notification_timezone_service.dart';

/// Coordinates non-core notification reconciliation with app readiness and
/// foreground lifecycle events. It never requests OS permission.
class NotificationLifecycleCoordinator {
  NotificationLifecycleCoordinator({
    required this.notificationBootstrap,
    required this.catalogBootstrap,
    required this.profileRepository,
    required this.timezoneService,
    required this.reminderSyncService,
  });

  final Future<NotificationBootstrapResult> Function() notificationBootstrap;
  final Future<CatalogSeedResult> Function() catalogBootstrap;
  final ProfileRepository profileRepository;
  final NotificationTimezoneRefresher timezoneService;
  final PlannedActivityReminderReconciler reminderSyncService;

  Future<void>? _inFlight;
  bool _rerunRequested = false;
  bool _disposed = false;

  void dispose() {
    _disposed = true;
    _rerunRequested = false;
  }

  Future<void> startup() async {
    try {
      if (_disposed) return;
      if (!await _ready()) return;
      if (_disposed) return;
      await reconcileCurrentProfile();
    } on Object {
      // Forge startup remains available when notification projection fails.
    }
  }

  Future<void> onResumed() async {
    try {
      if (_disposed) return;
      if (!await _ready()) return;
      if (_disposed) return;
      await reconcileCurrentProfile();
    } on Object {
      // A later resume retries the reconciliation.
    }
  }

  Future<void> afterRestore() async {
    try {
      if (_disposed) return;
      if (!await _ready()) return;
      if (_disposed) return;
      await reconcileCurrentProfile();
    } on Object {
      // Restore data remains committed even if notifications are unavailable.
    }
  }

  Future<void> reconcileCurrentProfile() {
    if (_disposed) return Future<void>.value();
    final inFlight = _inFlight;
    if (inFlight != null) {
      _rerunRequested = true;
      return inFlight;
    }

    final operation = _reconcileLoop();
    _inFlight = operation;
    // The lifecycle entry points intentionally observe and swallow
    // reconciliation failures. Observe the bookkeeping future as well, so
    // its completion callback cannot reintroduce the same failure as an
    // unhandled asynchronous error.
    unawaited(
      operation.then<void>(
        (_) {
          if (identical(_inFlight, operation)) _inFlight = null;
        },
        onError: (Object error, StackTrace stackTrace) {
          if (identical(_inFlight, operation)) _inFlight = null;
        },
      ),
    );
    return operation;
  }

  Future<bool> _ready() async {
    if (_disposed) return false;
    final bootstrap = await notificationBootstrap();
    if (_disposed) return false;
    if (!bootstrap.isReady) {
      try {
        await reminderSyncService.clearAllPlannedActivityReminders();
      } on Object {
        // The gateway itself may be unavailable; startup remains non-core.
      }
      return false;
    }
    try {
      await catalogBootstrap();
    } on Object {
      return false;
    }
    if (_disposed) return false;
    return true;
  }

  Future<void> _reconcileLoop() async {
    do {
      _rerunRequested = false;
      await _reconcileOnce();
    } while (_rerunRequested);
  }

  Future<void> _reconcileOnce() async {
    if (_disposed) return;
    final timezoneReady = await timezoneService.refreshIfChanged();
    if (_disposed) return;
    if (!timezoneReady) {
      await reminderSyncService.clearAllPlannedActivityReminders();
      return;
    }

    final profile = await profileRepository.getCurrentProfile();
    final profileId = profile?.id;
    if (profileId == null) {
      await reminderSyncService.clearAllPlannedActivityReminders();
      return;
    }
    await reminderSyncService.syncAllPlannedActivityReminders(
      profileId: profileId,
    );
  }
}
