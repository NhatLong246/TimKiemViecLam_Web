import '../models/job_post_model.dart';
import 'api_client.dart';

class JobPostService {
  final ApiClient _apiClient = ApiClient();

  Future<List<JobPostModel>> fetchJobPosts({int limit = 20}) async {
    try {
      final response = await _apiClient.get('/jobs?limit=$limit');
      if (response is List) {
        return response.map((data) {
          final mappedData = Map<String, dynamic>.from(data);
          mappedData['jobId'] = mappedData['jobId'] ?? mappedData['id'] ?? '';
          return JobPostModel.fromMap(mappedData);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách tin tuyển dụng: $e');
    }
  }

  Future<List<JobPostModel>> fetchJobPostsByEmployer(String employerId, {int limit = 50}) async {
    try {
      final response = await _apiClient.get('/jobs?employerId=$employerId&limit=$limit');
      if (response is List) {
        final jobs = response.map((data) {
          final mappedData = Map<String, dynamic>.from(data);
          mappedData['jobId'] = mappedData['jobId'] ?? mappedData['id'] ?? '';
          return JobPostModel.fromMap(mappedData);
        }).toList();
        
        jobs.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        return jobs;
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách tin tuyển dụng của nhà tuyển dụng: $e');
    }
  }

  Future<void> updateJobStatus(
    String jobId, {
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status,
      };
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        data['rejectionReason'] = rejectionReason;
      }

      await _apiClient.patch('/jobs/$jobId/status', body: data);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái tin tuyển dụng: $e');
    }
  }

  Future<void> deleteJobPost(String jobId) async {
    try {
      await _apiClient.delete('/jobs/$jobId');
    } catch (e) {
      throw Exception('Lỗi khi xóa tin tuyển dụng: $e');
    }
  }
}
