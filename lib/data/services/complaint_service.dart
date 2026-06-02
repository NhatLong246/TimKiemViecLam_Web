import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ComplaintModel>> fetchComplaints({int limit = 20}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _db
            .collection('jobComplaints')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } on FirebaseException {
        // Fallback without ordering if index is missing
        snapshot = await _db.collection('jobComplaints').limit(limit).get();
      }

      final complaints = <ComplaintModel>[];
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final complaint = ComplaintModel.fromMap(data, doc.id);

        // Fetch additional info (Employer Name & Candidate Name)
        try {
          if (complaint.employerId.isNotEmpty) {
            final empDoc = await _db.collection('users').doc(complaint.employerId).get();
            if (empDoc.exists) {
              final userData = empDoc.data();
              final companyName = userData?['companyName'] as String?;
              if (companyName != null && companyName.isNotEmpty) {
                complaint.employerName = companyName;
              } else {
                final firstName = userData?['firstName'] as String? ?? '';
                final lastName = userData?['lastName'] as String? ?? '';
                complaint.employerName = '$firstName $lastName'.trim();
              }
            }
          }
          if (complaint.candidateId.isNotEmpty) {
            final candDoc = await _db.collection('users').doc(complaint.candidateId).get();
            if (candDoc.exists) {
              final userData = candDoc.data();
              final firstName = userData?['firstName'] as String? ?? '';
              final lastName = userData?['lastName'] as String? ?? '';
              complaint.candidateName = '$firstName $lastName'.trim();
            }
          }
        } catch (_) {
          // Ignore errors
        }

        complaints.add(complaint);
      }
      return complaints;
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> updateComplaintStatus(
    String complaintId, {
    required String status,
    String? resolution,
    String? resolvedBy,
  }) async {
    try {
      final docRef = _db.collection('jobComplaints').doc(complaintId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('Khiếu nại không tồn tại');
      }

      final data = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (resolution != null && resolution.isNotEmpty) {
        data['resolution'] = resolution;
      }
      if (resolvedBy != null && resolvedBy.isNotEmpty) {
        data['resolvedBy'] = resolvedBy;
      }

      await docRef.update(data);
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
