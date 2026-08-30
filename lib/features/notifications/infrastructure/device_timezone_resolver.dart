import 'package:flutter_timezone/flutter_timezone.dart';

abstract interface class DeviceTimezoneResolver {
  Future<String> resolveIdentifier();
}

class FlutterDeviceTimezoneResolver implements DeviceTimezoneResolver {
  const FlutterDeviceTimezoneResolver();

  @override
  Future<String> resolveIdentifier() async {
    final timezone = await FlutterTimezone.getLocalTimezone();
    return timezone.identifier;
  }
}
