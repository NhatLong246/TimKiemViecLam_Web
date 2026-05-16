import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/job_post_model.dart';

class JobPostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<JobPostModel>> fetchJobPosts({int limit = 20}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _db
            .collection('jobPosts')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } on FirebaseException {
        snapshot = await _db.collection('jobPosts').limit(limit).get();
      }

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['jobId'] = data['jobId'] as String? ?? doc.id;
        return JobPostModel.fromMap(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> updateJobStatus(
    String jobId, {
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final docRef = _db.collection('jobPosts').doc(jobId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('Tin tuyển dụng không tồn tại');
      }

      final data = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        data['rejectionReason'] = rejectionReason;
      }

      await docRef.update(data);
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
