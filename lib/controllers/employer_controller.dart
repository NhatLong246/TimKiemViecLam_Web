import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/services/user_service.dart';
import '../data/models/user_model.dart';

class EmployerController extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _allEmployers = [];
  String _statusFilter = 'all'; // all, active, locked
  String _searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  String? processingUserId;

  // Cache for job post counts
  final Map<String, int> _jobCounts = {};

  static const statusFilters = [
    'all',
    'active',
    'locked',
  ];

  String get statusFilter => _statusFilter;
  List<UserModel> get employers => _filteredEmployers;
  int get totalCount => _allEmployers.length;

  int getJobCount(String uid) => _jobCounts[uid] ?? 0;

  List<UserModel> get _filteredEmployers {
    var list = _allEmployers;
    
    if (_statusFilter != 'all') {
      final isActiveFilter = _statusFilter == 'active';
      list = list.where((u) => u.isActive == isActiveFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) {
        final name = u.fullName.toLowerCase();
        final email = u.email.toLowerCase();
        final company = (u.companyName ?? '').toLowerCase();
        return name.contains(q) || email.contains(q) || company.contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> fetchEmployers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allEmployers = await _userService.fetchEmployers();
      await _fetchJobCountsForEmployers();
    } catch (e) {
      errorMessage = e.toString();
      _allEmployers = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchJobCountsForEmployers() async {
    // In a real large-scale app, querying counts for all employers at once
    // might be heavy, but with Firestore's count() aggregate query it is much cheaper.
    // We will do it in parallel for the fetched employers.
    final futures = _allEmployers.map((emp) async {
      try {
        final aggregateQuery = await _firestore
            .collection('jobPosts')
            .where('employerId', isEqualTo: emp.uid)
            .count()
            .get();
        _jobCounts[emp.uid] = aggregateQuery.count ?? 0;
      } catch (e) {
        _jobCounts[emp.uid] = 0;
      }
    });
    
    await Future.wait(futures);
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
      final index = _allEmployers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allEmployers[index] = _allEmployers[index].copyWith(isActive: newStatus);
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
      final index = _allEmployers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allEmployers[index] = _allEmployers[index].copyWith(isVerified: newStatus);
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
