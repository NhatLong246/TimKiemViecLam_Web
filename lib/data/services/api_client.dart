import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://encrust-dramatize-nurture.ngrok-free.dev/api';
  static const String _tokenKey = 'jwt_token';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Bỏ qua trang cảnh báo của Ngrok
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _handleError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    
    String message = 'Đã xảy ra lỗi không xác định (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body['message'] != null) {
        message = body['message'];
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 401:
        throw Exception('Lỗi xác thực: $message');
      case 403:
        throw Exception('Không có quyền truy cập: $message');
      case 404:
        throw Exception('Không tìm thấy tài nguyên: $message');
      case 500:
        throw Exception('Lỗi máy chủ nội bộ: $message');
      default:
        throw Exception(message);
    }
  }

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(uri, headers: await _getHeaders());
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        uri,
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.patch(
        uri,
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(uri, headers: await _getHeaders());
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
