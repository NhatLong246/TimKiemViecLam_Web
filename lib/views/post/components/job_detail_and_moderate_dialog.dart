import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/job_post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../controllers/user_controller.dart';
import '../../../constants.dart';

class JobDetailAndModerateDialog extends StatefulWidget {
  final JobPostModel jobPost;
  final Function(JobPostModel) onApprove;
  final Function(JobPostModel, String) onReject;

  const JobDetailAndModerateDialog({
    Key? key,
    required this.jobPost,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  State<JobDetailAndModerateDialog> createState() => _JobDetailAndModerateDialogState();
}

class _JobDetailAndModerateDialogState extends State<JobDetailAndModerateDialog> {
  UserModel? employer;
  bool isLoadingEmployer = true;
  bool showRejectForm = false;
  
  String? selectedRejectReason;
  final customReasonController = TextEditingController();

  final List<String> predefinedReasons = [
    'Hồ sơ doanh nghiệp chưa đầy đủ thông tin.',
    'Tài khoản doanh nghiệp chưa được xác thực (Vui lòng xác minh danh tính).',
    'Nội dung tin tuyển dụng không hợp lệ / vi phạm chính sách.',
    'Mức lương hoặc điều kiện làm việc không rõ ràng.',
    'Khác (Nhập lý do bên dưới)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchEmployer();
  }

  Future<void> _fetchEmployer() async {
    final userController = context.read<UserController>();
    final user = await userController.getUserById(widget.jobPost.employerId);
    if (mounted) {
      setState(() {
        employer = user;
        isLoadingEmployer = false;
      });
    }
  }

  @override
  void dispose() {
    customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 32),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildEmployerInfo()),
                  const VerticalDivider(width: 32),
                  Expanded(flex: 2, child: _buildJobInfo()),
                ],
              ),
            ),
            if (showRejectForm) ...[
              const Divider(height: 32),
              _buildRejectForm(),
            ],
            const Divider(height: 32),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Duyệt Tin Tuyển Dụng',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildEmployerInfo() {
    if (isLoadingEmployer) {
      return const Center(child: CircularProgressIndicator());
    }
    if (employer == null) {
      return const Center(child: Text('Không tìm thấy thông tin Doanh nghiệp', style: TextStyle(color: Colors.red)));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: primaryColor),
              const SizedBox(width: 8),
              Text('Thông tin Doanh nghiệp', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tên công ty', employer!.companyName ?? 'Chưa cập nhật', isBold: true),
          _buildInfoRow('Mã số thuế', employer!.companyTaxCode ?? 'Chưa cập nhật'),
          _buildInfoRow('Quy mô', employer!.companySize ?? 'Chưa cập nhật'),
          _buildInfoRow('Loại hình', employer!.businessType ?? 'Chưa cập nhật'),
          const SizedBox(height: 8),
          const Text('Địa chỉ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(employer!.companyAddress ?? 'Chưa cập nhật', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Xác thực:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(width: 8),
              if (employer!.isVerified)
                const Chip(
                  label: Text('Đã xác thực', style: TextStyle(color: Colors.green, fontSize: 12)),
                  backgroundColor: Color(0xFFE8F5E9),
                  padding: EdgeInsets.zero,
                )
              else
                const Chip(
                  label: Text('Chưa xác thực', style: TextStyle(color: Colors.red, fontSize: 12)),
                  backgroundColor: Color(0xFFFFEBEE),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: primaryColor),
              const SizedBox(width: 8),
              Text('Chi tiết Công việc', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.jobPost.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildIconInfo(Icons.category, JobPostModel.categoryLabel(widget.jobPost.category)),
              _buildIconInfo(Icons.access_time, JobPostModel.jobTypeLabel(widget.jobPost.jobType)),
              _buildIconInfo(Icons.monetization_on, widget.jobPost.salaryDisplay),
              _buildIconInfo(Icons.people, '${widget.jobPost.filledSlots}/${widget.jobPost.slots} slot'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.jobPost.locationDisplay.isNotEmpty ? widget.jobPost.locationDisplay : 'Chưa cập nhật địa điểm',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Mô tả công việc:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(widget.jobPost.description, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lý do từ chối:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: predefinedReasons.map((reason) {
            return ChoiceChip(
              label: Text(reason),
              selected: selectedRejectReason == reason,
              onSelected: (selected) {
                setState(() {
                  selectedRejectReason = selected ? reason : null;
                });
              },
            );
          }).toList(),
        ),
        if (selectedRejectReason == 'Khác (Nhập lý do bên dưới)') ...[
          const SizedBox(height: 12),
          TextField(
            controller: customReasonController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Nhập lý do từ chối chi tiết...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    if (showRejectForm) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                showRejectForm = false;
                selectedRejectReason = null;
                customReasonController.clear();
              });
            },
            child: const Text('Huỷ từ chối'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              String finalReason = selectedRejectReason ?? '';
              if (finalReason == 'Khác (Nhập lý do bên dưới)') {
                finalReason = customReasonController.text.trim();
              }
              if (finalReason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn hoặc nhập lý do từ chối')));
                return;
              }
              widget.onReject(widget.jobPost, finalReason);
              Navigator.pop(context);
            },
            child: const Text('Xác nhận Từ Chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        if (widget.jobPost.status == 'pending' || widget.jobPost.status == 'draft') ...[
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            icon: const Icon(Icons.cancel, size: 18, color: Colors.white),
            label: const Text('Từ chối', style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                showRejectForm = true;
              });
            },
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            icon: const Icon(Icons.check_circle, size: 18, color: Colors.white),
            label: const Text('Duyệt tin', style: TextStyle(color: Colors.white)),
            onPressed: () {
              widget.onApprove(widget.jobPost);
              Navigator.pop(context);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? Colors.black87 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
