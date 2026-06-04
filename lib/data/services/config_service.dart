import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/config_model.dart';

class ConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'system_configs';
  static const String _docId = 'main';

  Future<ConfigModel> fetchConfig() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_docId).get();
      if (!doc.exists) {
        // Create default if not exists
        final defaultConfig = ConfigModel(
          autoApproveJobs: true,
          minimumBalanceToPost: 0.0,
          notifyNewUsers: true,
          notifyNewComplaints: true,
          notifyNewDisbursements: true,
        );
        await _firestore.collection(_collection).doc(_docId).set(defaultConfig.toMap());
        return defaultConfig;
      }
      return ConfigModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Lỗi khi tải cấu hình: $e');
    }
  }

  Future<void> updateConfig(ConfigModel config) async {
    try {
      await _firestore.collection(_collection).doc(_docId).set(
        config.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Lỗi khi cập nhật cấu hình: $e');
    }
  }
}
