import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/candidate_controller.dart';
import '../../../data/models/user_model.dart';

class CandidateDetailDialog extends StatelessWidget {
  final UserModel candidate;

  const CandidateDetailDialog({
    super.key,
    required this.candidate,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: candidate.avatarUrl != null && candidate.avatarUrl!.isNotEmpty
                        ? NetworkImage(candidate.avatarUrl!)
                        : null,
                    child: candidate.avatarUrl == null || candidate.avatarUrl!.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.fullName.isNotEmpty ? candidate.fullName : candidate.username,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(candidate.email),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: candidate.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                candidate.isActive ? 'Hoạt động' : 'Đã khoá',
                                style: TextStyle(
                                  color: candidate.isActive ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: candidate.isVerified
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                candidate.isVerified ? 'Đã xác thực' : 'Chưa xác thực',
                                style: TextStyle(
                                  color: candidate.isVerified ? Colors.green : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildInfoRow('ID', candidate.uid),
              _buildInfoRow('Tài khoản (Username)', candidate.username),
              _buildInfoRow('Số điện thoại', candidate.phone.isNotEmpty ? candidate.phone : 'Chưa cập nhật'),
              _buildInfoRow('Ngày tham gia', candidate.createdAt != null ? dateFormat.format(candidate.createdAt!) : 'Không có thông tin'),
              _buildInfoRow('Số dư ví', currencyFormat.format(candidate.walletBalance)),
              
              const SizedBox(height: 32),
              const Text('Hành động quản trị', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Consumer<CandidateController>(
                builder: (context, controller, _) {
                  final isProcessing = controller.processingUserId == candidate.uid;
                  
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  final error = await controller.toggleUserStatus(
                                      candidate.uid, candidate.isActive);
                                  if (error != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
                                    );
                                  }
                                  if (context.mounted) Navigator.pop(context);
                                },
                          icon: Icon(candidate.isActive ? Icons.lock : Icons.lock_open),
                          label: Text(candidate.isActive ? 'Khoá tài khoản' : 'Mở khoá tài khoản'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: candidate.isActive ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  final error = await controller.toggleVerification(
                                      candidate.uid, candidate.isVerified);
                                  if (error != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
                                    );
                                  }
                                  if (context.mounted) Navigator.pop(context);
                                },
                          icon: Icon(candidate.isVerified ? Icons.cancel : Icons.check_circle),
                          label: Text(candidate.isVerified ? 'Huỷ xác thực' : 'Xác thực tài khoản'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: candidate.isVerified ? Colors.orange : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
