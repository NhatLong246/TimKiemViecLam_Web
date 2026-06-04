import 'package:flutter/material.dart';

import '../data/services/user_service.dart';
import '../data/models/user_model.dart';

class CandidateController extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _allCandidates = [];
  String _statusFilter = 'all'; // all, active, locked
  String _searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  String? processingUserId;

  static const statusFilters = [
    'all',
    'active',
    'locked',
  ];

  String get statusFilter => _statusFilter;
  List<UserModel> get candidates => _filteredCandidates;
  int get totalCount => _allCandidates.length;

  List<UserModel> get _filteredCandidates {
    var list = _allCandidates;
    
    if (_statusFilter != 'all') {
      final isActiveFilter = _statusFilter == 'active';
      list = list.where((u) => u.isActive == isActiveFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) {
        final name = u.fullName.toLowerCase();
        final email = u.email.toLowerCase();
        return name.contains(q) || email.contains(q) || u.phone.contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> fetchCandidates() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allCandidates = await _userService.fetchCandidates();
    } catch (e) {
      errorMessage = e.toString();
      _allCandidates = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
      await _userService.updateUserStatus(uid, newStatus);
      final index = _allCandidates.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allCandidates[index] = _allCandidates[index].copyWith(isActive: newStatus);
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
      await _userService.updateUserVerification(uid, newStatus);
      final index = _allCandidates.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allCandidates[index] = _allCandidates[index].copyWith(isVerified: newStatus);
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
