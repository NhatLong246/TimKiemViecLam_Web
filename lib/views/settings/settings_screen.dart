import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/settings_controller.dart';
import '../../data/models/config_model.dart';
import '../dashboard/components/header.dart';
import '../../controllers/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _minBalanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsController>().fetchConfig();
    });
  }

  @override
  void dispose() {
    _minBalanceController.dispose();
    super.dispose();
  }

  void _syncControllers(ConfigModel config) {
    if (_minBalanceController.text.isEmpty || 
        double.tryParse(_minBalanceController.text) != config.minimumBalanceToPost) {
      _minBalanceController.text = config.minimumBalanceToPost.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, _) {
        if (controller.config != null) {
          _syncControllers(controller.config!);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Icon(Icons.settings, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Cài đặt Hệ thống',
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
                      onPressed: controller.fetchConfig,
                    ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              if (controller.isLoading && controller.config == null)
                const Center(child: CircularProgressIndicator())
              else if (controller.errorMessage != null && controller.config == null)
                Center(
                  child: Text('Lỗi: ${controller.errorMessage}', style: const TextStyle(color: Colors.red)),
                )
              else if (controller.config != null)
                _buildSettingsSections(context, controller.config!, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSections(BuildContext context, ConfigModel config, SettingsController controller) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Cấu hình Hệ thống',
          icon: Icons.tune,
          children: [
            SwitchListTile(
              title: const Text('Duyệt tin tuyển dụng tự động'),
              subtitle: const Text('Nếu tắt, mọi tin tuyển dụng mới đều phải qua Admin duyệt.'),
              value: config.autoApproveJobs,
              onChanged: (val) {
                controller.updateConfig(config.copyWith(autoApproveJobs: val));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Số tiền tối thiểu để đăng bài'),
              subtitle: const Text('Yêu cầu Nhà tuyển dụng phải có đủ số dư trong ví để đăng bài.'),
              trailing: SizedBox(
                width: 150,
                child: TextField(
                  controller: _minBalanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixText: 'đ',
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    controller.updateConfig(config.copyWith(minimumBalanceToPost: amount));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật số dư tối thiểu'), backgroundColor: Colors.green),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        _buildSectionCard(
          title: 'Cài đặt Thông báo',
          icon: Icons.notifications,
          children: [
            SwitchListTile(
              title: const Text('Thông báo Người dùng mới'),
              subtitle: const Text('Nhận thông báo khi có Nhà tuyển dụng hoặc Ứng viên mới đăng ký.'),
              value: config.notifyNewUsers,
              onChanged: (val) {
                controller.updateConfig(config.copyWith(notifyNewUsers: val));
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Thông báo Khiếu nại mới'),
              subtitle: const Text('Nhận thông báo khi có người dùng gửi khiếu nại.'),
              value: config.notifyNewComplaints,
              onChanged: (val) {
                controller.updateConfig(config.copyWith(notifyNewComplaints: val));
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Thông báo Yêu cầu giải ngân'),
              subtitle: const Text('Nhận thông báo khi có yêu cầu rút tiền từ Ví.'),
              value: config.notifyNewDisbursements,
              onChanged: (val) {
                controller.updateConfig(config.copyWith(notifyNewDisbursements: val));
              },
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        _buildSectionCard(
          title: 'Quản lý Tài khoản (Profile)',
          icon: Icons.admin_panel_settings,
          children: [
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Đổi mật khẩu'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang được cập nhật')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Có'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await context.read<AuthController>().logout();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
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
              Icon(icon, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
