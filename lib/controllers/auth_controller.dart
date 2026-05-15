import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();
  bool _isLoggedIn = false;
  bool _initialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get initialized => _initialized;

  AuthController() {
    checkLogin();
  }

  Future<void> checkLogin() async {
    _isLoggedIn = await _service.isLoggedIn();
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final success = await _service.login(username, password);
    _isLoggedIn = success;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _service.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
