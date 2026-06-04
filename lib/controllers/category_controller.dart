import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<CategoryModel> _categories = [];
  bool isLoading = false;
  String? errorMessage;
  String _searchQuery = '';

  List<CategoryModel> get categories {
    if (_searchQuery.isEmpty) return _categories;
    final q = _searchQuery.toLowerCase();
    return _categories.where((c) {
      return c.name.toLowerCase().contains(q) || c.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _categories = await _service.fetchCategories();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<String?> addCategory(CategoryModel category) async {
    try {
      final newCat = await _service.addCategory(category);
      _categories.insert(0, newCat);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateCategory(CategoryModel category) async {
    try {
      await _service.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleCategoryActive(String id, bool isActive) async {
    try {
      await _service.toggleCategoryActive(id, isActive);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(isActive: isActive);
        notifyListeners();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
