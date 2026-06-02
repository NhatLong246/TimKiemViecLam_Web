import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controllers/user_controller.dart';
import '../../../../data/models/user_model.dart';

class UserDetailDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chi tiết Người dùng'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(user.email),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow('UID:', user.uid),
              _buildDetailRow('Username:', user.username),
              _buildDetailRow('Số điện thoại:', user.phone),
              _buildDetailRow('Vai trò:', user.roleLabel),
              if (user.role == 'employer' && user.companyName != null)
                _buildDetailRow('Tên công ty:', user.companyName!),
              if (user.role == 'employer')
                _buildDetailRow('Số dư ví:', '${user.walletBalance}'),
              _buildDetailRow(
                'Tình trạng xác thực:',
                user.isVerified ? 'Đã xác thực' : 'Chưa xác thực',
                valueColor: user.isVerified ? Colors.green : Colors.orange,
              ),
              _buildDetailRow(
                'Trạng thái tài khoản:',
                user.isActive ? 'Đang hoạt động' : 'Đã khoá',
                valueColor: user.isActive ? Colors.green : Colors.red,
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isVerified ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _handleToggleVerification(context),
                    icon: Icon(user.isVerified ? Icons.cancel : Icons.check_circle),
                    label: Text(user.isVerified ? 'Bỏ xác thực' : 'Xác thực Email'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _handleToggleStatus(context),
                    icon: Icon(user.isActive ? Icons.lock : Icons.lock_open),
                    label: Text(user.isActive ? 'Khoá tài khoản' : 'Mở khoá'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
    final controller = context.read<UserController>();
    final action = user.isVerified ? 'Bỏ xác thực' : 'Xác thực';
    final confirmed = await _showConfirmDialog(
      context,
      title: '$action người dùng',
      content: 'Bạn có chắc chắn muốn $action email cho ${user.fullName}?',
    );

    if (confirmed == true && context.mounted) {
      final error = await controller.toggleVerification(user.uid, user.isVerified);
      if (context.mounted) {
        if (error == null) {
          Navigator.pop(context);
          _showSnackBar(context, 'Đã cập nhật tình trạng xác thực', Colors.green);
        } else {
          _showSnackBar(context, 'Lỗi: $error', Colors.red);
        }
      }
    }
  }

  Future<void> _handleToggleStatus(BuildContext context) async {
    final controller = context.read<UserController>();
    final action = user.isActive ? 'Khoá' : 'Mở khoá';
    final confirmed = await _showConfirmDialog(
      context,
      title: '$action tài khoản',
      content: 'Bạn có chắc chắn muốn $action tài khoản của ${user.fullName}?',
    );

    if (confirmed == true && context.mounted) {
      final error = await controller.toggleUserStatus(user.uid, user.isActive);
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
