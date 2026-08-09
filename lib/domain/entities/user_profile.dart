import '../../core/constants/activity_level.dart';
import 'biological_sex.dart';

class UserProfile {
  const UserProfile({
    this.id,
    required this.name,
    required this.birthDate,
    this.biologicalSexForFormula,
    required this.heightCm,
    required this.initialWeightKg,
    this.targetWeightKg,
    required this.preferredWalkMinutes,
    required this.equipmentBudgetLimit,
    required this.startDate,
    this.activityLevel = ActivityFactors.defaultLevel,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String name;
  final DateTime birthDate;
  final BiologicalSexForFormula? biologicalSexForFormula;
  final double heightCm;
  final double initialWeightKg;
  final double? targetWeightKg;
  final int preferredWalkMinutes;
  final double equipmentBudgetLimit;
  final DateTime startDate;
  final ActivityLevel activityLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    BiologicalSexForFormula? Function()? biologicalSexForFormula,
    double? heightCm,
    double? initialWeightKg,
    double? Function()? targetWeightKg,
    int? preferredWalkMinutes,
    double? equipmentBudgetLimit,
    DateTime? startDate,
    ActivityLevel? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      biologicalSexForFormula: biologicalSexForFormula != null
          ? biologicalSexForFormula()
          : this.biologicalSexForFormula,
      heightCm: heightCm ?? this.heightCm,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      targetWeightKg: targetWeightKg != null
          ? targetWeightKg()
          : this.targetWeightKg,
      preferredWalkMinutes: preferredWalkMinutes ?? this.preferredWalkMinutes,
      equipmentBudgetLimit: equipmentBudgetLimit ?? this.equipmentBudgetLimit,
      startDate: startDate ?? this.startDate,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
