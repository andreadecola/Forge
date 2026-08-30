import 'package:drift/drift.dart';

import '../../core/constants/activity_level.dart';
import '../../domain/entities/biological_sex.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../database/app_database.dart';
import '../database/daos/user_profile_dao.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dao);

  final UserProfileDao _dao;

  @override
  Future<UserProfile?> getCurrentProfile() async {
    final row = await _dao.getCurrentProfile();
    return row == null ? null : _toEntity(row);
  }

  @override
  Stream<UserProfile?> watchCurrentProfile() {
    return _dao.watchCurrentProfile().map(
      (row) => row == null ? null : _toEntity(row),
    );
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    final rows = await _dao.getAllProfiles();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<int> saveProfile(UserProfile profile) async {
    final now = DateTime.now();
    if (profile.id == null) {
      return _dao.insertProfile(
        UserProfilesTableCompanion.insert(
          name: profile.name,
          birthDate: profile.birthDate,
          biologicalSexForFormula: Value(profile.biologicalSexForFormula?.name),
          heightCm: profile.heightCm,
          initialWeightKg: profile.initialWeightKg,
          targetWeightKg: Value(profile.targetWeightKg),
          preferredWalkMinutes: profile.preferredWalkMinutes,
          equipmentBudgetLimit: profile.equipmentBudgetLimit,
          startDate: profile.startDate,
          activityLevel: Value(profile.activityLevel.name),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    await _dao.updateProfile(
      UserProfilesTableCompanion(
        id: Value(profile.id!),
        name: Value(profile.name),
        birthDate: Value(profile.birthDate),
        biologicalSexForFormula: Value(profile.biologicalSexForFormula?.name),
        heightCm: Value(profile.heightCm),
        initialWeightKg: Value(profile.initialWeightKg),
        targetWeightKg: Value(profile.targetWeightKg),
        preferredWalkMinutes: Value(profile.preferredWalkMinutes),
        equipmentBudgetLimit: Value(profile.equipmentBudgetLimit),
        startDate: Value(profile.startDate),
        activityLevel: Value(profile.activityLevel.name),
        createdAt: Value(profile.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
    return profile.id!;
  }

  UserProfile _toEntity(UserProfilesTableData row) {
    return UserProfile(
      id: row.id,
      name: row.name,
      birthDate: row.birthDate,
      biologicalSexForFormula: row.biologicalSexForFormula == null
          ? null
          : BiologicalSexForFormula.values.byName(row.biologicalSexForFormula!),
      heightCm: row.heightCm,
      initialWeightKg: row.initialWeightKg,
      targetWeightKg: row.targetWeightKg,
      preferredWalkMinutes: row.preferredWalkMinutes,
      equipmentBudgetLimit: row.equipmentBudgetLimit,
      startDate: row.startDate,
      activityLevel: row.activityLevel == null
          ? ActivityFactors.defaultLevel
          : ActivityLevel.values.byName(row.activityLevel!),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
