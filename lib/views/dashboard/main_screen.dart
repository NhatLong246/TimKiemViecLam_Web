import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../post/job_posts_screen.dart';
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
      case MenuAppController.pageDashboard:
      default:
        return DashboardScreen();
    }
  }
}
