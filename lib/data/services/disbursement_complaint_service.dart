import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/disbursement_complaint_model.dart';

class DisbursementComplaintService {
  final FirebaseFirestore _db;

  DisbursementComplaintService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Future<List<DisbursementComplaintModel>> fetchComplaints({
    int limit = 20,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _db
            .collection('disbursementNotices')
            .where(
              'status',
              whereIn: ['complaints_pending', 'complaints_reviewed'],
            )
            .limit(limit)
            .get();
      } on FirebaseException {
        snapshot = await _db
            .collection('disbursementNotices')
            .limit(limit)
            .get();
      }

      final complaints = <DisbursementComplaintModel>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        if (status != 'complaints_pending' && status != 'complaints_reviewed') {
          continue;
        }
        complaints.addAll(
          DisbursementComplaintModel.fromNotice(noticeId: doc.id, data: data),
        );
      }

      final nameCache = <String, String>{};
      for (final complaint in complaints) {
        complaint.employerName = await _userDisplayName(
          complaint.employerId,
          nameCache,
        );
        complaint.candidateName = await _userDisplayName(
          complaint.candidateId,
          nameCache,
        );
      }
      complaints.sort(
        (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
          a.createdAt ?? DateTime(1970),
        ),
      );
      return complaints;
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Không thể tải khiếu nại giải ngân: $e');
    }
  }

  Future<void> resolveComplaint({
    required String noticeId,
    required String candidateId,
    required String decision,
    required double finalCompensation,
    required String note,
  }) async {
    if (decision != 'approved' && decision != 'rejected') {
      throw Exception('Quyết định không hợp lệ');
    }
    if (finalCompensation < 0) {
      throw Exception('Số tiền đền bù không được âm');
    }

    final noticeRef = _db.collection('disbursementNotices').doc(noticeId);
    String employerId = '';
    String jobTitle = '';

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(noticeRef);
      if (!snapshot.exists) {
        throw Exception('Yêu cầu giải ngân không tồn tại');
      }
      final data = snapshot.data()!;
      final complained =
          (data['complainedCandidates'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [];
      if (!complained.contains(candidateId)) {
        throw Exception('Ứng viên không nằm trong danh sách khiếu nại');
      }

      final results = Map<String, dynamic>.from(
        data['complaintResults'] as Map? ?? {},
      );
      if (results.containsKey(candidateId)) {
        throw Exception('Khiếu nại này đã được xử lý');
      }

      final finalDeductions = Map<String, dynamic>.from(
        data['adminFinalDeductions'] as Map? ?? {},
      );
      final adminNotes = Map<String, dynamic>.from(
        data['adminNotes'] as Map? ?? {},
      );
      results[candidateId] = decision;
      finalDeductions[candidateId] = decision == 'approved'
          ? finalCompensation
          : 0;
      adminNotes[candidateId] = note;

      final allReviewed =
          complained.isNotEmpty && complained.every(results.containsKey);
      transaction.update(noticeRef, {
        'complaintResults': results,
        'adminFinalDeductions': finalDeductions,
        'adminNotes': adminNotes,
        'adminNote': note,
        if (allReviewed) 'status': 'complaints_reviewed',
        if (allReviewed) 'complaintsReviewedAt': FieldValue.serverTimestamp(),
      });

      employerId = data['employerId'] as String? ?? '';
      jobTitle = data['jobTitle'] as String? ?? '';
    });

    if (employerId.isNotEmpty) {
      try {
        await _db.collection('notifications').add({
          'recipientId': employerId,
          'userId': employerId,
          'type': decision == 'approved'
              ? 'complaint_approved'
              : 'complaint_rejected',
          'title': decision == 'approved'
              ? 'Khiếu nại được duyệt'
              : 'Khiếu nại bị từ chối',
          'body': decision == 'approved'
              ? 'Admin đã duyệt khiếu nại cho "$jobTitle". Mức đền bù: ${finalCompensation.toStringAsFixed(0)}đ.'
              : 'Admin đã từ chối khiếu nại cho "$jobTitle". $note',
          'data': {'noticeId': noticeId, 'candidateId': candidateId},
          'relatedId': noticeId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // Quyết định đã lưu; lỗi notification không được ghi đè quyết định.
      }
    }
  }

  Future<String> _userDisplayName(
    String userId,
    Map<String, String> cache,
  ) async {
    if (userId.isEmpty) return '';
    if (cache.containsKey(userId)) return cache[userId]!;
    try {
      final snapshot = await _db.collection('users').doc(userId).get();
      final data = snapshot.data();
      final company = data?['companyName'] as String? ?? '';
      final firstName = data?['firstName'] as String? ?? '';
      final lastName = data?['lastName'] as String? ?? '';
      final name = company.isNotEmpty
          ? company
          : '$firstName $lastName'.trim().isNotEmpty
          ? '$firstName $lastName'.trim()
          : userId;
      cache[userId] = name;
      return name;
    } catch (_) {
      return userId;
    }
  }
}
