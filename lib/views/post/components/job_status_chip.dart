import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../data/models/job_post_model.dart';

class JobStatusChip extends StatelessWidget {
  const JobStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colorsFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        JobPostModel.statusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  (Color, Color) _colorsFor(String status) {
    switch (status) {
      case 'draft':
        return (Colors.grey.shade700, Colors.grey.shade200);
      case 'pending':
        return (Colors.orange.shade800, Colors.orange.shade100);
      case 'approved':
        return (primaryColor, primaryColor.withValues(alpha: 0.15));
      case 'active':
        return (Colors.green.shade800, Colors.green.shade100);
      case 'closed':
        return (secondaryColor, secondaryColor.withValues(alpha: 0.12));
      case 'rejected':
        return (Colors.red.shade800, Colors.red.shade100);
      default:
        return (Colors.grey.shade700, Colors.grey.shade200);
    }
  }
}
