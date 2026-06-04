class ConfigModel {
  final bool autoApproveJobs;
  final double minimumBalanceToPost;
  final bool notifyNewUsers;
  final bool notifyNewComplaints;
  final bool notifyNewDisbursements;

  ConfigModel({
    required this.autoApproveJobs,
    required this.minimumBalanceToPost,
    required this.notifyNewUsers,
    required this.notifyNewComplaints,
    required this.notifyNewDisbursements,
  });

  factory ConfigModel.fromMap(Map<String, dynamic> map) {
    return ConfigModel(
      autoApproveJobs: map['autoApproveJobs'] as bool? ?? true,
      minimumBalanceToPost: (map['minimumBalanceToPost'] as num?)?.toDouble() ?? 0.0,
      notifyNewUsers: map['notifyNewUsers'] as bool? ?? true,
      notifyNewComplaints: map['notifyNewComplaints'] as bool? ?? true,
      notifyNewDisbursements: map['notifyNewDisbursements'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoApproveJobs': autoApproveJobs,
      'minimumBalanceToPost': minimumBalanceToPost,
      'notifyNewUsers': notifyNewUsers,
      'notifyNewComplaints': notifyNewComplaints,
      'notifyNewDisbursements': notifyNewDisbursements,
    };
  }

  ConfigModel copyWith({
    bool? autoApproveJobs,
    double? minimumBalanceToPost,
    bool? notifyNewUsers,
    bool? notifyNewComplaints,
    bool? notifyNewDisbursements,
  }) {
    return ConfigModel(
      autoApproveJobs: autoApproveJobs ?? this.autoApproveJobs,
      minimumBalanceToPost: minimumBalanceToPost ?? this.minimumBalanceToPost,
      notifyNewUsers: notifyNewUsers ?? this.notifyNewUsers,
      notifyNewComplaints: notifyNewComplaints ?? this.notifyNewComplaints,
      notifyNewDisbursements: notifyNewDisbursements ?? this.notifyNewDisbursements,
    );
  }
}
