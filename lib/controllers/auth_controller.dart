import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _service = AuthService();
  UserModel? currentUser;

  Future<String?> register(String email, String password) async {
    try {
      currentUser = await _service.register(email, password);
      return null;
    } catch (_) {
      return 'Cet email existe déjà';
    }
  }

  Future<String?> login(String email, String password) async {
    currentUser = await _service.login(email, password);
    if (currentUser == null) {
      return 'Email ou mot de passe incorrect';
    }
    return null;
  }

  void logout() {
    currentUser = null;
  }
}
