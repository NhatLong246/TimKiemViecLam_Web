import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/user_controller.dart';
import '../../data/models/user_model.dart';
import '../dashboard/components/header.dart';
import '../post/components/job_status_filter_chip.dart';
import 'components/user_detail_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserController>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Icon(Icons.people, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Quản lý Người dùng',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (!controller.isLoading)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Tải lại',
                      onPressed: controller.fetchUsers,
                    ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              _buildFilters(controller),
              const SizedBox(height: defaultPadding),
              _buildContentCard(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(UserController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Vai trò: ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserController.roleFilters.map((role) {
                final isSelected = controller.roleFilter == role;
                final count = role == 'all'
                    ? controller.totalCount
                    : controller.countByRole(role);
                String label;
                switch (role) {
                  case 'all': label = 'Tất cả ($count)'; break;
                  case 'candidate': label = 'Ứng viên ($count)'; break;
                  case 'employer': label = 'Nhà tuyển dụng ($count)'; break;
                  case 'admin': label = 'Admin ($count)'; break;
                  default: label = role;
                }

                return JobStatusFilterChip(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => controller.setRoleFilter(role),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Trạng thái: ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserController.statusFilters.map((status) {
                final isSelected = controller.statusFilter == status;
                String label;
                switch (status) {
                  case 'all': label = 'Tất cả'; break;
                  case 'active': label = 'Đang hoạt động'; break;
                  case 'locked': label = 'Đã khoá'; break;
                  default: label = status;
                }

                return JobStatusFilterChip(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => controller.setStatusFilter(status),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context, UserController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Danh sách người dùng',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm tên, email, sđt...',
                    isDense: true,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: controller.setSearchQuery,
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          if (controller.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else if (controller.errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text('Lỗi: ${controller.errorMessage}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.fetchUsers,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.users.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Text('Không có dữ liệu'),
              ),
            )
          else
            _buildTable(context, controller),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, UserController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Họ tên')),
          DataColumn(label: Text('Vai trò')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Xác thực')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: controller.users.map((user) {
          final isProcessing = controller.processingUserId == user.uid;

          return DataRow(
            onSelectChanged: (_) => _showDetailDialog(context, user),
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(user.fullName.isNotEmpty ? user.fullName : user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              DataCell(Text(user.roleLabel)),
              DataCell(Text(user.email)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.isVerified ? 'Đã xác thực' : 'Chưa xác thực',
                    style: TextStyle(
                      color: user.isVerified ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.isActive ? 'Hoạt động' : 'Đã khoá',
                    style: TextStyle(
                      color: user.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(
                        onPressed: () => _showDetailDialog(context, user),
                        child: const Text('Xem'),
                      ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => UserDetailDialog(user: user),
    );
  }
}
