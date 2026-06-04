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
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Chờ xử lý', style: TextStyle(color: Colors.black87))),
                  DropdownMenuItem(value: 'processing', child: Text('Đang xử lý', style: TextStyle(color: Colors.black87))),
                  DropdownMenuItem(value: 'resolved', child: Text('Đã xử lý', style: TextStyle(color: Colors.black87))),
                  DropdownMenuItem(value: 'rejected', child: Text('Từ chối', style: TextStyle(color: Colors.black87))),
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
              const Divider(height: 32),
              const Text(
                'Hành động bổ sung:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (_selectedStatus == 'processing' || _selectedStatus == 'resolved')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade900,
                        ),
                        icon: const Icon(Icons.gavel),
                        label: const Text('Phạt NTD'),
                        onPressed: () => _showPenaltyDialog(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade900,
                        ),
                        icon: const Icon(Icons.volunteer_activism),
                        label: const Text('Bồi thường Ứng viên'),
                        onPressed: () => _showCompensationDialog(context),
                      ),
                    ),
                  ],
                )
              else
                const Text('Vui lòng chuyển trạng thái khiếu nại sang "Đang xử lý" hoặc "Đã xử lý" để sử dụng tính năng này.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
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

  void _showPenaltyDialog(BuildContext context) {
    String? selectedRule;
    final rules = {
      'Vi phạm quy định tuyển dụng': 500000.0,
      'Quấy rối / Xúc phạm ứng viên': 1000000.0,
      'Hành vi lừa đảo': 2000000.0,
    };

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Phạt Nhà tuyển dụng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn lý do phạt:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRule,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: rules.keys.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setState(() => selectedRule = val),
                  ),
                  const SizedBox(height: 16),
                  if (selectedRule != null)
                    Text('Số tiền phạt: ${rules[selectedRule]!.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: selectedRule == null ? null : () async {
                    Navigator.pop(ctx);
                    final controller = context.read<ComplaintController>();
                    final error = await controller.applyPenalty(widget.complaint.complaintId, widget.complaint.employerId, rules[selectedRule]!, selectedRule!);
                    if (error == null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã trừ tiền phạt Nhà tuyển dụng'), backgroundColor: Colors.green));
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Xác nhận phạt'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _showCompensationDialog(BuildContext context) {
    String? selectedRule;
    final rules = {
      'Hỗ trợ chi phí đi lại': 100000.0,
      'Bồi thường thời gian': 200000.0,
      'Bồi thường vi phạm cam kết': 500000.0,
    };

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Bồi thường Ứng viên'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn lý do bồi thường:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRule,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: rules.keys.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setState(() => selectedRule = val),
                  ),
                  const SizedBox(height: 16),
                  if (selectedRule != null)
                    Text('Số tiền bồi thường: ${rules[selectedRule]!.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: selectedRule == null ? null : () async {
                    Navigator.pop(ctx);
                    final controller = context.read<ComplaintController>();
                    final error = await controller.applyCompensation(widget.complaint.complaintId, widget.complaint.candidateId, rules[selectedRule]!, selectedRule!);
                    if (error == null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cộng tiền bồi thường cho Ứng viên'), backgroundColor: Colors.green));
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Xác nhận bồi thường'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
