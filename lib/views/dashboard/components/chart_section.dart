import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../responsive.dart';

class ChartSection extends StatelessWidget {
  const ChartSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        // Tính toán phần trăm cho biểu đồ tròn
        int total = controller.totalApplications;
        if (total == 0) total = 1; // Tránh chia cho 0

        double hiredPct = (controller.hiredApps / total) * 100;
        double pendingPct = (controller.pendingApps / total) * 100;
        double interviewPct = (controller.interviewApps / total) * 100;
        double rejectedPct = (controller.rejectedApps / total) * 100;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Thống kê lượt ứng tuyển (Tuần)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: defaultPadding),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const style = TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  );
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = Text('T2', style: style);
                                      break;
                                    case 1:
                                      text = Text('T3', style: style);
                                      break;
                                    case 2:
                                      text = Text('T4', style: style);
                                      break;
                                    case 3:
                                      text = Text('T5', style: style);
                                      break;
                                    case 4:
                                      text = Text('T6', style: style);
                                      break;
                                    case 5:
                                      text = Text('T7', style: style);
                                      break;
                                    case 6:
                                      text = Text('CN', style: style);
                                      break;
                                    default:
                                      text = Text('', style: style);
                                      break;
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: text,
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, controller.weeklyApplications[0]),
                                FlSpot(1, controller.weeklyApplications[1]),
                                FlSpot(2, controller.weeklyApplications[2]),
                                FlSpot(3, controller.weeklyApplications[3]),
                                FlSpot(4, controller.weeklyApplications[4]),
                                FlSpot(5, controller.weeklyApplications[5]),
                                FlSpot(6, controller.weeklyApplications[6]),
                              ],
                              isCurved: true,
                              color: primaryColor,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!Responsive.isMobile(context)) SizedBox(width: defaultPadding),
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thống Kê Trạng Thái Hồ Sơ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: defaultPadding),
                      SizedBox(
                        height: 250,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 50,
                                startDegreeOffset: -90,
                                sections: [
                                  if (hiredPct > 0)
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: hiredPct,
                                      showTitle: true,
                                      title: "${hiredPct.toStringAsFixed(0)}%",
                                      radius: 40,
                                      titleStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (pendingPct > 0)
                                    PieChartSectionData(
                                      color: Colors.blue,
                                      value: pendingPct,
                                      showTitle: true,
                                      title:
                                          "${pendingPct.toStringAsFixed(0)}%",
                                      radius: 40,
                                      titleStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (interviewPct > 0)
                                    PieChartSectionData(
                                      color: Colors.orange,
                                      value: interviewPct,
                                      showTitle: true,
                                      title:
                                          "${interviewPct.toStringAsFixed(0)}%",
                                      radius: 40,
                                      titleStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (rejectedPct > 0)
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: rejectedPct,
                                      showTitle: true,
                                      title:
                                          "${rejectedPct.toStringAsFixed(0)}%",
                                      radius: 40,
                                      titleStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  // Hiển thị vòng tròn rỗng nếu chưa có data
                                  if (hiredPct == 0 &&
                                      pendingPct == 0 &&
                                      interviewPct == 0 &&
                                      rejectedPct == 0)
                                    PieChartSectionData(
                                      color: Colors.grey.withOpacity(0.2),
                                      value: 100,
                                      showTitle: false,
                                      radius: 40,
                                    ),
                                ],
                              ),
                            ),
                            Positioned.fill(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: defaultPadding),
                                  Text(
                                    "${controller.totalApplications}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          height: 0.5,
                                        ),
                                  ),
                                  Text("Hồ sơ"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIndicator(
                            color: Colors.green,
                            text: "Đã tuyển",
                          ),
                          SizedBox(width: 10),
                          _buildIndicator(color: Colors.blue, text: "Đang chờ"),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIndicator(
                            color: Colors.orange,
                            text: "Phỏng vấn",
                          ),
                          SizedBox(width: 10),
                          _buildIndicator(color: Colors.red, text: "Từ chối"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildIndicator({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
