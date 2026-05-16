import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/menu_app_controller.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPage = context.watch<MenuAppController>().currentPage;

    void navigate(String page) {
      context.read<MenuAppController>().navigateTo(page);
      final scaffold = Scaffold.maybeOf(context);
      if (scaffold?.isDrawerOpen ?? false) {
        Navigator.of(context).pop();
      }
    }

    return Drawer(
      backgroundColor: sidebarColor,
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work, color: Colors.blueAccent, size: 30),
                SizedBox(width: 10),
                Text(
                  "VIECNOW ADMIN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "MAIN MENU",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          DrawerListTile(
            title: "Bảng điều khiển",
            icon: Icons.dashboard,
            press: () => navigate(MenuAppController.pageDashboard),
            isActive: currentPage == MenuAppController.pageDashboard,
          ),
          DrawerListTile(
            title: "Quản lý người dùng",
            icon: Icons.people,
            press: () {},
          ),
          DrawerListTile(
            title: "Nhà tuyển dụng",
            icon: Icons.business,
            press: () {},
          ),
          DrawerListTile(
            title: "Tin tuyển dụng",
            icon: Icons.article,
            press: () => navigate(MenuAppController.pageJobs),
            isActive: currentPage == MenuAppController.pageJobs,
          ),
          DrawerListTile(
            title: "Hồ sơ ứng viên (CV)",
            icon: Icons.file_present,
            press: () {},
          ),
          DrawerListTile(
            title: "Danh mục ngành nghề",
            icon: Icons.category,
            press: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "SYSTEM",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          DrawerListTile(
            title: "Cài đặt",
            icon: Icons.settings,
            press: () {},
          ),
          DrawerListTile(
            title: "Đăng xuất",
            icon: Icons.logout,
            press: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Đăng xuất'),
      content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Có'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await context.read<AuthController>().logout();
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.press,
    this.isActive = false,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white54,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(color: isActive ? Colors.white : Colors.white54),
      ),
      selected: isActive,
      selectedTileColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
