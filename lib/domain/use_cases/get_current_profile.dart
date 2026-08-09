import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetCurrentProfile {
  GetCurrentProfile(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile?> call() => _repository.getCurrentProfile();
}
