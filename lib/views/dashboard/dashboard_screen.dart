import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../responsive.dart';
import 'components/header.dart';
import 'components/summary_cards.dart';
import 'components/chart_section.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              children: [
                Icon(Icons.bar_chart, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  "Hệ Thống Quản Lý",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
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
