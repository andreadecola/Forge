import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/notifications/application/notification_ids.dart';

void main() {
  test('stesso namespace e id producono sempre lo stesso valore', () {
    expect(
      NotificationIdGenerator.forEntity(namespace: 'walk', entityId: 7),
      NotificationIdGenerator.forEntity(namespace: 'walk', entityId: 7),
    );
  });

  test(
    'namespace e entity differenti hanno identificatori distinti nel caso nominale',
    () {
      final walk = NotificationIdGenerator.forEntity(
        namespace: 'walk',
        entityId: 7,
      );
      final workout = NotificationIdGenerator.forEntity(
        namespace: 'workout',
        entityId: 7,
      );
      final otherWalk = NotificationIdGenerator.forEntity(
        namespace: 'walk',
        entityId: 8,
      );

      expect(workout, isNot(walk));
      expect(otherWalk, isNot(walk));
    },
  );

  test('id è sempre positivo e rappresentabile da Android', () {
    final id = NotificationIdGenerator.forEntity(
      namespace: 'planned_activity',
      entityId: 999999,
    );

    expect(id, greaterThan(0));
    expect(id, lessThanOrEqualTo(0x7fffffff));
  });

  test('namespace vuoto e entity non valido sono rifiutati', () {
    expect(
      () => NotificationIdGenerator.forEntity(namespace: '', entityId: 1),
      throwsArgumentError,
    );
    expect(
      () => NotificationIdGenerator.forEntity(namespace: 'walk', entityId: 0),
      throwsArgumentError,
    );
  });
}
