import 'package:flutter_test/flutter_test.dart';
import 'package:web_viecnow/data/models/disbursement_complaint_model.dart';

void main() {
  group('DisbursementComplaintModel.fromNotice', () {
    test('creates one complaint per complained candidate', () {
      final complaints = DisbursementComplaintModel.fromNotice(
        noticeId: 'notice-1',
        data: {
          'jobId': 'job-1',
          'groupId': 'group-1',
          'employerId': 'employer-1',
          'jobTitle': 'Phuc vu su kien',
          'status': 'complaints_pending',
          'candidateAmounts': {'candidate-1': 500000},
          'complainedCandidates': ['candidate-1'],
          'complaintReasons': {'candidate-1': 'Khong hoan thanh cong viec'},
          'complaintEvidence': {
            'candidate-1': ['https://example.com/evidence.jpg'],
          },
          'deductions': {'candidate-1': 700000},
          'complaintResults': <String, String>{},
          'adminFinalDeductions': <String, double>{},
        },
      );

      expect(complaints, hasLength(1));
      expect(complaints.single.noticeId, 'notice-1');
      expect(complaints.single.candidateId, 'candidate-1');
      expect(complaints.single.proposedCompensation, 700000);
      expect(complaints.single.candidateWage, 500000);
      expect(complaints.single.status, 'pending');
      expect(complaints.single.evidenceUrls, hasLength(1));
    });

    test('uses admin result and final compensation when reviewed', () {
      final complaint = DisbursementComplaintModel.fromNotice(
        noticeId: 'notice-1',
        data: {
          'complainedCandidates': ['candidate-1'],
          'complaintResults': {'candidate-1': 'approved'},
          'adminFinalDeductions': {'candidate-1': 450000},
          'adminNotes': {'candidate-1': 'Bang chung hop le'},
        },
      ).single;

      expect(complaint.status, 'approved');
      expect(complaint.finalCompensation, 450000);
      expect(complaint.adminNote, 'Bang chung hop le');
      expect(complaint.isPending, isFalse);
    });
  });
}
