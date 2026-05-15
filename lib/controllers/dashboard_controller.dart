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

  // Dữ liệu biểu đồ đường (Thứ 2 đến Chủ Nhật)
  List<double> weeklyApplications = List.filled(7, 0);

  bool isLoading = true;

  DashboardController() {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading = true;
    notifyListeners();

    try {
      final usersQuery = await _firestore.collection('users').count().get();
      totalUsers = usersQuery.count ?? 0;

      final jobsQuery = await _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'open')
          .count()
          .get();
      openJobs = jobsQuery.count ?? 0;

      final appsQuery = await _firestore
          .collection('applications')
          .count()
          .get();
      totalApplications = appsQuery.count ?? 0;

      final companiesQuery = await _firestore
          .collection('companies')
          .count()
          .get();
      totalCompanies = companiesQuery.count ?? 0;

      // Lấy dữ liệu biểu đồ tròn (Trạng thái hồ sơ)
      // Lưu ý: Thay đổi chuỗi 'hired', 'pending',... cho đúng với data của bạn
      final hiredQuery = await _firestore
          .collection('applications')
          .where('status', isEqualTo: 'hired')
          .count()
          .get();
      hiredApps = hiredQuery.count ?? 0;

      final pendingQuery = await _firestore
          .collection('applications')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      pendingApps = pendingQuery.count ?? 0;

      final interviewQuery = await _firestore
          .collection('applications')
          .where('status', isEqualTo: 'interviewing')
          .count()
          .get();
      interviewApps = interviewQuery.count ?? 0;

      final rejectedQuery = await _firestore
          .collection('applications')
          .where('status', isEqualTo: 'rejected')
          .count()
          .get();
      rejectedApps = rejectedQuery.count ?? 0;

      // Lấy dữ liệu biểu đồ đường (7 ngày qua)
      // Cần có trường 'createdAt' trong collection applications
      try {
        DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
        final recentApps = await _firestore
            .collection('applications')
            .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
            .get();

        List<double> tempWeekly = List.filled(7, 0);
        for (var doc in recentApps.docs) {
          if (doc.data().containsKey('createdAt')) {
            Timestamp ts = doc['createdAt'];
            DateTime date = ts.toDate();
            // weekday: 1 = T2, 7 = CN -> index 0 = T2, 6 = CN
            int dayIndex = date.weekday - 1;
            tempWeekly[dayIndex]++;
          }
        }
        weeklyApplications = tempWeekly;
      } catch (e) {
        print("Lấy dữ liệu tuần thất bại (có thể thiếu trường createdAt): $e");
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu từ Firebase: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
