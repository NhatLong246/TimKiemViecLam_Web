import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controllers/employer_controller.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/job_post_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/services/job_post_service.dart';
import '../../../../data/services/transaction_service.dart';

class EmployerDetailDialog extends StatefulWidget {
  final UserModel employer;
  final int totalJobs;

  const EmployerDetailDialog({
    super.key,
    required this.employer,
    required this.totalJobs,
  });

  @override
  State<EmployerDetailDialog> createState() => _EmployerDetailDialogState();
}

class _EmployerDetailDialogState extends State<EmployerDetailDialog> {
  final JobPostService _jobPostService = JobPostService();
  final TransactionService _transactionService = TransactionService();
  late NumberFormat currencyFormat;

  @override
  void initState() {
    super.initState();
    currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 800,
        height: 600,
        child: DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                tabs: [
                  Tab(text: 'Thông tin chung'),
                  Tab(text: 'Tin tuyển dụng'),
                  Tab(text: 'Lịch sử giao dịch'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildGeneralInfoTab(context),
                    _buildJobPostsTab(),
                    _buildTransactionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chi tiết Nhà tuyển dụng',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoTab(BuildContext context) {
    final formattedBalance = currencyFormat.format(widget.employer.walletBalance);
    final employer = widget.employer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: employer.avatarUrl != null && employer.avatarUrl!.isNotEmpty
                    ? NetworkImage(employer.avatarUrl!)
                    : null,
                child: employer.avatarUrl == null || employer.avatarUrl!.isEmpty
                    ? const Icon(Icons.business, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employer.companyName ?? 'Chưa cập nhật tên công ty',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(employer.email),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow('Người đại diện:', employer.fullName),
          _buildDetailRow('SĐT Liên hệ:', employer.phone),
          _buildDetailRow('Username:', employer.username),
          _buildDetailRow('Số dư ví:', formattedBalance, valueColor: Colors.blueAccent),
          _buildDetailRow('Số lượng tin đã đăng:', widget.totalJobs.toString()),
          _buildDetailRow(
            'Tình trạng xác thực:',
            employer.isVerified ? 'Đã xác thực' : 'Chưa xác thực',
            valueColor: employer.isVerified ? Colors.green : Colors.orange,
          ),
          _buildDetailRow(
            'Trạng thái tài khoản:',
            employer.isActive ? 'Đang hoạt động' : 'Đã khoá',
            valueColor: employer.isActive ? Colors.green : Colors.red,
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: employer.isVerified ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _handleToggleVerification(context),
                icon: Icon(employer.isVerified ? Icons.cancel : Icons.check_circle),
                label: Text(employer.isVerified ? 'Bỏ xác thực' : 'Xác thực Email'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: employer.isActive ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _handleToggleStatus(context),
                icon: Icon(employer.isActive ? Icons.lock : Icons.lock_open),
                label: Text(employer.isActive ? 'Khoá tài khoản' : 'Mở khoá'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobPostsTab() {
    return FutureBuilder<List<JobPostModel>>(
      future: _jobPostService.fetchJobPostsByEmployer(widget.employer.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) {
          return const Center(child: Text('Chưa có tin tuyển dụng nào.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Tiêu đề')),
              DataColumn(label: Text('Ngày đăng')),
              DataColumn(label: Text('Số lượng')),
              DataColumn(label: Text('Trạng thái')),
            ],
            rows: jobs.map((job) {
              final dateStr = job.createdAt != null
                  ? DateFormat('dd/MM/yyyy').format(job.createdAt!)
                  : 'N/A';
              return DataRow(cells: [
                DataCell(Text(job.title)),
                DataCell(Text(dateStr)),
                DataCell(Text('${job.slots}')),
                DataCell(Text(job.status)),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    return FutureBuilder<List<TransactionModel>>(
      future: _transactionService.fetchTransactionsByUser(widget.employer.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return const Center(child: Text('Chưa có giao dịch nào.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Loại')),
              DataColumn(label: Text('Số dư trước')),
              DataColumn(label: Text('Số tiền')),
              DataColumn(label: Text('Số dư sau')),
              DataColumn(label: Text('Ngày')),
            ],
            rows: transactions.map((txn) {
              final dateStr = txn.createdAt != null
                  ? DateFormat('dd/MM/yy HH:mm').format(txn.createdAt!)
                  : 'N/A';
              final isPositive = txn.type == 'deposit' || txn.type == 'refund';
              return DataRow(cells: [
                DataCell(Text(txn.typeLabel)),
                DataCell(Text(currencyFormat.format(txn.balanceBefore))),
                DataCell(
                  Text(
                    '${isPositive ? '+' : '-'}${currencyFormat.format(txn.amount)}',
                    style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(Text(currencyFormat.format(txn.balanceAfter))),
                DataCell(Text(dateStr)),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggleVerification(BuildContext context) async {
    final controller = context.read<EmployerController>();
    final action = widget.employer.isVerified ? 'Bỏ xác thực' : 'Xác thực';
    final confirmed = await _showConfirmDialog(
      context,
      title: '$action nhà tuyển dụng',
      content: 'Bạn có chắc chắn muốn $action cho ${widget.employer.companyName ?? widget.employer.fullName}?',
    );

    if (confirmed == true && context.mounted) {
      final error = await controller.toggleVerification(widget.employer.uid, widget.employer.isVerified);
      if (context.mounted) {
        if (error == null) {
          Navigator.pop(context); // Optional: close dialog to refresh list state easily
          _showSnackBar(context, 'Đã cập nhật tình trạng xác thực', Colors.green);
        } else {
          _showSnackBar(context, 'Lỗi: $error', Colors.red);
        }
      }
    }
  }

  Future<void> _handleToggleStatus(BuildContext context) async {
    final controller = context.read<EmployerController>();
    final action = widget.employer.isActive ? 'Khoá' : 'Mở khoá';
    final confirmed = await _showConfirmDialog(
      context,
      title: '$action tài khoản',
      content: 'Bạn có chắc chắn muốn $action tài khoản của ${widget.employer.companyName ?? widget.employer.fullName}?',
    );

    if (confirmed == true && context.mounted) {
      final error = await controller.toggleUserStatus(widget.employer.uid, widget.employer.isActive);
      if (context.mounted) {
        if (error == null) {
          Navigator.pop(context);
          _showSnackBar(context, 'Đã cập nhật trạng thái tài khoản', Colors.green);
        } else {
          _showSnackBar(context, 'Lỗi: $error', Colors.red);
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context,
      {required String title, required String content}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor),
    );
  }
}
