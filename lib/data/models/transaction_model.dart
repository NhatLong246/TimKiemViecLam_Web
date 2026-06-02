import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String txnId;
  final String userId;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? jobId;
  final String status;
  final DateTime? createdAt;

  TransactionModel({
    required this.txnId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.jobId,
    required this.status,
    this.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? toDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      return null;
    }

    return TransactionModel(
      txnId: id,
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (map['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (map['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      jobId: map['jobId'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: toDateTime(map['createdAt']),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'deposit':
        return 'Nạp tiền';
      case 'payment':
        return 'Thanh toán';
      case 'withdrawal':
        return 'Rút tiền';
      case 'refund':
        return 'Hoàn tiền';
      case 'hold':
        return 'Tạm giữ';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Đang chờ';
      case 'completed':
        return 'Hoàn thành';
      case 'failed':
        return 'Thất bại';
      default:
        return status;
    }
  }
}
