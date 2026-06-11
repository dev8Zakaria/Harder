import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  Future<UserModel> register(String email, String password) async {
    final db = await DatabaseService.instance.database;
    final normalizedEmail = email.trim().toLowerCase();
    final id = await db.insert('users', {
      'email': normalizedEmail,
      'password': password,
    });
    return UserModel(id: id, email: normalizedEmail, password: password);
  }

  Future<UserModel?> login(String email, String password) async {
    final db = await DatabaseService.instance.database;
    final normalizedEmail = email.trim().toLowerCase();
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return UserModel.fromMap(rows.first);
  }
}
