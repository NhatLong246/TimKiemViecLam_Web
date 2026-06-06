import 'package:flutter/material.dart';

import '../data/models/disbursement_complaint_model.dart';
import '../data/services/disbursement_complaint_service.dart';

class ComplaintController extends ChangeNotifier {
  final DisbursementComplaintService _service;

  ComplaintController({DisbursementComplaintService? service})
    : _service = service ?? DisbursementComplaintService();

  List<DisbursementComplaintModel> _allComplaints = [];
  String _statusFilter = 'all';
  String _searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  String? processingComplaintId;

  static const statusFilters = ['all', 'pending', 'approved', 'rejected'];

  String get statusFilter => _statusFilter;
  List<DisbursementComplaintModel> get complaints => _filteredComplaints;
  int get totalCount => _allComplaints.length;

  int countByStatus(String status) =>
      _allComplaints.where((complaint) => complaint.status == status).length;

  List<DisbursementComplaintModel> get _filteredComplaints {
    var list = _allComplaints;
    if (_statusFilter != 'all') {
      list = list.where((item) => item.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((item) {
        return item.jobTitle.toLowerCase().contains(query) ||
            (item.employerName ?? item.employerId).toLowerCase().contains(
              query,
            ) ||
            (item.candidateName ?? item.candidateId).toLowerCase().contains(
              query,
            ) ||
            item.reason.toLowerCase().contains(query) ||
            item.noticeId.toLowerCase().contains(query);
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

  Future<String?> resolveComplaint({
    required DisbursementComplaintModel complaint,
    required String decision,
    required double finalCompensation,
    required String note,
  }) async {
    processingComplaintId = complaint.rowId;
    notifyListeners();
    try {
      await _service.resolveComplaint(
        noticeId: complaint.noticeId,
        candidateId: complaint.candidateId,
        decision: decision,
        finalCompensation: finalCompensation,
        note: note,
      );
      final index = _allComplaints.indexWhere(
        (item) => item.rowId == complaint.rowId,
      );
      if (index != -1) {
        _allComplaints[index] = _allComplaints[index].copyWith(
          status: decision,
          finalCompensation: decision == 'approved' ? finalCompensation : 0,
          adminNote: note,
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
