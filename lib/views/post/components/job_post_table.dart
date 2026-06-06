import 'package:flutter/material.dart';

import '../../../data/models/job_post_model.dart';
import 'job_status_chip.dart';

class JobPostTable extends StatelessWidget {
  const JobPostTable({
    super.key,
    required this.posts,
    this.processingJobId,
    this.onApprove,
    this.onReject,
    this.onDelete,
  });

  final List<JobPostModel> posts;
  final String? processingJobId;
  final void Function(JobPostModel post)? onApprove;
  final void Function(JobPostModel post)? onReject;
  final void Function(JobPostModel post)? onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('Tiêu đề')),
          DataColumn(label: Text('Danh mục')),
          DataColumn(label: Text('Loại việc')),
          DataColumn(label: Text('Địa điểm')),
          DataColumn(label: Text('Lương')),
          DataColumn(label: Text('Số slot')),
          DataColumn(label: Text('Ngày bắt đầu')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: posts.map((p) => _buildRow(context, p)).toList(),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, JobPostModel post) {
    final isProcessing = processingJobId == post.jobId;
    final canModerate = post.status == 'pending' || post.status == 'draft';

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        DataCell(Text(JobPostModel.categoryLabel(post.category))),
        DataCell(Text(JobPostModel.jobTypeLabel(post.jobType))),
        DataCell(
          SizedBox(
            width: 140,
            child: Text(
              post.locationDisplay.isNotEmpty ? post.locationDisplay : '—',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(post.salaryDisplay)),
        DataCell(Text('${post.filledSlots}/${post.slots}')),
        DataCell(Text(_formatDate(post.startDate))),
        DataCell(JobStatusChip(status: post.status)),
        DataCell(_buildActions(context, post, canModerate, isProcessing)),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    JobPostModel post,
    bool canModerate,
    bool isProcessing,
  ) {
    if (isProcessing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canModerate) ...[
          TextButton.icon(
            onPressed: onApprove == null ? null : () => onApprove!(post),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Duyệt'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green.shade700,
            ),
          ),
          TextButton.icon(
            onPressed: onReject == null ? null : () => onReject!(post),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Từ chối'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
            ),
          ),
        ],
        TextButton.icon(
          onPressed: onDelete == null ? null : () => onDelete!(post),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Xoá'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
