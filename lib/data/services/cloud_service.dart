import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudService {
  /// Giả lập việc lấy Presigned URL từ Backend, sau đó upload file lên AWS S3 / GCP Storage.
  /// Trong thực tế, Backend sẽ có API cấp Presigned URL để client tự upload file.
  Future<String> uploadFile(Uint8List fileBytes, String fileName) async {
    final bucketUrl = dotenv.env['CLOUD_STORAGE_URL'];
    if (bucketUrl == null || bucketUrl.isEmpty) {
      throw Exception('Thiếu cấu hình CLOUD_STORAGE_URL trong file .env');
    }

    try {
      // BƯỚC 1: (Giả lập) Lấy presigned URL từ Backend của bạn
      // final presignedResponse = await ApiClient().get('/upload-url?file=$fileName');
      // final uploadUrl = presignedResponse['url'];
      
      // Ở đây chúng ta giả sử bucketUrl là URL có thể PUT trực tiếp (hoặc presigned url)
      final url = Uri.parse('$bucketUrl/$fileName');

      // BƯỚC 2: Upload trực tiếp file lên Cloud Storage (AWS S3 / GCP) qua HTTP PUT
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/octet-stream',
        },
        body: fileBytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Trả về URL public của file sau khi upload thành công
        return '$bucketUrl/$fileName';
      } else {
        throw Exception('Lỗi upload Cloud API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối Cloud API: $e');
    }
  }
}
