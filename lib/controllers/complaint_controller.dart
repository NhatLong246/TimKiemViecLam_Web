import 'package:flutter/material.dart';

import '../data/services/complaint_service.dart';
import '../data/models/complaint_model.dart';

class ComplaintController extends ChangeNotifier {
  final ComplaintService _service = ComplaintService();

  List<ComplaintModel> _allComplaints = [];
  String _statusFilter = 'all';
  String _searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  String? processingComplaintId;

  static const statusFilters = [
    'all',
    'pending',
    'processing',
    'resolved',
    'rejected',
  ];

  String get statusFilter => _statusFilter;
  List<ComplaintModel> get complaints => _filteredComplaints;
  int get totalCount => _allComplaints.length;

  int countByStatus(String status) =>
      _allComplaints.where((c) => c.status == status).length;

  List<ComplaintModel> get _filteredComplaints {
    var list = _allComplaints;
    if (_statusFilter != 'all') {
      list = list.where((c) => c.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) {
        final jobTitle = c.jobTitle.toLowerCase();
        final empName = c.employerName?.toLowerCase() ?? '';
        final candName = c.candidateName?.toLowerCase() ?? '';
        return jobTitle.contains(q) ||
            empName.contains(q) ||
            candName.contains(q) ||
            c.jobId.toLowerCase().contains(q) ||
            c.employerId.toLowerCase().contains(q) ||
            c.candidateId.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> fetchComplaints() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allComplaints = await _service.fetchComplaints();
    } catch (e) {
      errorMessage = e.toString();
      _allComplaints = [];
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

  Future<String?> processComplaint(
    String complaintId,
    String status, {
    String? resolution,
    String? resolvedBy,
  }) async {
    processingComplaintId = complaintId;
    notifyListeners();

    try {
      await _service.updateComplaintStatus(
        complaintId,
        status: status,
        resolution: resolution,
        resolvedBy: resolvedBy,
      );
      final index = _allComplaints.indexWhere((c) => c.complaintId == complaintId);
      if (index != -1) {
        _allComplaints[index] = _allComplaints[index].copyWith(
          status: status,
          resolution: resolution,
          resolvedBy: resolvedBy,
        );
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingComplaintId = null;
      notifyListeners();
    }
  }
}
