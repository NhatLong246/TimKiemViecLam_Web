import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controllers/complaint_controller.dart';
import '../../../../data/models/complaint_model.dart';

class ComplaintDetailDialog extends StatefulWidget {
  final ComplaintModel complaint;

  const ComplaintDetailDialog({super.key, required this.complaint});

  @override
  State<ComplaintDetailDialog> createState() => _ComplaintDetailDialogState();
}

class _ComplaintDetailDialogState extends State<ComplaintDetailDialog> {
  final _resolutionController = TextEditingController();
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.complaint.status;
    _resolutionController.text = widget.complaint.resolution ?? '';
  }

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;

    return AlertDialog(
      title: const Text('Chi tiết Khiếu nại / Sự cố'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Mã KN:', complaint.complaintId),
              _buildDetailRow('Công việc:', complaint.jobTitle),
              _buildDetailRow(
                  'Ứng viên:', complaint.candidateName ?? complaint.candidateId),
              _buildDetailRow(
                  'Nhà tuyển dụng:', complaint.employerName ?? complaint.employerId),
              _buildDetailRow('Nội dung:', complaint.description),
              const SizedBox(height: 16),
              const Text(
                'Bằng chứng (Ảnh):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (complaint.imageBase64s.isEmpty)
                const Text('Không có ảnh đính kèm')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: complaint.imageBase64s.map((base64String) {
                    try {
                      return Image.memory(
                        base64Decode(base64String),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey),
                      );
                    } catch (e) {
                      return const Icon(Icons.broken_image,
                          size: 100, color: Colors.grey);
                    }
                  }).toList(),
                ),
              const Divider(height: 32),
              const Text(
                'Xử lý Khiếu nại:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Chờ xử lý')),
                  DropdownMenuItem(value: 'processing', child: Text('Đang xử lý')),
                  DropdownMenuItem(value: 'resolved', child: Text('Đã xử lý')),
                  DropdownMenuItem(value: 'rejected', child: Text('Từ chối')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _resolutionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Kết quả xử lý / Phản hồi',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _handleSave(context),
          child: const Text('Lưu thay đổi'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    final controller = context.read<ComplaintController>();
    final resolution = _resolutionController.text.trim();

    final error = await controller.processComplaint(
      widget.complaint.complaintId,
      _selectedStatus,
      resolution: resolution.isEmpty ? null : resolution,
      resolvedBy: 'admin', // Ideally fetch from AuthController
    );

    if (!context.mounted) return;

    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật khiếu nại'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
      );
    }
  }
}
