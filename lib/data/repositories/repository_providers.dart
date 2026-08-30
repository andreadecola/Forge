import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/body_metrics_repository.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/planned_activity_repository.dart';
import '../../domain/repositories/pressure_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../database/database_provider.dart';
import 'body_metrics_repository_impl.dart';
import 'drift_planned_activity_repository.dart';
import 'equipment_repository_impl.dart';
import 'pressure_repository_impl.dart';
import 'profile_repository_impl.dart';
import 'settings_repository_impl.dart';
import 'weekly_plan_generation_repository.dart';

// Nota: `clockProvider` (Clock/SystemClock condivisi) resta in
// `forge_providers.dart` (Milestone 5.3) — già riusato da fuori Forge
// (`features/walking/...`, Milestone 6). Il modulo Progressi (Milestone
// 7.1) lo importa da lì con lo stesso pattern, invece di duplicarlo qui.

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

/// Fondamenta del Piano Settimanale (Milestone 8.1).
final plannedActivityRepositoryProvider = Provider<PlannedActivityRepository>((
  ref,
) {
  return DriftPlannedActivityRepository(
    ref.watch(databaseProvider).attivitaPianificateDao,
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(databaseProvider).appSettingsDao);
});

/// Conferma atomica della generazione automatica settimanale (Milestone
/// 8.4): richiede `AppDatabase` diretto (non solo l'interfaccia
/// repository) per aprire un'unica transazione su Workout+PlannedActivity
/// insieme — per questo vive qui e non in `weeklyPlanGenerationServiceProvider`
/// (quello resta puro use-case/repository, nessun accesso Drift diretto).
final weeklyPlanGenerationRepositoryProvider =
    Provider<WeeklyPlanGenerationRepository>((ref) {
      return WeeklyPlanGenerationRepository(ref.watch(databaseProvider));
    });

/// Profilo corrente condiviso da tutte le feature (nessun multi-profilo in v1).
final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(profileRepositoryProvider).watchCurrentProfile();
});

/// Stato di completamento onboarding, usato anche dal redirect di go_router.
final onboardingCompletedProvider = StreamProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).watchOnboardingCompleted();
});
