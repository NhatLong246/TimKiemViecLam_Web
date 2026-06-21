import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String role;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String? avatarUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;
  final String? companyName;
  final String? companyAddress;
  final String? companyTaxCode;
  final String? companySize;
  final String? businessType;
  final double walletBalance;

  UserModel({
    required this.uid,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.companyName,
    this.companyAddress,
    this.companyTaxCode,
    this.companySize,
    this.businessType,
    this.walletBalance = 0.0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? toDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      return null;
    }

    return UserModel(
      uid: id,
      role: map['role'] as String? ?? 'candidate',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: toDateTime(map['createdAt']),
      companyName: map['companyName'] as String?,
      companyAddress: map['companyAddress'] as String?,
      companyTaxCode: map['companyTaxCode'] as String?,
      companySize: map['companySize'] as String?,
      businessType: map['businessType'] as String?,
      walletBalance: (map['walletBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'employer':
        return 'Nhà tuyển dụng';
      case 'candidate':
        return 'Ứng viên';
      default:
        return 'Không xác định';
    }
  }

  UserModel copyWith({
    String? role,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    String? companyName,
    String? companyAddress,
    String? companyTaxCode,
    String? companySize,
    String? businessType,
    double? walletBalance,
  }) {
    return UserModel(
      uid: uid,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyTaxCode: companyTaxCode ?? this.companyTaxCode,
      companySize: companySize ?? this.companySize,
      businessType: businessType ?? this.businessType,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}
