import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/notifications/infrastructure/device_timezone_resolver.dart';
import 'package:forge/features/notifications/infrastructure/notification_timezone_service.dart';
import 'package:timezone/timezone.dart' as tz;

class _FakeTimezoneResolver implements DeviceTimezoneResolver {
  _FakeTimezoneResolver(this.identifier);

  final String identifier;

  @override
  Future<String> resolveIdentifier() async => identifier;
}

class _MutableTimezoneResolver implements DeviceTimezoneResolver {
  _MutableTimezoneResolver(this.identifier);

  String identifier;

  @override
  Future<String> resolveIdentifier() async => identifier;
}

void main() {
  test('risolve Europe/Rome e conserva la parete locale', () async {
    final service = NotificationTimezoneService(
      resolver: _FakeTimezoneResolver('Europe/Rome'),
    );

    expect(await service.initialize(), isTrue);
    final result = service.toLocalWallClock(DateTime(2026, 8, 30, 18, 30));

    expect(service.identifier, 'Europe/Rome');
    expect(result.location.name, 'Europe/Rome');
    expect(result.hour, 18);
    expect(result.minute, 30);
  });

  test('risolve America/New_York senza assumere il timezone host', () async {
    final service = NotificationTimezoneService(
      resolver: _FakeTimezoneResolver('America/New_York'),
    );

    expect(await service.initialize(), isTrue);
    final result = service.toLocalWallClock(DateTime(2026, 1, 15, 9, 5));

    expect(result.location.name, 'America/New_York');
    expect(result.hour, 9);
    expect(result.minute, 5);
    expect(result.timeZoneOffset, const Duration(hours: -5));
  });

  test('date estiva dopo DST mantiene il fuso locale corretto', () async {
    final service = NotificationTimezoneService(
      resolver: _FakeTimezoneResolver('Europe/Rome'),
    );

    await service.initialize();
    final result = service.toLocalWallClock(DateTime(2026, 7, 1, 9));

    expect(result.timeZoneOffset, const Duration(hours: 2));
  });

  test(
    'timezone non risolvibile usa fallback controllato e non schedulabile',
    () async {
      final service = NotificationTimezoneService(
        resolver: _FakeTimezoneResolver('Not/A-Timezone'),
      );

      expect(await service.initialize(), isFalse);
      expect(service.usingFallback, isTrue);
      expect(
        () => service.toLocalWallClock(DateTime(2026, 8, 30, 9)),
        throwsStateError,
      );
      expect(tz.local, tz.UTC);
    },
  );

  test(
    'refresh rileva cambio timezone senza persistere uno snapshot DB',
    () async {
      final resolver = _MutableTimezoneResolver('Europe/Rome');
      final service = NotificationTimezoneService(resolver: resolver);

      expect(await service.initialize(), isTrue);
      resolver.identifier = 'America/New_York';
      expect(await service.refreshIfChanged(), isTrue);
      expect(service.identifier, 'America/New_York');
      expect(service.toLocalWallClock(DateTime(2026, 1, 15, 8, 30)).hour, 8);
    },
  );
}
