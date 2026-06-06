import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controllers/complaint_controller.dart';
import '../../../../data/models/disbursement_complaint_model.dart';

class ComplaintDetailDialog extends StatefulWidget {
  final DisbursementComplaintModel complaint;

  const ComplaintDetailDialog({super.key, required this.complaint});

  @override
  State<ComplaintDetailDialog> createState() => _ComplaintDetailDialogState();
}

class _ComplaintDetailDialogState extends State<ComplaintDetailDialog> {
  final _noteController = TextEditingController();
  final _compensationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.complaint.adminNote;
    _compensationController.text = widget.complaint.isPending
        ? widget.complaint.proposedCompensation.toStringAsFixed(0)
        : widget.complaint.finalCompensation.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _compensationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    return AlertDialog(
      title: const Text('Chi tiết khiếu nại giải ngân'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('Mã yêu cầu:', complaint.noticeId),
              _detail('Công việc:', complaint.jobTitle),
              _detail(
                'Nhà tuyển dụng:',
                complaint.employerName ?? complaint.employerId,
              ),
              _detail(
                'Ứng viên bị khiếu nại:',
                complaint.candidateName ?? complaint.candidateId,
              ),
              _detail('Tiền công ứng viên:', _money(complaint.candidateWage)),
              _detail(
                'Mức đền bù NTD đề xuất:',
                _money(complaint.proposedCompensation),
                color: Colors.red.shade700,
              ),
              _detail('Lý do:', complaint.reason),
              const SizedBox(height: 12),
              const Text(
                'Bằng chứng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (complaint.evidenceUrls.isEmpty)
                const Text('Không có bằng chứng đính kèm')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: complaint.evidenceUrls
                      .map(
                        (url) => Image.network(
                          url,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 110,
                                height: 110,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image),
                              ),
                        ),
                      )
                      .toList(),
                ),
              const Divider(height: 32),
              if (complaint.isPending) ...[
                TextField(
                  controller: _compensationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mức đền bù Admin chốt',
                    helperText:
                        'Có thể thấp hơn, bằng hoặc cao hơn tiền công ứng viên.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú / lý do quyết định',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ] else ...[
                _detail(
                  'Kết quả:',
                  DisbursementComplaintModel.statusLabel(complaint.status),
                ),
                _detail(
                  'Mức đền bù Admin chốt:',
                  _money(complaint.finalCompensation),
                ),
                _detail('Ghi chú Admin:', complaint.adminNote),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        if (complaint.isPending) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _resolve(context, 'rejected'),
            child: const Text('Từ chối'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _resolve(context, 'approved'),
            child: const Text('Duyệt khiếu nại'),
          ),
        ],
      ],
    );
  }

  Widget _detail(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resolve(BuildContext context, String decision) async {
    final note = _noteController.text.trim();
    final compensation =
        double.tryParse(_compensationController.text.trim()) ?? -1;
    if (note.isEmpty) {
      _message(context, 'Vui lòng nhập ghi chú hoặc lý do quyết định');
      return;
    }
    if (decision == 'approved' && compensation < 0) {
      _message(context, 'Vui lòng nhập mức đền bù hợp lệ');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          decision == 'approved' ? 'Duyệt khiếu nại?' : 'Từ chối khiếu nại?',
        ),
        content: Text(
          decision == 'approved'
              ? 'NTD sẽ được phép giải ngân với mức đền bù ${_money(compensation)}.'
              : 'Ứng viên sẽ nhận đủ tiền công vì khiếu nại bị từ chối.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await context.read<ComplaintController>().resolveComplaint(
      complaint: widget.complaint,
      decision: decision,
      finalCompensation: decision == 'approved' ? compensation : 0,
      note: note,
    );
    if (!context.mounted) return;
    if (error != null) {
      _message(context, 'Lỗi: $error', color: Colors.red);
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          decision == 'approved'
              ? 'Đã duyệt khiếu nại và thông báo cho NTD'
              : 'Đã từ chối khiếu nại và thông báo cho NTD',
        ),
        backgroundColor: decision == 'approved' ? Colors.green : Colors.orange,
      ),
    );
  }

  void _message(BuildContext context, String text, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color ?? Colors.orange),
    );
  }

  static String _money(double value) => '${value.toStringAsFixed(0)}đ';
}
