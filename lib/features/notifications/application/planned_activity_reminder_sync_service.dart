import '../../../domain/entities/notification_settings.dart';
import '../../../domain/entities/planned_activity.dart';
import '../../../domain/entities/planned_activity_enums.dart';
import '../../../domain/repositories/planned_activity_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/repositories/walking_session_repository.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import '../../../domain/services/clock.dart';
import '../../../domain/use_cases/planned_activity_session_lookup.dart';
import '../domain/local_notification_gateway.dart';
import '../domain/notification_permission_gateway.dart';
import '../domain/notification_permission_status.dart';
import '../domain/notification_payload.dart';
import '../domain/pending_local_notification.dart';
import '../domain/pending_local_notification_reader.dart';
import '../domain/scheduled_local_notification.dart';
import 'notification_constants.dart';
import 'notification_ids.dart';
import 'notification_operation.dart';
import 'notification_scheduler.dart';

abstract interface class PlannedActivitySessionStateResolver {
  Future<LinkedSessionState> resolve(PlannedActivity activity);
}

class RepositoryPlannedActivitySessionStateResolver
    implements PlannedActivitySessionStateResolver {
  const RepositoryPlannedActivitySessionStateResolver({
    required this.workoutSessionRepository,
    required this.walkingSessionRepository,
  });

  final WorkoutSessionRepository workoutSessionRepository;
  final WalkingSessionRepository walkingSessionRepository;

  @override
  Future<LinkedSessionState> resolve(PlannedActivity activity) {
    return resolveLinkedSessionState(
      activity,
      workoutSessionRepository,
      walkingSessionRepository,
    );
  }
}

enum PlannedActivityReminderSyncOutcome {
  scheduled,
  cancelled,
  skippedPast,
  notFound,
  failed,
}

class PlannedActivityReminderSyncResult {
  const PlannedActivityReminderSyncResult({
    required this.outcome,
    this.failure,
  });

  const PlannedActivityReminderSyncResult.scheduled()
    : outcome = PlannedActivityReminderSyncOutcome.scheduled,
      failure = null;

  const PlannedActivityReminderSyncResult.cancelled()
    : outcome = PlannedActivityReminderSyncOutcome.cancelled,
      failure = null;

  const PlannedActivityReminderSyncResult.skippedPast()
    : outcome = PlannedActivityReminderSyncOutcome.skippedPast,
      failure = null;

  const PlannedActivityReminderSyncResult.notFound()
    : outcome = PlannedActivityReminderSyncOutcome.notFound,
      failure = null;

  const PlannedActivityReminderSyncResult.failed(this.failure)
    : outcome = PlannedActivityReminderSyncOutcome.failed;

  final PlannedActivityReminderSyncOutcome outcome;
  final NotificationOperationFailure? failure;

  bool get isSuccess => failure == null;
}

class PlannedActivityReminderBulkSyncResult {
  const PlannedActivityReminderBulkSyncResult({
    required this.activityResults,
    required this.orphanCleanupResult,
  });

  final List<PlannedActivityReminderSyncResult> activityResults;
  final PlannedActivityReminderSyncResult? orphanCleanupResult;

  bool get isSuccess =>
      activityResults.every((result) => result.isSuccess) &&
      (orphanCleanupResult?.isSuccess ?? true);
}

class PlannedActivityReminderDesiredSet {
  const PlannedActivityReminderDesiredSet({required this.notifications});

  final List<ScheduledLocalNotification> notifications;
}

abstract interface class PlannedActivityReminderReconciler {
  Future<PlannedActivityReminderBulkSyncResult>
  syncAllPlannedActivityReminders({required int profileId});

  Future<void> clearAllPlannedActivityReminders();
}

/// Projects eligible M8 planned activities onto local notification requests.
///
/// This service is deliberately the only place that combines planned
/// activity state, notification settings, OS permission, local wall-clock
/// time and deterministic notification ids. M8 remains the source of truth;
/// notifications are disposable side effects of that state.
class PlannedActivityReminderSyncService
    implements PlannedActivityReminderReconciler {
  PlannedActivityReminderSyncService({
    required this.plannedActivityRepository,
    required this.settingsRepository,
    required this.permissionGateway,
    required this.notificationGateway,
    required this.sessionStateResolver,
    required this.clock,
  }) : scheduler = NotificationScheduler(
         gateway: notificationGateway,
         clock: clock,
       );

  final PlannedActivityRepository plannedActivityRepository;
  final SettingsRepository settingsRepository;
  final NotificationPermissionGateway permissionGateway;
  final LocalNotificationGateway notificationGateway;
  final PlannedActivitySessionStateResolver sessionStateResolver;
  final Clock clock;
  final NotificationScheduler scheduler;

  // Serializes incremental writes, resume reconciliation and settings
  // reconciliation without introducing a package or a database lock.
  Future<void> _operationTail = Future<void>.value();

  static const namespace = 'planned_activity';

  Future<PlannedActivityReminderSyncResult> syncActivity(int activityId) {
    return _serialize(() => _syncActivity(activityId));
  }

  Future<PlannedActivityReminderSyncResult> _syncActivity(
    int activityId,
  ) async {
    final notificationId = _notificationId(activityId);
    try {
      final activity = await plannedActivityRepository.getById(activityId);
      if (activity == null) {
        return await _cancel(notificationId, missing: true);
      }

      final settings = await settingsRepository.getNotificationSettings();
      final permission = settings.hasDesiredPlannedActivityReminders
          ? await permissionGateway.getPermissionStatus()
          : null;
      return _syncLoadedActivity(activity, settings, permission);
    } on Object {
      return const PlannedActivityReminderSyncResult.failed(
        NotificationOperationFailure.pluginFailure,
      );
    }
  }

  Future<PlannedActivityReminderSyncResult> cancelByActivityId(int activityId) {
    return _serialize(() => _cancelByActivityId(activityId));
  }

  Future<PlannedActivityReminderSyncResult> _cancelByActivityId(
    int activityId,
  ) async {
    try {
      return await _cancel(_notificationId(activityId));
    } on Object {
      return const PlannedActivityReminderSyncResult.failed(
        NotificationOperationFailure.pluginFailure,
      );
    }
  }

  /// Reconciles the complete future/current set belonging to the active
  /// profile. Other notification namespaces are never cancelled.
  @override
  Future<PlannedActivityReminderBulkSyncResult>
  syncAllPlannedActivityReminders({required int profileId}) {
    return _serialize(() => _syncAllPlannedActivityReminders(profileId));
  }

  Future<PlannedActivityReminderDesiredSet>
  computeDesiredPlannedActivityReminders({required int profileId}) {
    return _serialize(() => _computeDesiredPlannedActivityReminders(profileId));
  }

  Future<PlannedActivityReminderDesiredSet>
  _computeDesiredPlannedActivityReminders(int profileId) async {
    final activities = await plannedActivityRepository.getAllForProfile(
      profileId: profileId,
    );
    final settings = await settingsRepository.getNotificationSettings();
    final permission = settings.hasDesiredPlannedActivityReminders
        ? await permissionGateway.getPermissionStatus()
        : null;
    return _computeDesiredFrom(
      activities: activities,
      settings: settings,
      permission: permission,
    );
  }

  Future<PlannedActivityReminderDesiredSet> _computeDesiredFrom({
    required List<PlannedActivity> activities,
    required NotificationSettings settings,
    required NotificationPermissionStatus? permission,
  }) async {
    final notifications = <ScheduledLocalNotification>[];
    for (final activity in activities) {
      try {
        final evaluation = await _evaluateActivity(
          activity,
          settings,
          permission,
        );
        if (evaluation.notification != null) {
          notifications.add(evaluation.notification!);
        }
      } on Object {
        // A single malformed/temporarily unreadable activity must not block
        // reconciliation of the rest of the profile.
      }
    }

    return PlannedActivityReminderDesiredSet(
      notifications: List.unmodifiable(notifications),
    );
  }

  Future<PlannedActivityReminderBulkSyncResult>
  _syncAllPlannedActivityReminders(int profileId) async {
    final activities = await plannedActivityRepository.getAllForProfile(
      profileId: profileId,
    );
    final settings = await settingsRepository.getNotificationSettings();
    final permission = settings.hasDesiredPlannedActivityReminders
        ? await permissionGateway.getPermissionStatus()
        : null;
    final desired = await _computeDesiredFrom(
      activities: activities,
      settings: settings,
      permission: permission,
    );
    final results = <PlannedActivityReminderSyncResult>[];
    final scheduledIds = <int>{};
    final protectedCollisionIds = <int>{};

    final pendingReader = notificationGateway is PendingLocalNotificationReader
        ? notificationGateway as PendingLocalNotificationReader
        : null;
    final pending = pendingReader == null
        ? const <PendingLocalNotification>[]
        : await pendingReader.pending();
    final pendingById = <int, PendingLocalNotification>{
      for (final request in pending) request.id: request,
    };

    for (final notification in desired.notifications) {
      final existing = pendingById[notification.id];
      if (existing != null && existing.payload != notification.payload) {
        // Never overwrite a theoretically colliding id with another entity.
        protectedCollisionIds.add(notification.id);
        results.add(
          const PlannedActivityReminderSyncResult.failed(
            NotificationOperationFailure.pluginFailure,
          ),
        );
        continue;
      }
      final result = await _replace(notification);
      results.add(result);
      if (result.outcome == PlannedActivityReminderSyncOutcome.scheduled) {
        scheduledIds.add(notification.id);
      }
    }

    if (pendingReader == null) {
      // Deterministic cancellation remains available for gateways that do
      // not expose a pending list.
      for (final activity in activities) {
        final id = _notificationId(activity.id!);
        if (!scheduledIds.contains(id)) {
          results.add(await _cancel(id));
        }
      }
    }

    PlannedActivityReminderSyncResult? orphanResult;
    try {
      if (pendingReader == null) {
        return PlannedActivityReminderBulkSyncResult(
          activityResults: List.unmodifiable(results),
          orphanCleanupResult: orphanResult,
        );
      }
      for (final request in pending) {
        final payload = NotificationPayloadCodec.tryDecode(request.payload);
        if (payload?.type != NotificationPayloadTypes.plannedActivity) {
          continue;
        }
        if (!scheduledIds.contains(request.id) &&
            !protectedCollisionIds.contains(request.id)) {
          final result = await scheduler.cancel(request.id);
          if (!result.isSuccess) {
            orphanResult = PlannedActivityReminderSyncResult.failed(
              result.failure!,
            );
          }
        }
      }
    } on Object {
      orphanResult = const PlannedActivityReminderSyncResult.failed(
        NotificationOperationFailure.pluginFailure,
      );
    }

    return PlannedActivityReminderBulkSyncResult(
      activityResults: List.unmodifiable(results),
      orphanCleanupResult: orphanResult,
    );
  }

  @override
  Future<void> clearAllPlannedActivityReminders() {
    return _serialize(_clearAllPlannedActivityReminders);
  }

  Future<void> _clearAllPlannedActivityReminders() async {
    final pendingReader = notificationGateway is PendingLocalNotificationReader
        ? notificationGateway as PendingLocalNotificationReader
        : null;
    if (pendingReader == null) return;
    for (final request in await pendingReader.pending()) {
      final payload = NotificationPayloadCodec.tryDecode(request.payload);
      if (payload?.type == NotificationPayloadTypes.plannedActivity) {
        await scheduler.cancel(request.id);
      }
    }
  }

  Future<PlannedActivityReminderSyncResult> _syncLoadedActivity(
    PlannedActivity activity,
    NotificationSettings settings,
    NotificationPermissionStatus? permission,
  ) async {
    final notificationId = _notificationId(activity.id!);
    final evaluation = await _evaluateActivity(activity, settings, permission);
    if (evaluation.notification == null) {
      final result = await _cancel(notificationId);
      return evaluation.skippedPast && result.isSuccess
          ? const PlannedActivityReminderSyncResult.skippedPast()
          : result;
    }
    return _replace(evaluation.notification!);
  }

  Future<_PlannedActivityEvaluation> _evaluateActivity(
    PlannedActivity activity,
    NotificationSettings settings,
    NotificationPermissionStatus? permission,
  ) async {
    if (!_isSupportedType(activity.type) ||
        !settings.hasDesiredPlannedActivityReminders ||
        permission != NotificationPermissionStatus.granted ||
        activity.status != PlannedActivityStatus.planned) {
      return const _PlannedActivityEvaluation();
    }

    final sessionState = await sessionStateResolver.resolve(activity);
    if (sessionState != LinkedSessionState.none) {
      return const _PlannedActivityEvaluation();
    }

    final scheduledAt = _scheduledAt(
      activity.scheduledDate,
      settings.plannedActivityReminderTimeMinutes!,
    );
    if (scheduledAt == null || !scheduledAt.isAfter(clock.now())) {
      return _PlannedActivityEvaluation(skippedPast: scheduledAt != null);
    }

    return _PlannedActivityEvaluation(
      notification: ScheduledLocalNotification(
        id: _notificationId(activity.id!),
        scheduledAt: scheduledAt,
        title: _title(activity.type),
        body: _body(activity.type),
        payload: NotificationPayloadCodec.encode(
          NotificationPayload(
            type: NotificationPayloadTypes.plannedActivity,
            entityId: activity.id!,
          ),
        ),
      ),
    );
  }

  Future<PlannedActivityReminderSyncResult> _replace(
    ScheduledLocalNotification notification,
  ) async {
    final cancelResult = await scheduler.cancel(notification.id);
    if (!cancelResult.isSuccess) {
      return PlannedActivityReminderSyncResult.failed(cancelResult.failure!);
    }
    final result = await scheduler.schedule(notification);
    return result.isSuccess
        ? const PlannedActivityReminderSyncResult.scheduled()
        : PlannedActivityReminderSyncResult.failed(result.failure!);
  }

  Future<PlannedActivityReminderSyncResult> _cancel(
    int notificationId, {
    bool missing = false,
  }) async {
    final result = await scheduler.cancel(notificationId);
    if (!result.isSuccess) {
      return PlannedActivityReminderSyncResult.failed(result.failure!);
    }
    if (missing) return const PlannedActivityReminderSyncResult.notFound();
    return const PlannedActivityReminderSyncResult.cancelled();
  }

  static bool _isSupportedType(PlannedActivityType type) =>
      type == PlannedActivityType.workout || type == PlannedActivityType.walk;

  static int _notificationId(int activityId) =>
      NotificationIdGenerator.forEntity(
        namespace: namespace,
        entityId: activityId,
      );

  static DateTime? _scheduledAt(DateTime date, int minutes) {
    if (minutes < 0 || minutes >= 24 * 60) return null;
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    );
    if (scheduledAt.year != date.year ||
        scheduledAt.month != date.month ||
        scheduledAt.day != date.day) {
      return null;
    }
    return scheduledAt;
  }

  static String _title(PlannedActivityType type) => switch (type) {
    PlannedActivityType.workout => 'Allenamento previsto oggi',
    PlannedActivityType.walk => 'Camminata prevista oggi',
    PlannedActivityType.recovery => '',
  };

  static String _body(PlannedActivityType type) => switch (type) {
    PlannedActivityType.workout => 'Quando vuoi, il tuo allenamento è pronto.',
    PlannedActivityType.walk => 'Quando vuoi, la tua camminata è pronta.',
    PlannedActivityType.recovery => '',
  };

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _operationTail.then<T>((_) => operation());
    _operationTail = result.then<void>((_) {}).catchError((Object _) {});
    return result;
  }
}

class _PlannedActivityEvaluation {
  const _PlannedActivityEvaluation({
    this.notification,
    this.skippedPast = false,
  });

  final ScheduledLocalNotification? notification;
  final bool skippedPast;
}
