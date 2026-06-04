import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    String? relatedId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type ?? 'system',
        'relatedId': relatedId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Lỗi khi gửi thông báo: $e');
      throw Exception('Không thể gửi thông báo: $e');
    }
  }
}
