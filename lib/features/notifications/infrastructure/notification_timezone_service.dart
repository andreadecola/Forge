import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'device_timezone_resolver.dart';

abstract interface class NotificationTimezoneInitializer {
  Future<bool> initialize();
}

class NotificationTimezoneService implements NotificationTimezoneInitializer {
  NotificationTimezoneService({required this.resolver});

  final DeviceTimezoneResolver resolver;
  bool _initialized = false;
  bool _usingFallback = false;
  String? _identifier;

  bool get isInitialized => _initialized;
  bool get usingFallback => _usingFallback;
  String? get identifier => _identifier;

  @override
  Future<bool> initialize() async {
    if (_initialized) {
      return !_usingFallback;
    }

    tz_data.initializeTimeZones();
    try {
      final identifier = await resolver.resolveIdentifier();
      final location = tz.getLocation(identifier);
      tz.setLocalLocation(location);
      _identifier = identifier;
      _initialized = true;
      return true;
    } on Object {
      // UTC is a safe deterministic fallback, but scheduling is rejected by
      // the adapter while this flag is set: a wrong wall-clock reminder is
      // preferable neither to a crash nor to a silently shifted reminder.
      tz.setLocalLocation(tz.UTC);
      _usingFallback = true;
      _initialized = true;
      return false;
    }
  }

  tz.TZDateTime toLocalWallClock(DateTime scheduledAt) {
    if (!_initialized || _usingFallback) {
      throw StateError('Notification timezone is not available.');
    }
    if (scheduledAt.isUtc) {
      throw ArgumentError('scheduledAt must be a local wall-clock DateTime.');
    }

    return tz.TZDateTime(
      tz.local,
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
      scheduledAt.hour,
      scheduledAt.minute,
      scheduledAt.second,
      scheduledAt.millisecond,
      scheduledAt.microsecond,
    );
  }
}
