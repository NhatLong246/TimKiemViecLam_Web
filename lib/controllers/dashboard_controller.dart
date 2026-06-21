import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int totalUsers = 0;
  int openJobs = 0;
  int totalApplications = 0;
  int totalCompanies = 0;

  // Dữ liệu biểu đồ tròn
  int hiredApps = 0;
  int pendingApps = 0;
  int interviewApps = 0;
  int rejectedApps = 0;

  // Dữ liệu biểu đồ đường
  List<double> chartData = [];
  List<String> chartLabels = [];
  String chartTitle = "Thống kê lượt ứng tuyển";

  bool isLoading = true;

  DashboardController() {
    fetchDashboardData();
  }

  List<QueryDocumentSnapshot> _allUsers = [];
  List<QueryDocumentSnapshot> _allJobs = [];
  List<QueryDocumentSnapshot> _allApps = [];
  List<QueryDocumentSnapshot> _allCompanies = [];

  DateTime? filterStartDate;
  DateTime? filterEndDate;

  Future<void> fetchDashboardData() async {
    isLoading = true;
    notifyListeners();

    try {
      final uSnap = await _firestore.collection('users').get();
      _allUsers = uSnap.docs;

      final jSnap = await _firestore.collection('jobs').get();
      _allJobs = jSnap.docs;

      final aSnap = await _firestore.collection('applications').get();
      _allApps = aSnap.docs;

      final cSnap = await _firestore.collection('companies').get();
      _allCompanies = cSnap.docs;

      _calculateMetrics();
    } catch (e) {
      print("Lỗi khi tải dữ liệu từ Firebase: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setDateFilter(DateTime? start, DateTime? end) {
    filterStartDate = start;
    filterEndDate = end;
    _calculateMetrics();
    notifyListeners();
  }

  DateTime? _getDateFromDoc(Map<String, dynamic> data, String field) {
    if (!data.containsKey(field)) return null;
    var val = data[field];
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return null;
  }

  bool _isWithinFilter(DateTime? date) {
    if (filterStartDate == null || filterEndDate == null) return true;
    if (date == null) return false;
    return date.compareTo(filterStartDate!) >= 0 && date.compareTo(filterEndDate!) <= 0;
  }

  void _calculateMetrics() {
    final filteredUsers = _allUsers.where((doc) => _isWithinFilter(_getDateFromDoc(doc.data() as Map<String, dynamic>, 'createdAt'))).toList();
    totalUsers = filteredUsers.length;

    final filteredJobs = _allJobs.where((doc) => _isWithinFilter(_getDateFromDoc(doc.data() as Map<String, dynamic>, 'createdAt'))).toList();
    openJobs = filteredJobs.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'open').length;

    final filteredApps = _allApps.where((doc) => _isWithinFilter(_getDateFromDoc(doc.data() as Map<String, dynamic>, 'appliedAt') ?? _getDateFromDoc(doc.data() as Map<String, dynamic>, 'createdAt'))).toList();
    totalApplications = filteredApps.length;

    final filteredCompanies = _allCompanies.where((doc) => _isWithinFilter(_getDateFromDoc(doc.data() as Map<String, dynamic>, 'createdAt'))).toList();
    totalCompanies = filteredCompanies.length;

    hiredApps = filteredApps.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'hired').length;
    pendingApps = filteredApps.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'pending').length;
    interviewApps = filteredApps.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'interviewing').length;
    rejectedApps = filteredApps.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'rejected').length;

    DateTime endDate = filterEndDate ?? DateTime.now();
    DateTime? explicitStartDate = filterStartDate;

    if (explicitStartDate == null && filteredApps.isNotEmpty) {
      DateTime earliest = endDate;
      for (var doc in filteredApps) {
        final date = _getDateFromDoc(doc.data() as Map<String, dynamic>, 'appliedAt') ?? _getDateFromDoc(doc.data() as Map<String, dynamic>, 'createdAt');
        if (date != null && date.isBefore(earliest)) {
          earliest = date;
        }
      }
      explicitStartDate = earliest;
    }
    DateTime startDate = explicitStartDate ?? endDate.subtract(const Duration(days: 6));
    
    DateTime startOnlyDate = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime endOnlyDate = DateTime(endDate.year, endDate.month, endDate.day);
    int daysDiff = endOnlyDate.difference(startOnlyDate).inDays + 1;

    if (daysDiff > 31) {
      // Group by month
      chartTitle = filterStartDate == null ? "Lượt ứng tuyển (Tất cả thời gian)" : "Lượt ứng tuyển (Theo Tháng)";
      int monthsDiff = (endOnlyDate.year - startOnlyDate.year) * 12 + endOnlyDate.month - startOnlyDate.month + 1;
      List<double> tempData = List.filled(monthsDiff, 0);
      List<String> tempLabels = List.filled(monthsDiff, '');
      for (int i = 0; i < monthsDiff; i++) {
        int m = startOnlyDate.month + i;
        int y = startOnlyDate.year + (m - 1) ~/ 12;
        m = (m - 1) % 12 + 1;
        tempLabels[i] = 'T$m/$y';
      }
      for (var doc in filteredApps) {
        final date = _getDateFromDoc(doc.data() as Map<String, dynamic>, 'appliedAt') ?? _getDateFromDoc(doc.data() as Map<String, dynamic>, 'createdAt');
        if (date != null && _isWithinFilter(date)) {
          int mDiff = (date.year - startOnlyDate.year) * 12 + date.month - startOnlyDate.month;
          if (mDiff >= 0 && mDiff < monthsDiff) {
            tempData[mDiff]++;
          }
        }
      }
      chartData = tempData;
      chartLabels = tempLabels;
    } else {
      // Group by day
      chartTitle = daysDiff <= 7 ? "Lượt ứng tuyển ($daysDiff ngày)" : "Lượt ứng tuyển (Theo Ngày)";
      List<double> tempData = List.filled(daysDiff, 0);
      List<String> tempLabels = List.filled(daysDiff, '');
      for (int i = 0; i < daysDiff; i++) {
        DateTime d = startOnlyDate.add(Duration(days: i));
        tempLabels[i] = '${d.day}/${d.month}';
      }
      for (var doc in filteredApps) {
        final date = _getDateFromDoc(doc.data() as Map<String, dynamic>, 'appliedAt') ?? _getDateFromDoc(doc.data() as Map<String, dynamic>, 'createdAt');
        if (date != null && _isWithinFilter(date)) {
          DateTime dOnly = DateTime(date.year, date.month, date.day);
          int idx = dOnly.difference(startOnlyDate).inDays;
          if (idx >= 0 && idx < daysDiff) {
            tempData[idx]++;
          }
        }
      }
      chartData = tempData;
      chartLabels = tempLabels;
    }
  }
}
