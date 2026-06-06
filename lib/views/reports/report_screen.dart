import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants.dart';
import '../../responsive.dart';
import '../../controllers/job_post_controller.dart';
import '../../controllers/complaint_controller.dart';
import '../../controllers/disbursement_controller.dart';
import '../dashboard/components/header.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobCtrl = context.read<JobPostController>();
      if (jobCtrl.totalCount == 0 && !jobCtrl.isLoading) {
        jobCtrl.fetchJobPosts();
      }

      final complaintCtrl = context.read<ComplaintController>();
      if (complaintCtrl.totalCount == 0 && !complaintCtrl.isLoading) {
        complaintCtrl.fetchComplaints();
      }

      final disbCtrl = context.read<DisbursementController>();
      if (disbCtrl.totalCount == 0 && !disbCtrl.isLoading) {
        disbCtrl.fetchDisbursements();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                Icon(Icons.pie_chart, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Báo Cáo Thống Kê",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildFinancialSummary(),
                      const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        _buildJobStatusChart(),
                      if (Responsive.isMobile(context))
                        const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        _buildComplaintStatusChart(),

                      if (!Responsive.isMobile(context))
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildJobStatusChart()),
                            const SizedBox(width: defaultPadding),
                            Expanded(child: _buildComplaintStatusChart()),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Consumer<DisbursementController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        double totalDisbursed = 0;
        double pendingAmount = 0;
        int clearedCount = 0;
        int pendingCount = 0;

        for (var n in controller.notices) { // accesses _filteredNotices, we might want to use total instead. but notices is fine if no filter is applied
          if (n.status == 'cleared') {
            totalDisbursed += n.amount;
            clearedCount++;
          } else if (n.status == 'pending_admin') {
            pendingAmount += n.amount;
            pendingCount++;
          }
        }

        return Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Báo cáo Giải Ngân",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Tổng đã giải ngân",
                      value: _formatCurrency(totalDisbursed),
                      subtitle: "$clearedCount giao dịch",
                      color: Colors.green,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: _buildStatCard(
                      title: "Đang chờ duyệt",
                      value: _formatCurrency(pendingAmount),
                      subtitle: "$pendingCount giao dịch",
                      color: Colors.orange,
                      icon: Icons.hourglass_empty,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildJobStatusChart() {
    return Consumer<JobPostController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final int total = controller.totalCount == 0 ? 1 : controller.totalCount;
        final int draft = controller.countByStatus('draft');
        final int pending = controller.countByStatus('pending');
        final int approved = controller.countByStatus('approved');
        final int active = controller.countByStatus('active');
        final int closed = controller.countByStatus('closed');
        final int rejected = controller.countByStatus('rejected');

        return _buildPieChartCard(
          title: "Trạng thái Tin Tuyển Dụng",
          total: controller.totalCount,
          sections: [
            if (pending > 0) _buildPieSection(pending / total, Colors.orange, "$pending"),
            if (approved > 0) _buildPieSection(approved / total, Colors.blue, "$approved"),
            if (active > 0) _buildPieSection(active / total, Colors.green, "$active"),
            if (closed > 0) _buildPieSection(closed / total, Colors.grey, "$closed"),
            if (rejected > 0) _buildPieSection(rejected / total, Colors.red, "$rejected"),
            if (draft > 0) _buildPieSection(draft / total, Colors.brown, "$draft"),
            if (controller.totalCount == 0)
              PieChartSectionData(color: Colors.grey.withOpacity(0.2), value: 100, showTitle: false, radius: 40),
          ],
          legends: [
            _buildIndicator(color: Colors.orange, text: "Chờ duyệt"),
            _buildIndicator(color: Colors.blue, text: "Đã duyệt"),
            _buildIndicator(color: Colors.green, text: "Đang tuyển"),
            _buildIndicator(color: Colors.grey, text: "Đã đóng"),
            _buildIndicator(color: Colors.red, text: "Từ chối"),
            _buildIndicator(color: Colors.brown, text: "Nháp"),
          ],
        );
      },
    );
  }

  Widget _buildComplaintStatusChart() {
    return Consumer<ComplaintController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final int total = controller.totalCount == 0 ? 1 : controller.totalCount;
        final int pending = controller.countByStatus('pending');
        final int approved = controller.countByStatus('approved');
        final int rejected = controller.countByStatus('rejected');

        return _buildPieChartCard(
          title: "Trạng thái Khiếu Nại",
          total: controller.totalCount,
          sections: [
            if (pending > 0) _buildPieSection(pending / total, Colors.orange, "$pending"),
            if (approved > 0) _buildPieSection(approved / total, Colors.green, "$approved"),
            if (rejected > 0) _buildPieSection(rejected / total, Colors.red, "$rejected"),
            if (controller.totalCount == 0)
              PieChartSectionData(color: Colors.grey.withOpacity(0.2), value: 100, showTitle: false, radius: 40),
          ],
          legends: [
            _buildIndicator(color: Colors.orange, text: "Chờ xử lý"),
            _buildIndicator(color: Colors.green, text: "Chấp thuận"),
            _buildIndicator(color: Colors.red, text: "Từ chối"),
          ],
        );
      },
    );
  }

  Widget _buildPieChartCard({
    required String title,
    required int total,
    required List<PieChartSectionData> sections,
    required List<Widget> legends,
  }) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: defaultPadding),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                    sections: sections,
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$total",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              height: 0.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text("Tổng"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: legends,
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(double value, Color color, String title) {
    return PieChartSectionData(
      color: color,
      value: value * 100,
      showTitle: true,
      title: title,
      radius: 40,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildIndicator({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final s = amount.toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer.toString()}₫';
  }
}
