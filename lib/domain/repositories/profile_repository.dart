import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getCurrentProfile();

  Stream<UserProfile?> watchCurrentProfile();

  /// Crea il profilo se non esiste ancora un id, altrimenti lo aggiorna.
  /// Ritorna l'id del profilo salvato.
  Future<int> saveProfile(UserProfile profile);
}
