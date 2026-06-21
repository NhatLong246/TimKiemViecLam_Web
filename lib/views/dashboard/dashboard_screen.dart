import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../responsive.dart';
import 'components/header.dart';
import 'components/summary_cards.dart';
import 'components/chart_section.dart';

import 'package:provider/provider.dart';
import '../../../controllers/dashboard_controller.dart';
import '../components/date_filter_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().fetchDashboardData();
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
                Icon(Icons.bar_chart, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Hệ Thống Quản Lý",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                DateFilterWidget(
                  onDateRangeChanged: (start, end) {
                    context.read<DashboardController>().setDateFilter(start, end);
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<DashboardController>().fetchDashboardData();
                  },
                  tooltip: 'Làm mới dữ liệu',
                )
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
                      SummaryCards(),
                      SizedBox(height: defaultPadding),
                      ChartSection(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context)) SizedBox(width: defaultPadding),
                // Có thể thêm cột thông báo/lịch sử bên phải ở đây cho Desktop nếu cần
              ],
            )
          ],
        ),
      ),
    );
  }
}
