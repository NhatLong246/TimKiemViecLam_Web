import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String complaintId;
  final String jobId;
  final String groupId;
  final String employerId;
  final String candidateId;
  final String jobTitle;
  final String description;
  final List<String> imageBase64s;
  final String status;
  final String? resolution;
  final String? resolvedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields fetched for display
  String? employerName;
  String? candidateName;

  ComplaintModel({
    required this.complaintId,
    required this.jobId,
    required this.groupId,
    required this.employerId,
    required this.candidateId,
    required this.jobTitle,
    required this.description,
    required this.imageBase64s,
    required this.status,
    this.resolution,
    this.resolvedBy,
    this.createdAt,
    this.updatedAt,
    this.employerName,
    this.candidateName,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? toDateTime(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    return ComplaintModel(
      complaintId: id,
      jobId: map['jobId'] as String? ?? '',
      groupId: map['groupId'] as String? ?? '',
      employerId: map['employerId'] as String? ?? '',
      candidateId: map['candidateId'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageBase64s: (map['imageBase64s'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: map['status'] as String? ?? 'pending',
      resolution: map['resolution'] as String?,
      resolvedBy: map['resolvedBy'] as String?,
      createdAt: toDateTime(map['createdAt']),
      updatedAt: toDateTime(map['updatedAt']),
    );
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'processing':
        return 'Đang xử lý';
      case 'resolved':
        return 'Đã xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  ComplaintModel copyWith({
    String? status,
    String? resolution,
    String? resolvedBy,
  }) {
    return ComplaintModel(
      complaintId: complaintId,
      jobId: jobId,
      groupId: groupId,
      employerId: employerId,
      candidateId: candidateId,
      jobTitle: jobTitle,
      description: description,
      imageBase64s: imageBase64s,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      employerName: employerName,
      candidateName: candidateName,
    );
  }
}
