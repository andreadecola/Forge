import '../../../domain/entities/equipment_item.dart';

/// Scelta del parametro sesso in onboarding. A differenza di
/// [BiologicalSexForFormula] (dominio, persistito), include l'opzione
/// "preferisco non specificarlo", che si traduce in un valore assente.
enum OnboardingSexChoice { male, female, preferNotToSay }

/// Durate di camminata preimpostate proposte in onboarding.
const List<int> presetWalkMinutes = [30, 40, 50, 60];

const double defaultEquipmentBudgetLimit = 50;

class OnboardingDraft {
  const OnboardingDraft({
    this.name = '',
    this.birthDate,
    this.heightCm,
    this.initialWeightKg,
    this.targetWeightKg,
    this.sexChoice,
    this.preferredWalkMinutes = 30,
    this.ownedEquipment = EquipmentItem.defaultOwned,
    this.equipmentBudgetLimit = defaultEquipmentBudgetLimit,
  });

  final String name;
  final DateTime? birthDate;
  final double? heightCm;
  final double? initialWeightKg;
  final double? targetWeightKg;
  final OnboardingSexChoice? sexChoice;
  final int preferredWalkMinutes;
  final Set<EquipmentItem> ownedEquipment;
  final double equipmentBudgetLimit;

  bool get isIdentityStepValid => name.trim().isNotEmpty && birthDate != null;

  bool get isBodyStepValid =>
      heightCm != null &&
      heightCm! > 0 &&
      initialWeightKg != null &&
      initialWeightKg! > 0;

  OnboardingDraft copyWith({
    String? name,
    DateTime? birthDate,
    double? heightCm,
    double? initialWeightKg,
    double? Function()? targetWeightKg,
    OnboardingSexChoice? Function()? sexChoice,
    int? preferredWalkMinutes,
    Set<EquipmentItem>? ownedEquipment,
    double? equipmentBudgetLimit,
  }) {
    return OnboardingDraft(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      targetWeightKg: targetWeightKg != null
          ? targetWeightKg()
          : this.targetWeightKg,
      sexChoice: sexChoice != null ? sexChoice() : this.sexChoice,
      preferredWalkMinutes: preferredWalkMinutes ?? this.preferredWalkMinutes,
      ownedEquipment: ownedEquipment ?? this.ownedEquipment,
      equipmentBudgetLimit: equipmentBudgetLimit ?? this.equipmentBudgetLimit,
    );
  }
}
