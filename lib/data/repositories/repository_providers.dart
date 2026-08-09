import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/body_metrics_repository.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/pressure_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../database/database_provider.dart';
import 'body_metrics_repository_impl.dart';
import 'equipment_repository_impl.dart';
import 'pressure_repository_impl.dart';
import 'profile_repository_impl.dart';
import 'settings_repository_impl.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(databaseProvider).userProfileDao);
});

final bodyMetricsRepositoryProvider = Provider<BodyMetricsRepository>((ref) {
  return BodyMetricsRepositoryImpl(
    ref.watch(databaseProvider).bodyMeasurementsDao,
  );
});

final pressureRepositoryProvider = Provider<PressureRepository>((ref) {
  return PressureRepositoryImpl(
    ref.watch(databaseProvider).pressureMeasurementsDao,
  );
});

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepositoryImpl(ref.watch(databaseProvider).userEquipmentDao);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(databaseProvider).appSettingsDao);
});

/// Profilo corrente condiviso da tutte le feature (nessun multi-profilo in v1).
final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(profileRepositoryProvider).watchCurrentProfile();
});

/// Stato di completamento onboarding, usato anche dal redirect di go_router.
final onboardingCompletedProvider = StreamProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).watchOnboardingCompleted();
});
