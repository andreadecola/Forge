class NotificationIdGenerator {
  const NotificationIdGenerator._();

  /// Generates a stable positive Android notification id.
  ///
  /// FNV-1a is used instead of Dart's [String.hashCode], whose value is not
  /// a persistence contract across runtimes.
  static int forEntity({required String namespace, required int entityId}) {
    if (namespace.trim().isEmpty) {
      throw ArgumentError.value(namespace, 'namespace');
    }
    if (entityId <= 0) {
      throw ArgumentError.value(entityId, 'entityId');
    }

    var hash = 0x811c9dc5;
    final value = '$namespace:$entityId';
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }

    final id = hash & 0x7fffffff;
    return id == 0 ? 1 : id;
  }
}
