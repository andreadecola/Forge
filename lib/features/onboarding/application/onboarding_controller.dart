import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/biological_sex.dart';
import '../../../domain/entities/body_measurement.dart';
import '../../../domain/entities/equipment_item.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/use_cases/save_profile.dart';
import 'onboarding_state.dart';

class OnboardingController extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void updateIdentity({required String name, required DateTime birthDate}) {
    state = state.copyWith(name: name, birthDate: birthDate);
  }

  void updateBodyData({
    required double heightCm,
    required double initialWeightKg,
    double? targetWeightKg,
  }) {
    state = state.copyWith(
      heightCm: heightCm,
      initialWeightKg: initialWeightKg,
      targetWeightKg: () => targetWeightKg,
    );
  }

  void updateSexChoice(OnboardingSexChoice? choice) {
    state = state.copyWith(sexChoice: () => choice);
  }

  void updatePreferredWalkMinutes(int minutes) {
    state = state.copyWith(preferredWalkMinutes: minutes);
  }

  void updateEquipment(Set<EquipmentItem> owned) {
    state = state.copyWith(ownedEquipment: owned);
  }

  void updateBudget(double budget) {
    state = state.copyWith(equipmentBudgetLimit: budget);
  }

  /// Salva profilo, prima misura, attrezzatura iniziale e completa l'onboarding.
  Future<void> completeOnboarding() async {
    final draft = state;
    final now = DateTime.now();

    final biologicalSex = switch (draft.sexChoice) {
      OnboardingSexChoice.male => BiologicalSexForFormula.male,
      OnboardingSexChoice.female => BiologicalSexForFormula.female,
      OnboardingSexChoice.preferNotToSay || null => null,
    };

    final profile = UserProfile(
      name: draft.name.trim(),
      birthDate: draft.birthDate!,
      biologicalSexForFormula: biologicalSex,
      heightCm: draft.heightCm!,
      initialWeightKg: draft.initialWeightKg!,
      targetWeightKg: draft.targetWeightKg,
      preferredWalkMinutes: draft.preferredWalkMinutes,
      equipmentBudgetLimit: draft.equipmentBudgetLimit,
      startDate: now,
    );

    final profileId = await SaveProfile(ref.read(profileRepositoryProvider))(
      profile,
    );

    await ref
        .read(bodyMetricsRepositoryProvider)
        .addMeasurement(
          BodyMeasurement(
            profileId: profileId,
            measuredAt: now,
            weightKg: draft.initialWeightKg!,
          ),
        );

    await ref
        .read(equipmentRepositoryProvider)
        .saveInitialEquipment(
          profileId: profileId,
          owned: draft.ownedEquipment,
        );

    await ref.read(settingsRepositoryProvider).setOnboardingCompleted(true);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingDraft>(
      OnboardingController.new,
    );
