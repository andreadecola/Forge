import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/forge_theme.dart';
import 'data/repositories/repository_providers.dart';
import 'features/notifications/application/notification_constants.dart';
import 'features/notifications/application/notification_lifecycle_coordinator.dart';
import 'features/notifications/application/notification_providers.dart';
import 'features/notifications/domain/notification_tap_event.dart';

class ForgeApp extends ConsumerStatefulWidget {
  const ForgeApp({super.key});

  @override
  ConsumerState<ForgeApp> createState() => _ForgeAppState();
}

class _ForgeAppState extends ConsumerState<ForgeApp>
    with WidgetsBindingObserver {
  late final NotificationLifecycleCoordinator _lifecycleCoordinator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycleCoordinator = ref.read(notificationLifecycleCoordinatorProvider);
    ref.read(notificationTapCoordinatorProvider).start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleCoordinator.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(notificationLifecycleCoordinatorProvider).onResumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(notificationTapCoordinatorProvider)
          .setHandler((event) => _handleNotificationTap(router, event));
    });
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ForgeTheme.dark,
      themeMode: ThemeMode.dark,
      locale: const Locale('it'),
      supportedLocales: const [Locale('it')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }

  Future<void> _handleNotificationTap(
    GoRouter router,
    NotificationTapEvent event,
  ) async {
    final payload = event.payload;
    if (payload?.type != NotificationPayloadTypes.plannedActivity) {
      router.go(AppRoutes.dashboard);
      return;
    }

    final profile = await ref
        .read(profileRepositoryProvider)
        .getCurrentProfile();
    final activity = await ref
        .read(plannedActivityRepositoryProvider)
        .getById(payload!.entityId);
    if (profile?.id == activity?.profileId) {
      router.go(AppRoutes.weeklyPlan);
    } else {
      router.go(AppRoutes.dashboard);
    }
  }
}
