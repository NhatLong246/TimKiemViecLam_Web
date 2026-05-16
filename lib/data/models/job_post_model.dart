import 'package:cloud_firestore/cloud_firestore.dart';

class JobPostModel {
  final String jobId;
  final String employerId;
  final String title;
  final String description;
  final String category;
  final String jobType;
  final Map<String, dynamic> location;
  final double salary;
  final String salaryType;
  final int slots;
  final int filledSlots;
  final DateTime startDate;
  final DateTime? endDate;
  final double? workHoursPerDay;
  final String? startTime;
  final String? requirements;
  final String status;
  final double totalBudget;
  final String? groupChatId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobPostModel({
    required this.jobId,
    required this.employerId,
    required this.title,
    required this.description,
    required this.category,
    required this.jobType,
    required this.location,
    required this.salary,
    required this.salaryType,
    required this.slots,
    this.filledSlots = 0,
    required this.startDate,
    this.endDate,
    this.workHoursPerDay,
    this.startTime,
    this.requirements,
    required this.status,
    required this.totalBudget,
    this.groupChatId,
    this.createdAt,
    this.updatedAt,
  });

  int get remainingSlots => (slots - filledSlots).clamp(0, slots);
  bool get isFull => remainingSlots == 0;

  String get locationDisplay {
    final district = location['district'] as String? ?? '';
    final city = location['city'] as String? ?? '';
    if (district.isNotEmpty && city.isNotEmpty) return '$district, $city';
    return city.isNotEmpty ? city : (location['address'] as String? ?? '');
  }

  String get salaryDisplay {
    final formatted = _formatNumber(salary.toInt());
    switch (salaryType) {
      case 'per_hour':
        return '$formatted₫/giờ';
      case 'per_day':
        return '$formatted₫/ngày';
      case 'per_month':
        return '$formatted₫/tháng';
      default:
        return '$formatted₫';
    }
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

  factory JobPostModel.fromMap(Map<String, dynamic> map) {
    DateTime toDateTime(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return JobPostModel(
      jobId: map['jobId'] as String? ?? '',
      employerId: map['employerId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      jobType: map['jobType'] as String? ?? 'part_time',
      location: (map['location'] as Map<String, dynamic>?) ?? {},
      salary: (map['salary'] as num?)?.toDouble() ?? 0,
      salaryType: map['salaryType'] as String? ?? 'per_day',
      slots: (map['slots'] as num?)?.toInt() ?? 1,
      filledSlots: (map['filledSlots'] as num?)?.toInt() ?? 0,
      startDate: toDateTime(map['startDate']),
      endDate: map['endDate'] != null ? toDateTime(map['endDate']) : null,
      workHoursPerDay: (map['workHoursPerDay'] as num?)?.toDouble(),
      startTime: map['startTime'] as String?,
      requirements: map['requirements'] as String?,
      status: map['status'] as String? ?? 'draft',
      totalBudget: (map['totalBudget'] as num?)?.toDouble() ?? 0,
      groupChatId: map['groupChatId'] as String?,
      createdAt:
          map['createdAt'] != null ? toDateTime(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? toDateTime(map['updatedAt']) : null,
    );
  }

  static String categoryLabel(String category) {
    const map = {
      'boc_vac': 'Bốc vác',
      'lau_don': 'Lau dọn',
      'bung_be': 'Bưng bê',
      'phuc_vu': 'Phục vụ',
      'pha_che': 'Pha chế',
      'tiep_thi': 'Tiếp thị',
      'van_chuyen': 'Vận chuyển',
      'bao_ve': 'Bảo vệ',
      'other': 'Khác',
    };
    return map[category] ?? category;
  }

  static String jobTypeLabel(String jobType) {
    switch (jobType) {
      case 'full_time':
        return 'Toàn thời gian';
      case 'part_time':
        return 'Bán thời gian';
      default:
        return jobType;
    }
  }

  JobPostModel copyWith({String? status}) {
    return JobPostModel(
      jobId: jobId,
      employerId: employerId,
      title: title,
      description: description,
      category: category,
      jobType: jobType,
      location: location,
      salary: salary,
      salaryType: salaryType,
      slots: slots,
      filledSlots: filledSlots,
      startDate: startDate,
      endDate: endDate,
      workHoursPerDay: workHoursPerDay,
      startTime: startTime,
      requirements: requirements,
      status: status ?? this.status,
      totalBudget: totalBudget,
      groupChatId: groupChatId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Nháp';
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'active':
        return 'Đang tuyển';
      case 'closed':
        return 'Đã đóng';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }
}
