import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/features/notifications/application/notification_providers.dart';
import 'package:forge/features/notifications/application/notification_tap_event_bus.dart';
import 'package:forge/features/notifications/domain/notification_payload.dart';
import 'package:forge/features/notifications/domain/notification_tap_event.dart';

AppDatabase _memoryDatabase() => AppDatabase(NativeDatabase.memory());

/// Smonta l'albero widget mentre siamo ancora nel corpo del test, in modo
/// che i timer di cleanup dello stream Drift (avviato da [currentProfileProvider])
/// possano essere scaricati con un pump esplicito prima della verifica finale
/// di flutter_test, che altrimenti fallisce con "Timer is still pending".
Future<void> _disposeCleanly(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

Future<void> _completeOnboardingWith(AppDatabase database) async {
  await ProfileRepositoryImpl(database.userProfileDao).saveProfile(
    UserProfile(
      name: 'Alex',
      birthDate: DateTime(1990, 1, 1),
      heightCm: 175,
      initialWeightKg: 80,
      preferredWalkMinutes: 30,
      equipmentBudgetLimit: 50,
      startDate: DateTime(2026, 1, 1),
    ),
  );
  await SettingsRepositoryImpl(
    database.appSettingsDao,
  ).setOnboardingCompleted(true);
}

void main() {
  testWidgets('Fresh install redirects to onboarding', (tester) async {
    final database = _memoryDatabase();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Configura Forge'), findsOneWidget);
    expect(find.text('Ripristina da backup'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Completed onboarding shows dashboard with bottom navigation', (
    tester,
  ) async {
    final database = _memoryDatabase();
    addTearDown(database.close);
    await _completeOnboardingWith(database);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ciao, Alex'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Programma'), findsOneWidget);
    expect(find.text('Progressi'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('Tapping a destination navigates to the matching page', (
    tester,
  ) async {
    final database = _memoryDatabase();
    addTearDown(database.close);
    await _completeOnboardingWith(database);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Programma'));
    await tester.pumpAndSettle();

    expect(find.text('I tuoi allenamenti'), findsOneWidget);
    expect(find.text('Non hai ancora creato allenamenti.'), findsOneWidget);

    await _disposeCleanly(tester);
  });

  testWidgets('Notification tap apre il Piano dentro la shell principale', (
    tester,
  ) async {
    final database = _memoryDatabase();
    addTearDown(database.close);
    await _completeOnboardingWith(database);

    final activityId =
        await DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        ).addPlannedActivity(
          PlannedActivity(
            profileId: 1,
            scheduledDate: DateTime(2026, 9, 2),
            type: PlannedActivityType.walk,
            plannedDurationMinutes: 30,
            origin: PlannedActivityOrigin.user,
          ),
        );
    final tapBus = NotificationTapEventBus();
    addTearDown(tapBus.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          notificationTapEventBusProvider.overrideWithValue(tapBus),
        ],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();

    tapBus.emit(
      NotificationTapEvent(
        rawPayload: NotificationPayloadCodec.encode(
          NotificationPayload(type: 'planned_activity', entityId: activityId),
        ),
        payload: NotificationPayload(
          type: 'planned_activity',
          entityId: activityId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Piano settimanale'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Programma'), findsOneWidget);
    expect(find.text('Progressi'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Ciao, Alex'), findsOneWidget);

    await _disposeCleanly(tester);
  });
}
