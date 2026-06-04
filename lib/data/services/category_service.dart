import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh mục: $e');
    }
  }

  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore.collection('categories').add(category.toMap());
      final docSnap = await docRef.get();
      return CategoryModel.fromMap(docSnap.data()!, docSnap.id);
    } catch (e) {
      throw Exception('Lỗi khi thêm danh mục: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      final data = category.toMap();
      data.remove('createdAt'); // don't overwrite createdAt
      await _firestore.collection('categories').doc(category.id).update(data);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật danh mục: $e');
    }
  }

  Future<void> toggleCategoryActive(String id, bool isActive) async {
    try {
      await _firestore.collection('categories').doc(id).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi thay đổi trạng thái danh mục: $e');
    }
  }
}
