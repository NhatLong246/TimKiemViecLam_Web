import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../responsive.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Consumer<DashboardController>(
      builder: (context, dashboardController, child) {
        if (dashboardController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        List<SummaryInfo> summaryData = [
          SummaryInfo(
            title: "Tổng Người Dùng",
            value: "${dashboardController.totalUsers}",
            color: Colors.blueAccent,
            icon: Icons.people,
          ),
          SummaryInfo(
            title: "Việc Làm Đang Mở",
            value: "${dashboardController.openJobs}",
            color: Colors.purpleAccent,
            icon: Icons.work,
          ),
          SummaryInfo(
            title: "Lượt Ứng Tuyển",
            value: "${dashboardController.totalApplications}",
            color: Colors.orangeAccent,
            icon: Icons.file_present,
          ),
          SummaryInfo(
            title: "Công Ty",
            value: "${dashboardController.totalCompanies}",
            color: Colors.greenAccent,
            icon: Icons.business,
          ),
        ];

        return Column(
          children: [
            Responsive(
              mobile: InfoCardGridView(
                summaryData: summaryData,
                crossAxisCount: _size.width < 650 ? 2 : 4,
                childAspectRatio: _size.width < 650 ? 1.3 : 1,
              ),
              tablet: InfoCardGridView(summaryData: summaryData),
              desktop: InfoCardGridView(
                summaryData: summaryData,
                childAspectRatio: _size.width < 1400 ? 1.5 : 2.1,
              ),
            ),
          ],
        );
      },
    );
  }
}

class InfoCardGridView extends StatelessWidget {
  const InfoCardGridView({
    Key? key,
    required this.summaryData,
    this.crossAxisCount = 4,
    this.childAspectRatio = 2,
  }) : super(key: key);

  final List<SummaryInfo> summaryData;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => InfoCard(
        title: summaryData[index].title,
        value: summaryData[index].value,
        color: summaryData[index].color,
        icon: summaryData[index].icon,
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  }) : super(key: key);

  final String title, value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Icon(icon, color: Colors.white24, size: 20),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryInfo {
  final String title, value;
  final Color color;
  final IconData icon;

  SummaryInfo({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
}

List<SummaryInfo> summaryData = [
  SummaryInfo(
    title: "Tổng Người Dùng",
    value: "25,320",
    color: Colors.blueAccent,
    icon: Icons.people,
  ),
  SummaryInfo(
    title: "Việc Làm Đang Mở",
    value: "1,245",
    color: Colors.purpleAccent,
    icon: Icons.work,
  ),
  SummaryInfo(
    title: "Lượt Ứng Tuyển",
    value: "8,920",
    color: Colors.orangeAccent,
    icon: Icons.file_present,
  ),
  SummaryInfo(
    title: "Công Ty",
    value: "450",
    color: Colors.greenAccent,
    icon: Icons.business,
  ),
];
