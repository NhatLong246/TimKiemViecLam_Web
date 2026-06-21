import 'package:flutter/material.dart';

import '../data/services/job_post_service.dart';
import '../data/models/job_post_model.dart';

class JobPostController extends ChangeNotifier {
  final JobPostService _service = JobPostService();

  List<JobPostModel> _allJobPosts = [];
  String _statusFilter = 'all';
  String _searchQuery = '';
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  bool isLoading = false;
  String? errorMessage;
  String? processingJobId;

  static const statusFilters = [
    'all',
    'draft',
    'pending',
    'approved',
    'active',
    'closed',
    'rejected',
  ];

  String get statusFilter => _statusFilter;
  List<JobPostModel> get jobPosts => _filteredPosts;
  int get totalCount => _allJobPosts.length;

  int countByStatus(String status) =>
      _allJobPosts.where((p) => p.status == status).length;

  List<JobPostModel> get _filteredPosts {
    var list = _allJobPosts;
    if (_statusFilter != 'all') {
      list = list.where((p) => p.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(q) ||
                JobPostModel.categoryLabel(p.category)
                    .toLowerCase()
                    .contains(q) ||
                p.locationDisplay.toLowerCase().contains(q) ||
                p.employerId.toLowerCase().contains(q),
          )
          .toList();
    }
    if (filterStartDate != null && filterEndDate != null) {
      list = list.where((p) {
        if (p.createdAt == null) return false;
        return p.createdAt!.compareTo(filterStartDate!) >= 0 && p.createdAt!.compareTo(filterEndDate!) <= 0;
      }).toList();
    }
    return list;
  }

  Future<void> fetchJobPosts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allJobPosts = await _service.fetchJobPosts();
    } catch (e) {
      errorMessage = e.toString();
      _allJobPosts = [];
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

  void setDateFilter(DateTime? start, DateTime? end) {
    filterStartDate = start;
    filterEndDate = end;
    notifyListeners();
  }

  Future<String?> approveJobPost(String jobId) async {
    return _updateStatus(jobId, 'approved');
  }

  Future<String?> rejectJobPost(String jobId, {String? reason}) async {
    return _updateStatus(jobId, 'rejected', rejectionReason: reason);
  }

  Future<String?> _updateStatus(
    String jobId,
    String status, {
    String? rejectionReason,
  }) async {
    processingJobId = jobId;
    notifyListeners();

    try {
      await _service.updateJobStatus(
        jobId,
        status: status,
        rejectionReason: rejectionReason,
      );
      final index = _allJobPosts.indexWhere((p) => p.jobId == jobId);
      if (index != -1) {
        _allJobPosts[index] = _allJobPosts[index].copyWith(status: status);
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingJobId = null;
      notifyListeners();
    }
  }

  Future<String?> deleteJobPost(String jobId) async {
    processingJobId = jobId;
    notifyListeners();

    try {
      await _service.deleteJobPost(jobId);
      _allJobPosts.removeWhere((p) => p.jobId == jobId);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingJobId = null;
      notifyListeners();
    }
  }
}
