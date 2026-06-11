import '../models/user_profile_model.dart';
import 'database_service.dart';

class ProfileService {
  Future<void> saveProfile(UserProfileModel profile) async {
    final db = await DatabaseService.instance.database;
    await db.insert('user_profiles', profile.toMap());
  }

  Future<UserProfileModel?> getProfile(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'user_profiles',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return UserProfileModel.fromMap(rows.first);
  }
}
