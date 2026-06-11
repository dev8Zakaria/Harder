import '../models/user_profile_model.dart';
import '../services/profile_service.dart';

class ProfileController {
  final ProfileService _service = ProfileService();

  Future<void> save(UserProfileModel profile) {
    return _service.saveProfile(profile);
  }

  Future<UserProfileModel?> getProfile(int userId) {
    return _service.getProfile(userId);
  }
}
