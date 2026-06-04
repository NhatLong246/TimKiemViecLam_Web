import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TransactionModel>> fetchTransactionsByUser(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .limit(limit)
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();

      transactions.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return transactions;
    } catch (e) {
      throw Exception('Không thể tải lịch sử giao dịch: $e');
    }
  }

  Future<void> createTransaction({
    required String userId,
    required String type,
    required double amount,
    String? jobId,
    String status = 'completed',
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final txnRef = _firestore.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception('Người dùng không tồn tại');
      }

      final double currentBalance =
          (userSnapshot.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;

      double newBalance = currentBalance;
      if (type == 'penalty') {
        newBalance -= amount;
      } else if (type == 'compensation') {
        newBalance += amount;
      } else {
        newBalance += amount;
      }

      transaction.update(userRef, {'walletBalance': newBalance});

      transaction.set(txnRef, {
        'userId': userId,
        'type': type,
        'amount': amount,
        'balanceBefore': currentBalance,
        'balanceAfter': newBalance,
        'jobId': jobId,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
