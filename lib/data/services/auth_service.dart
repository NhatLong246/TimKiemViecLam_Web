import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static const _key = "is_logged_in";
  final ApiClient _apiClient = ApiClient();

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', body: {
        'username': username,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        // Lưu JWT token
        await _apiClient.saveToken(response['token']);
        
        // Cập nhật trạng thái đăng nhập
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_key, true);
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}
