import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_profiles_table.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfilesTable])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  Future<int> insertProfile(UserProfilesTableCompanion profile) =>
      into(userProfilesTable).insert(profile);

  Future<bool> updateProfile(UserProfilesTableCompanion profile) =>
      update(userProfilesTable).replace(profile);

  Future<int> deleteProfile(int id) =>
      (delete(userProfilesTable)..where((t) => t.id.equals(id))).go();

  Future<UserProfilesTableData?> getById(int id) => (select(
    userProfilesTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Il prodotto non prevede ancora multi-profilo: ritorna l'unico profilo
  /// presente (il più recente per id), se esiste.
  Future<UserProfilesTableData?> getCurrentProfile() {
    return (select(userProfilesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<UserProfilesTableData?> watchCurrentProfile() {
    return (select(userProfilesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .watchSingleOrNull();
  }
}
