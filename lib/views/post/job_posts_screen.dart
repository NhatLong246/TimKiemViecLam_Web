import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/job_post_controller.dart';
import '../../data/models/job_post_model.dart';
import '../dashboard/components/header.dart';
import 'components/job_post_table.dart';
import 'components/job_status_filter_chip.dart';
import 'components/job_detail_and_moderate_dialog.dart';

class JobPostsScreen extends StatefulWidget {
  const JobPostsScreen({super.key});

  @override
  State<JobPostsScreen> createState() => _JobPostsScreenState();
}

class _JobPostsScreenState extends State<JobPostsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobPostController>().fetchJobPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobPostController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Icon(Icons.article, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Tin tuyển dụng',
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
                      onPressed: controller.fetchJobPosts,
                    ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              _buildStatusFilters(controller),
              const SizedBox(height: defaultPadding),
              _buildContentCard(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilters(JobPostController controller) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: JobPostController.statusFilters.map((status) {
        final isSelected = controller.statusFilter == status;
        final count = status == 'all'
            ? controller.totalCount
            : controller.countByStatus(status);
        final label = status == 'all'
            ? 'Tất cả ($count)'
            : '${JobPostModel.statusLabel(status)} ($count)';

        return JobStatusFilterChip(
          label: label,
          isSelected: isSelected,
          onTap: () => controller.setStatusFilter(status),
        );
      }).toList(),
    );
  }

  Widget _buildContentCard(BuildContext context, JobPostController controller) {
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
              Text(
                'Danh sách tin tuyển dụng',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tiêu đề, địa điểm...',
                    isDense: true,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: controller.setSearchQuery,
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          if (controller.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else if (controller.errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text('Lỗi: ${controller.errorMessage}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.fetchJobPosts,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.jobPosts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Text('Không có tin tuyển dụng'),
              ),
            )
          else
            JobPostTable(
              posts: controller.jobPosts,
              processingJobId: controller.processingJobId,
              onViewDetails: (post) => _showJobDetailDialog(context, post),
              onDelete: (post) => _handleDelete(context, post),
            ),
        ],
      ),
    );
  }

  void _showJobDetailDialog(BuildContext context, JobPostModel post) {
    showDialog(
      context: context,
      builder: (ctx) => JobDetailAndModerateDialog(
        jobPost: post,
        onApprove: (p) => _executeApprove(context, p),
        onReject: (p, reason) => _executeReject(context, p, reason),
      ),
    );
  }

  Future<void> _executeApprove(BuildContext context, JobPostModel post) async {
    final error =
        await context.read<JobPostController>().approveJobPost(post.jobId);
    if (!context.mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã duyệt tin tuyển dụng'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _executeReject(BuildContext context, JobPostModel post, String reason) async {
    final error = await context.read<JobPostController>().rejectJobPost(
          post.jobId,
          reason: reason.isEmpty ? null : reason,
        );
    if (!context.mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã từ chối tin tuyển dụng'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context, JobPostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá tin tuyển dụng'),
        content: Text('Bạn có chắc chắn muốn xoá tin "${post.title}" vĩnh viễn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final error =
        await context.read<JobPostController>().deleteJobPost(post.jobId);
    if (!context.mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xoá tin tuyển dụng'),
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
