import 'package:flutter/material.dart';

import '../data/services/user_service.dart';
import '../data/models/user_model.dart';

class UserController extends ChangeNotifier {
  final UserService _service = UserService();

  List<UserModel> _allUsers = [];
  String _roleFilter = 'all';
  String _statusFilter = 'all'; // all, active, locked
  String _searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  String? processingUserId;

  static const roleFilters = [
    'all',
    'candidate',
    'employer',
    'admin',
  ];

  static const statusFilters = [
    'all',
    'active',
    'locked',
  ];

  String get roleFilter => _roleFilter;
  String get statusFilter => _statusFilter;
  List<UserModel> get users => _filteredUsers;
  int get totalCount => _allUsers.length;

  int countByRole(String role) =>
      _allUsers.where((u) => u.role == role).length;

  List<UserModel> get _filteredUsers {
    var list = _allUsers;
    
    if (_roleFilter != 'all') {
      list = list.where((u) => u.role == _roleFilter).toList();
    }
    
    if (_statusFilter != 'all') {
      final isActiveFilter = _statusFilter == 'active';
      list = list.where((u) => u.isActive == isActiveFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) {
        final name = u.fullName.toLowerCase();
        final email = u.email.toLowerCase();
        final username = u.username.toLowerCase();
        return name.contains(q) ||
            email.contains(q) ||
            username.contains(q) ||
            u.uid.toLowerCase().contains(q) ||
            u.phone.contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> fetchUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allUsers = await _service.fetchUsers();
    } catch (e) {
      errorMessage = e.toString();
      _allUsers = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setRoleFilter(String role) {
    if (_roleFilter == role) return;
    _roleFilter = role;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  Future<String?> toggleUserStatus(String uid, bool currentStatus) async {
    processingUserId = uid;
    notifyListeners();

    try {
      final newStatus = !currentStatus;
      await _service.updateUserStatus(uid, newStatus);
      final index = _allUsers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].copyWith(isActive: newStatus);
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingUserId = null;
      notifyListeners();
    }
  }

  Future<String?> toggleVerification(String uid, bool currentStatus) async {
    processingUserId = uid;
    notifyListeners();

    try {
      final newStatus = !currentStatus;
      await _service.updateUserVerification(uid, newStatus);
      final index = _allUsers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].copyWith(isVerified: newStatus);
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingUserId = null;
      notifyListeners();
    }
  }
}
