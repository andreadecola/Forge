import 'dart:convert';

class NotificationPayload {
  const NotificationPayload({
    required this.type,
    required this.entityId,
    this.version = 1,
  });

  final int version;
  final String type;
  final int entityId;
}

class NotificationPayloadCodec {
  const NotificationPayloadCodec._();

  static String encode(NotificationPayload payload) {
    if (payload.version != 1 ||
        payload.type.trim().isEmpty ||
        payload.entityId <= 0) {
      throw ArgumentError('Invalid notification payload.');
    }

    return jsonEncode(<String, Object>{
      'v': payload.version,
      'type': payload.type,
      'entityId': payload.entityId,
    });
  }

  static NotificationPayload? tryDecode(String? rawPayload) {
    if (rawPayload == null || rawPayload.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final version = decoded['v'];
      final type = decoded['type'];
      final entityId = decoded['entityId'];
      if (version != 1 || type is! String || type.trim().isEmpty) {
        return null;
      }
      if (entityId is! int || entityId <= 0) {
        return null;
      }

      return NotificationPayload(
        version: version,
        type: type,
        entityId: entityId,
      );
    } on Object {
      return null;
    }
  }
}
