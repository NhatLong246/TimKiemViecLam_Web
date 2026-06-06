import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/disbursement_model.dart';

class DisbursementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<DisbursementModel>> fetchDisbursements({int limit = 20}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _db
            .collection('disbursementNotices')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } on FirebaseException {
        // Fallback without ordering if index is missing
        snapshot =
            await _db.collection('disbursementNotices').limit(limit).get();
      }

      final notices = <DisbursementModel>[];
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final notice = DisbursementModel.fromMap(data, doc.id);
        
        // Fetch additional info
        try {
          // Fetch job title
          if (notice.jobId.isNotEmpty) {
            final jobDoc = await _db.collection('jobPosts').doc(notice.jobId).get();
            if (jobDoc.exists) {
              notice.jobTitle = jobDoc.data()?['title'] as String?;
            }
          }
          // Fetch employer name
          if (notice.employerId.isNotEmpty) {
            final userDoc = await _db.collection('users').doc(notice.employerId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              final companyName = userData?['companyName'] as String?;
              if (companyName != null && companyName.isNotEmpty) {
                notice.employerName = companyName;
              } else {
                final firstName = userData?['firstName'] as String? ?? '';
                final lastName = userData?['lastName'] as String? ?? '';
                notice.employerName = '$firstName $lastName'.trim();
              }
            }
          }
        } catch (_) {
          // Ignore errors fetching joined data
        }

        notices.add(notice);
      }
      return notices;
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<double> fetchFullTimeCommission() async {
    try {
      final snapshot = await _db
          .collection('walletTransactions')
          .where('type', isEqualTo: 'full_time_referral_fee')
          .get();

      double totalCommission = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'completed') {
          final amount = (data['amount'] ?? 0) as num;
          totalCommission += amount.toDouble();
        }
      }
      return totalCommission;
    } catch (e) {
      return 0; // Return 0 if collection is missing or any other error
    }
  }

  Future<void> updateDisbursementStatus(
    String noticeId, {
    required bool adminAck,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final docRef = _db.collection('disbursementNotices').doc(noticeId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('Yêu cầu giải ngân không tồn tại');
      }

      final data = <String, dynamic>{
        'adminAck': adminAck,
        'status': status,
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
