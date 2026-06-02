import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/disbursement_controller.dart';
import '../../data/models/disbursement_model.dart';
import '../dashboard/components/header.dart';
import '../post/components/job_status_filter_chip.dart';
import 'components/disbursement_detail_dialog.dart';

class DisbursementScreen extends StatefulWidget {
  const DisbursementScreen({super.key});

  @override
  State<DisbursementScreen> createState() => _DisbursementScreenState();
}

class _DisbursementScreenState extends State<DisbursementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DisbursementController>().fetchDisbursements();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DisbursementController>(
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
                  Icon(Icons.monetization_on, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Yêu cầu Giải ngân',
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
                      onPressed: controller.fetchDisbursements,
                    ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              _buildStatusFilters(controller),
              const SizedBox(height: defaultPadding),
              _buildContentCard(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilters(DisbursementController controller) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DisbursementController.statusFilters.map((status) {
        final isSelected = controller.statusFilter == status;
        final count = status == 'all'
            ? controller.totalCount
            : controller.countByStatus(status);
        final label = status == 'all'
            ? 'Tất cả ($count)'
            : '${DisbursementModel.statusLabel(status)} ($count)';

        return JobStatusFilterChip(
          label: label,
          isSelected: isSelected,
          onTap: () => controller.setStatusFilter(status),
        );
      }).toList(),
    );
  }

  Widget _buildContentCard(
      BuildContext context, DisbursementController controller) {
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
                'Danh sách yêu cầu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm công việc, nhà tuyển dụng...',
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
                      onPressed: controller.fetchDisbursements,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.notices.isEmpty)
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

  Widget _buildTable(BuildContext context, DisbursementController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Mã YC')),
          DataColumn(label: Text('Công việc')),
          DataColumn(label: Text('Nhà tuyển dụng')),
          DataColumn(label: Text('Ngày làm')),
          DataColumn(label: Text('Số tiền')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: controller.notices.map((notice) {
          final isProcessing = controller.processingNoticeId == notice.noticeId;

          return DataRow(
            onSelectChanged: (_) => _showDetailDialog(context, notice),
            cells: [
              DataCell(Text(
                notice.noticeId.substring(0, 8),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    notice.jobTitle ?? notice.jobId,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(notice.employerName ?? notice.employerId)),
              DataCell(Text(notice.workDate)),
              DataCell(Text(
                notice.amountDisplay,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              )),
              DataCell(Text(DisbursementModel.statusLabel(notice.status))),
              DataCell(
                isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(
                        onPressed: () => _showDetailDialog(context, notice),
                        child: Text(notice.status == 'pending_admin' ? 'Giải ngân' : 'Xem'),
                      ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, DisbursementModel notice) {
    showDialog(
      context: context,
      builder: (_) => DisbursementDetailDialog(notice: notice),
    );
  }
}
