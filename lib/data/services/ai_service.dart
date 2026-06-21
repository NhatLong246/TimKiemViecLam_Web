import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  Future<String> generateJobSummary(String jobDescription) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Thiếu cấu hình GEMINI_API_KEY trong file .env');
    }

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Hãy tóm tắt ngắn gọn yêu cầu công việc sau đây trong 3 gạch đầu dòng:\n$jobDescription"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String;
          }
        }
        return 'Không thể tạo tóm tắt.';
      } else {
        throw Exception('Lỗi từ Gemini API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối AI API: $e');
    }
  }
}
