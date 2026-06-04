import 'package:flutter/material.dart';

import '../data/services/complaint_service.dart';
import '../data/models/complaint_model.dart';
import '../data/services/transaction_service.dart';
import '../data/services/notification_service.dart';

class ComplaintController extends ChangeNotifier {
  final ComplaintService _service = ComplaintService();
  final TransactionService _txnService = TransactionService();
  final NotificationService _notifService = NotificationService();

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

  Future<String?> applyPenalty(String complaintId, String employerId, double amount, String reason) async {
    processingComplaintId = complaintId;
    notifyListeners();
    try {
      await _txnService.createTransaction(
        userId: employerId,
        type: 'penalty',
        amount: amount,
      );
      await _notifService.sendNotification(
        userId: employerId,
        title: 'Thông báo xử phạt vi phạm',
        body: 'Tài khoản của bạn đã bị trừ ${amount.toStringAsFixed(0)}đ do: $reason',
        type: 'penalty',
        relatedId: complaintId,
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingComplaintId = null;
      notifyListeners();
    }
  }

  Future<String?> applyCompensation(String complaintId, String candidateId, double amount, String reason) async {
    processingComplaintId = complaintId;
    notifyListeners();
    try {
      await _txnService.createTransaction(
        userId: candidateId,
        type: 'compensation',
        amount: amount,
      );
      await _notifService.sendNotification(
        userId: candidateId,
        title: 'Thông báo bồi thường khiếu nại',
        body: 'Tài khoản của bạn đã được cộng ${amount.toStringAsFixed(0)}đ với lý do: $reason',
        type: 'compensation',
        relatedId: complaintId,
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      processingComplaintId = null;
      notifyListeners();
    }
  }
}
