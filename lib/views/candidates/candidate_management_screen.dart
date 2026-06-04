import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/candidate_controller.dart';
import '../../data/models/user_model.dart';
import '../dashboard/components/header.dart';
import '../post/components/job_status_filter_chip.dart';
import 'components/candidate_detail_dialog.dart';

class CandidateManagementScreen extends StatefulWidget {
  const CandidateManagementScreen({super.key});

  @override
  State<CandidateManagementScreen> createState() => _CandidateManagementScreenState();
}

class _CandidateManagementScreenState extends State<CandidateManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateController>().fetchCandidates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CandidateController>(
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
                  const Icon(Icons.file_present, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Quản lý Hồ sơ Ứng viên',
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
                      onPressed: controller.fetchCandidates,
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

  Widget _buildFilters(CandidateController controller) {
    return Row(
      children: [
        const Text('Trạng thái: ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CandidateController.statusFilters.map((status) {
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

  Widget _buildContentCard(BuildContext context, CandidateController controller) {
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
                'Danh sách Ứng viên',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên, email, SĐT...',
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
                      onPressed: controller.fetchCandidates,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.candidates.isEmpty)
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

  Widget _buildTable(BuildContext context, CandidateController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Ứng viên')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('SĐT')),
          DataColumn(label: Text('Xác thực')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: controller.candidates.map((candidate) {
          final isProcessing = controller.processingUserId == candidate.uid;

          return DataRow(
            onSelectChanged: (_) => _showDetailDialog(context, candidate),
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: candidate.avatarUrl != null && candidate.avatarUrl!.isNotEmpty
                          ? NetworkImage(candidate.avatarUrl!)
                          : null,
                      child: candidate.avatarUrl == null || candidate.avatarUrl!.isEmpty
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(candidate.fullName.isNotEmpty ? candidate.fullName : candidate.username,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              DataCell(Text(candidate.email)),
              DataCell(Text(candidate.phone.isNotEmpty ? candidate.phone : 'Chưa cập nhật')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: candidate.isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    candidate.isVerified ? 'Đã xác thực' : 'Chưa xác thực',
                    style: TextStyle(
                      color: candidate.isVerified ? Colors.green : Colors.orange,
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
                    color: candidate.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    candidate.isActive ? 'Hoạt động' : 'Đã khoá',
                    style: TextStyle(
                      color: candidate.isActive ? Colors.green : Colors.red,
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
                        onPressed: () => _showDetailDialog(context, candidate),
                        child: const Text('Xem'),
                      ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, UserModel candidate) {
    showDialog(
      context: context,
      builder: (_) => CandidateDetailDialog(candidate: candidate),
    );
  }
}
