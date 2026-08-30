import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getCurrentProfile();

  Stream<UserProfile?> watchCurrentProfile();

  /// Tutti i profili presenti nel database, in ordine di creazione. Usato
  /// dall'export di backup (Backup.2), che non deve presumere un
  /// singleton anche se il prodotto non espone ancora una UI
  /// multi-profilo.
  Future<List<UserProfile>> getAllProfiles();

  /// Crea il profilo se non esiste ancora un id, altrimenti lo aggiorna.
  /// Ritorna l'id del profilo salvato.
  Future<int> saveProfile(UserProfile profile);
}
