import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/employer_controller.dart';
import '../../data/models/user_model.dart';
import '../dashboard/components/header.dart';
import '../post/components/job_status_filter_chip.dart';
import 'components/employer_detail_dialog.dart';

class EmployerManagementScreen extends StatefulWidget {
  const EmployerManagementScreen({super.key});

  @override
  State<EmployerManagementScreen> createState() => _EmployerManagementScreenState();
}

class _EmployerManagementScreenState extends State<EmployerManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployerController>().fetchEmployers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployerController>(
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
                  Icon(Icons.business, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Quản lý Nhà tuyển dụng',
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
                      onPressed: controller.fetchEmployers,
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

  Widget _buildFilters(EmployerController controller) {
    return Row(
      children: [
        const Text('Trạng thái: ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EmployerController.statusFilters.map((status) {
            final isSelected = controller.statusFilter == status;
            String label;
            switch (status) {
              case 'all': label = 'Tất cả (${controller.totalCount})'; break;
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
    );
  }

  Widget _buildContentCard(BuildContext context, EmployerController controller) {
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
                'Danh sách Nhà tuyển dụng',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo công ty, tên, email...',
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
                      onPressed: controller.fetchEmployers,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.employers.isEmpty)
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

  Widget _buildTable(BuildContext context, EmployerController controller) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Công ty')),
          DataColumn(label: Text('Người đại diện')),
          DataColumn(label: Text('Số dư ví')),
          DataColumn(label: Text('Tin đã đăng')),
          DataColumn(label: Text('Xác thực')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: controller.employers.map((employer) {
          final isProcessing = controller.processingUserId == employer.uid;
          final totalJobs = controller.getJobCount(employer.uid);

          return DataRow(
            onSelectChanged: (_) => _showDetailDialog(context, employer, totalJobs),
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: employer.avatarUrl != null && employer.avatarUrl!.isNotEmpty
                          ? NetworkImage(employer.avatarUrl!)
                          : null,
                      child: employer.avatarUrl == null || employer.avatarUrl!.isEmpty
                          ? const Icon(Icons.business, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(employer.companyName ?? 'Chưa cập nhật',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              DataCell(Text(employer.fullName.isNotEmpty ? employer.fullName : employer.username)),
              DataCell(Text(
                currencyFormat.format(employer.walletBalance),
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              )),
              DataCell(Text(totalJobs.toString())),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: employer.isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    employer.isVerified ? 'Đã xác thực' : 'Chưa xác thực',
                    style: TextStyle(
                      color: employer.isVerified ? Colors.green : Colors.orange,
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
                    color: employer.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    employer.isActive ? 'Hoạt động' : 'Đã khoá',
                    style: TextStyle(
                      color: employer.isActive ? Colors.green : Colors.red,
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
                        onPressed: () => _showDetailDialog(context, employer, totalJobs),
                        child: const Text('Xem'),
                      ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, UserModel employer, int totalJobs) {
    showDialog(
      context: context,
      builder: (_) => EmployerDetailDialog(employer: employer, totalJobs: totalJobs),
    );
  }
}
