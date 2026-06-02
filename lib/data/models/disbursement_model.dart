import 'package:cloud_firestore/cloud_firestore.dart';

class DisbursementModel {
  final String noticeId;
  final String jobId;
  final String groupId;
  final String employerId;
  final String workDate;
  final double amount;
  final String status;
  final bool employerAck;
  final bool adminAck;
  final String? rejectionReason;
  final DateTime? createdAt;

  // Additional fields fetched from other collections for display
  String? jobTitle;
  String? employerName;

  DisbursementModel({
    required this.noticeId,
    required this.jobId,
    required this.groupId,
    required this.employerId,
    required this.workDate,
    required this.amount,
    required this.status,
    required this.employerAck,
    required this.adminAck,
    this.rejectionReason,
    this.createdAt,
    this.jobTitle,
    this.employerName,
  });

  factory DisbursementModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? toDateTime(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    return DisbursementModel(
      noticeId: id,
      jobId: map['jobId'] as String? ?? '',
      groupId: map['groupId'] as String? ?? '',
      employerId: map['employerId'] as String? ?? '',
      workDate: map['workDate'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pending_admin',
      employerAck: map['employerAck'] as bool? ?? false,
      adminAck: map['adminAck'] as bool? ?? false,
      rejectionReason: map['rejectionReason'] as String?,
      createdAt: toDateTime(map['createdAt']),
    );
  }

  String get amountDisplay {
    final formatted = _formatNumber(amount.toInt());
    return '$formatted₫';
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'pending_admin':
        return 'Chờ duyệt';
      case 'cleared':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  DisbursementModel copyWith({
    String? status,
    bool? adminAck,
    String? rejectionReason,
  }) {
    return DisbursementModel(
      noticeId: noticeId,
      jobId: jobId,
      groupId: groupId,
      employerId: employerId,
      workDate: workDate,
      amount: amount,
      status: status ?? this.status,
      employerAck: employerAck,
      adminAck: adminAck ?? this.adminAck,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      jobTitle: jobTitle,
      employerName: employerName,
    );
  }
}
