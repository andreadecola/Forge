import '../../core/validation/onboarding_validators.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfile {
  SaveProfile(this._repository);

  final ProfileRepository _repository;

  Future<int> call(UserProfile profile) {
    final error =
        OnboardingValidators.name(profile.name) ??
        OnboardingValidators.birthDate(profile.birthDate) ??
        OnboardingValidators.heightCm(profile.heightCm) ??
        OnboardingValidators.weightKg(profile.initialWeightKg) ??
        OnboardingValidators.targetWeightKg(profile.targetWeightKg) ??
        OnboardingValidators.preferredWalkMinutes(
          profile.preferredWalkMinutes,
        ) ??
        OnboardingValidators.equipmentBudgetLimit(profile.equipmentBudgetLimit);
    if (error != null) throw ArgumentError(error);
    return _repository.saveProfile(profile);
  }
}
