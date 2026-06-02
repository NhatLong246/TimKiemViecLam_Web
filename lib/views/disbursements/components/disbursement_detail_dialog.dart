import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/disbursement_controller.dart';
import '../../../../data/models/disbursement_model.dart';

class DisbursementDetailDialog extends StatefulWidget {
  final DisbursementModel notice;

  const DisbursementDetailDialog({super.key, required this.notice});

  @override
  State<DisbursementDetailDialog> createState() =>
      _DisbursementDetailDialogState();
}

class _DisbursementDetailDialogState extends State<DisbursementDetailDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;

    return AlertDialog(
      title: const Text('Chi tiết Yêu cầu giải ngân'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Mã YC:', notice.noticeId),
            _buildDetailRow('Job ID:', notice.jobId),
            _buildDetailRow('Công việc:', notice.jobTitle ?? 'N/A'),
            _buildDetailRow('Employer ID:', notice.employerId),
            _buildDetailRow('Nhà tuyển dụng:', notice.employerName ?? 'N/A'),
            _buildDetailRow('Ngày làm việc:', notice.workDate),
            _buildDetailRow('Số tiền:', notice.amountDisplay,
                valueColor: Colors.blueAccent),
            _buildDetailRow(
                'Trạng thái:', DisbursementModel.statusLabel(notice.status)),
            if (notice.rejectionReason != null)
              _buildDetailRow('Lý do từ chối:', notice.rejectionReason!),
            const SizedBox(height: 16),
            if (notice.status == 'pending_admin')
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Lý do từ chối (bắt buộc nếu từ chối)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        if (notice.status == 'pending_admin') ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _handleReject(context),
            child: const Text('Từ chối'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _handleApprove(context),
            child: const Text('Duyệt giải ngân'),
          ),
        ],
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
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context) async {
    final controller = context.read<DisbursementController>();
    final error = await controller.approveDisbursement(widget.notice.noticeId);

    if (!context.mounted) return;

    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã duyệt yêu cầu giải ngân'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập lý do từ chối'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final controller = context.read<DisbursementController>();
    final error = await controller.rejectDisbursement(
      widget.notice.noticeId,
      reason,
    );

    if (!context.mounted) return;

    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã từ chối yêu cầu giải ngân'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
      );
    }
  }
}
