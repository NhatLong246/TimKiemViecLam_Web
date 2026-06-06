import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/complaint_controller.dart';
import '../../data/models/disbursement_complaint_model.dart';
import '../dashboard/components/header.dart';
import '../post/components/job_status_filter_chip.dart';
import 'components/complaint_detail_dialog.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintController>().fetchComplaints();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintController>(
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
                  Icon(Icons.report_problem, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Khiếu nại giải ngân',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (!controller.isLoading)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Tải lại',
                      onPressed: controller.fetchComplaints,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Duyệt hoặc từ chối từng ứng viên bị NTD khiếu nại trước khi giải ngân.',
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

  Widget _buildStatusFilters(ComplaintController controller) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ComplaintController.statusFilters.map((status) {
        final count = status == 'all'
            ? controller.totalCount
            : controller.countByStatus(status);
        final label = status == 'all'
            ? 'Tất cả ($count)'
            : '${DisbursementComplaintModel.statusLabel(status)} ($count)';
        return JobStatusFilterChip(
          label: label,
          isSelected: controller.statusFilter == status,
          onTap: () => controller.setStatusFilter(status),
        );
      }).toList(),
    );
  }

  Widget _buildContentCard(
    BuildContext context,
    ComplaintController controller,
  ) {
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
                'Danh sách khiếu nại từ NTD',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm công việc, ứng viên...',
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
            _ErrorState(controller: controller)
          else if (controller.complaints.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Text('Không có khiếu nại giải ngân'),
              ),
            )
          else
            _buildTable(context, controller),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, ComplaintController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Mã yêu cầu')),
          DataColumn(label: Text('Công việc')),
          DataColumn(label: Text('Ứng viên')),
          DataColumn(label: Text('Nhà tuyển dụng')),
          DataColumn(label: Text('Đề xuất đền bù')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: controller.complaints.map((complaint) {
          final isProcessing =
              controller.processingComplaintId == complaint.rowId;
          return DataRow(
            onSelectChanged: (_) => _showDetailDialog(context, complaint),
            cells: [
              DataCell(
                Text(
                  _shortId(complaint.noticeId),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 190,
                  child: Text(
                    complaint.jobTitle.isEmpty
                        ? complaint.jobId
                        : complaint.jobTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(complaint.candidateName ?? complaint.candidateId)),
              DataCell(Text(complaint.employerName ?? complaint.employerId)),
              DataCell(Text(_money(complaint.proposedCompensation))),
              DataCell(
                Text(DisbursementComplaintModel.statusLabel(complaint.status)),
              ),
              DataCell(
                isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: () => _showDetailDialog(context, complaint),
                        child: Text(complaint.isPending ? 'Xử lý' : 'Xem'),
                      ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    DisbursementComplaintModel complaint,
  ) {
    showDialog(
      context: context,
      builder: (_) => ComplaintDetailDialog(complaint: complaint),
    );
  }

  static String _shortId(String value) =>
      value.length <= 8 ? value : value.substring(0, 8);

  static String _money(double value) => '${value.toStringAsFixed(0)}đ';
}

class _ErrorState extends StatelessWidget {
  final ComplaintController controller;

  const _ErrorState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text('Lỗi: ${controller.errorMessage}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.fetchComplaints,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
