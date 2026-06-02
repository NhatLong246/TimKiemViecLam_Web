import 'package:flutter/material.dart';

import '../data/services/disbursement_service.dart';
import '../data/models/disbursement_model.dart';

class DisbursementController extends ChangeNotifier {
  final DisbursementService _service = DisbursementService();

  List<DisbursementModel> _allNotices = [];
  String _statusFilter = 'all';
  String _searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  String? processingNoticeId;

  static const statusFilters = [
    'all',
    'pending_admin',
    'cleared',
    'rejected',
  ];

  String get statusFilter => _statusFilter;
  List<DisbursementModel> get notices => _filteredNotices;
  int get totalCount => _allNotices.length;

  int countByStatus(String status) =>
      _allNotices.where((n) => n.status == status).length;

  List<DisbursementModel> get _filteredNotices {
    var list = _allNotices;
    if (_statusFilter != 'all') {
      list = list.where((n) => n.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((n) {
        final jobTitle = n.jobTitle?.toLowerCase() ?? '';
        final empName = n.employerName?.toLowerCase() ?? '';
        return jobTitle.contains(q) ||
            empName.contains(q) ||
            n.jobId.toLowerCase().contains(q) ||
            n.employerId.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> fetchDisbursements() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allNotices = await _service.fetchDisbursements();
    } catch (e) {
      errorMessage = e.toString();
      _allNotices = [];
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

  Future<String?> approveDisbursement(String noticeId) async {
    processingNoticeId = noticeId;
    notifyListeners();

    try {
      await _service.updateDisbursementStatus(
        noticeId,
        adminAck: true,
        status: 'cleared',
      );
      final index = _allNotices.indexWhere((n) => n.noticeId == noticeId);
      if (index != -1) {
        _allNotices[index] = _allNotices[index].copyWith(
          status: 'cleared',
          adminAck: true,
        );
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingNoticeId = null;
      notifyListeners();
    }
  }

  Future<String?> rejectDisbursement(String noticeId, String reason) async {
    processingNoticeId = noticeId;
    notifyListeners();

    try {
      await _service.updateDisbursementStatus(
        noticeId,
        adminAck: false,
        status: 'rejected',
        rejectionReason: reason,
      );
      final index = _allNotices.indexWhere((n) => n.noticeId == noticeId);
      if (index != -1) {
        _allNotices[index] = _allNotices[index].copyWith(
          status: 'rejected',
          adminAck: false,
          rejectionReason: reason,
        );
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingNoticeId = null;
      notifyListeners();
    }
  }
}
