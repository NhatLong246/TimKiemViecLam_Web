import 'package:cloud_firestore/cloud_firestore.dart';

class DisbursementComplaintModel {
  final String noticeId;
  final String jobId;
  final String groupId;
  final String employerId;
  final String candidateId;
  final String jobTitle;
  final String reason;
  final List<String> evidenceUrls;
  final double candidateWage;
  final double proposedCompensation;
  final double finalCompensation;
  final String status;
  final String adminNote;
  final DateTime? createdAt;
  String? employerName;
  String? candidateName;

  DisbursementComplaintModel({
    required this.noticeId,
    required this.jobId,
    required this.groupId,
    required this.employerId,
    required this.candidateId,
    required this.jobTitle,
    required this.reason,
    required this.evidenceUrls,
    required this.candidateWage,
    required this.proposedCompensation,
    required this.finalCompensation,
    required this.status,
    required this.adminNote,
    this.createdAt,
    this.employerName,
    this.candidateName,
  });

  bool get isPending => status == 'pending';

  String get rowId => '$noticeId:$candidateId';

  static List<DisbursementComplaintModel> fromNotice({
    required String noticeId,
    required Map<String, dynamic> data,
  }) {
    final candidates = _stringList(data['complainedCandidates']);
    final wages = _doubleMap(data['candidateAmounts']);
    final proposed = _doubleMap(data['deductions']);
    final reasons = _stringMap(data['complaintReasons']);
    final evidence = _stringListMap(data['complaintEvidence']);
    final results = _stringMap(data['complaintResults']);
    final finalDeductions = _doubleMap(data['adminFinalDeductions']);
    final adminNotes = _stringMap(data['adminNotes']);
    final legacyAdminNote = data['adminNote'] as String? ?? '';
    final createdAt = data['createdAt'];

    return candidates
        .map(
          (candidateId) => DisbursementComplaintModel(
            noticeId: noticeId,
            jobId: data['jobId'] as String? ?? '',
            groupId: data['groupId'] as String? ?? '',
            employerId: data['employerId'] as String? ?? '',
            candidateId: candidateId,
            jobTitle: data['jobTitle'] as String? ?? '',
            reason: reasons[candidateId] ?? '',
            evidenceUrls: evidence[candidateId] ?? const [],
            candidateWage: wages[candidateId] ?? 0,
            proposedCompensation: proposed[candidateId] ?? 0,
            finalCompensation: finalDeductions[candidateId] ?? 0,
            status: results[candidateId] ?? 'pending',
            adminNote: adminNotes[candidateId] ?? legacyAdminNote,
            createdAt: createdAt is Timestamp
                ? createdAt.toDate()
                : createdAt is DateTime
                ? createdAt
                : null,
          ),
        )
        .toList();
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return 'Chờ xử lý';
    }
  }

  DisbursementComplaintModel copyWith({
    String? status,
    double? finalCompensation,
    String? adminNote,
  }) {
    return DisbursementComplaintModel(
      noticeId: noticeId,
      jobId: jobId,
      groupId: groupId,
      employerId: employerId,
      candidateId: candidateId,
      jobTitle: jobTitle,
      reason: reason,
      evidenceUrls: evidenceUrls,
      candidateWage: candidateWage,
      proposedCompensation: proposedCompensation,
      finalCompensation: finalCompensation ?? this.finalCompensation,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt,
      employerName: employerName,
      candidateName: candidateName,
    );
  }

  static List<String> _stringList(dynamic value) =>
      value is List ? value.map((item) => item.toString()).toList() : [];

  static Map<String, String> _stringMap(dynamic value) {
    if (value is! Map) return {};
    return value.map((key, item) => MapEntry(key.toString(), item.toString()));
  }

  static Map<String, double> _doubleMap(dynamic value) {
    if (value is! Map) return {};
    return value.map(
      (key, item) => MapEntry(key.toString(), (item as num?)?.toDouble() ?? 0),
    );
  }

  static Map<String, List<String>> _stringListMap(dynamic value) {
    if (value is! Map) return {};
    return value.map(
      (key, item) => MapEntry(key.toString(), _stringList(item)),
    );
  }
}
