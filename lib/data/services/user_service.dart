import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<List<UserModel>> fetchUsers({int limit = 100}) async {
    try {
      final response = await _apiClient.get('/users?limit=$limit');
      if (response is List) {
        return response.map((data) => UserModel.fromMap(data, data['uid'] ?? '')).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách người dùng: $e');
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final response = await _apiClient.get('/users/$uid');
      if (response != null) {
        return UserModel.fromMap(response, response['uid'] ?? uid);
      }
      return null;
    } catch (e) {
      // Bỏ qua lỗi 404
      return null;
    }
  }

  Future<List<UserModel>> fetchEmployers({int limit = 100}) async {
    try {
      final response = await _apiClient.get('/users?role=employer&limit=$limit');
      if (response is List) {
        return response.map((data) => UserModel.fromMap(data, data['uid'] ?? '')).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách nhà tuyển dụng: $e');
    }
  }

  Future<List<UserModel>> fetchCandidates({int limit = 100}) async {
    try {
      final response = await _apiClient.get('/users?role=candidate&limit=$limit');
      if (response is List) {
        return response.map((data) => UserModel.fromMap(data, data['uid'] ?? '')).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách ứng viên: $e');
    }
  }

  Future<void> updateUserStatus(String uid, bool isActive) async {
    try {
      await _apiClient.patch('/users/$uid/status', body: {
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái người dùng: $e');
    }
  }

  Future<void> updateUserVerification(String uid, bool isVerified) async {
    try {
      await _apiClient.patch('/users/$uid/verification', body: {
        'isVerified': isVerified,
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái xác thực: $e');
    }
  }
}
