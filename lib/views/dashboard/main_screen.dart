import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../post/job_posts_screen.dart';
import '../disbursements/disbursement_screen.dart';
import '../complaints/complaint_screen.dart';
import '../users/user_management_screen.dart';
import '../employers/employer_management_screen.dart';
import '../candidates/candidate_management_screen.dart';
import '../categories/category_management_screen.dart';
import '../settings/settings_screen.dart';
import '../reports/report_screen.dart';
import 'components/side_menu.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuAppController>(
      builder: (context, menu, _) {
        return Scaffold(
          key: menu.scaffoldKey,
          drawer: const SideMenu(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  const Expanded(flex: 1, child: SideMenu()),
                Expanded(flex: 5, child: _buildContent(menu.currentPage)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(String page) {
    switch (page) {
      case MenuAppController.pageJobs:
        return const JobPostsScreen();
      case MenuAppController.pageDisbursements:
        return const DisbursementScreen();
      case MenuAppController.pageComplaints:
        return const ComplaintScreen();
      case MenuAppController.pageUsers:
        return const UserManagementScreen();
      case MenuAppController.pageEmployers:
        return const EmployerManagementScreen();
      case MenuAppController.pageCandidates:
        return const CandidateManagementScreen();
      case MenuAppController.pageCategories:
        return const CategoryManagementScreen();
      case MenuAppController.pageSettings:
        return const SettingsScreen();
      case MenuAppController.pageReports:
        return const ReportScreen();
      case MenuAppController.pageDashboard:
      default:
        return DashboardScreen();
    }
  }
}
