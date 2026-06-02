import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> fetchUsers({int limit = 100}) async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<UserModel>> fetchEmployers({int limit = 100}) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'employer')
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateUserStatus(String uid, bool isActive) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception('Người dùng không tồn tại');
    }

    await docRef.update({
      'isActive': isActive,
    });
  }

  Future<void> updateUserVerification(String uid, bool isVerified) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception('Người dùng không tồn tại');
    }

    await docRef.update({
      'isVerified': isVerified,
    });
  }
}
