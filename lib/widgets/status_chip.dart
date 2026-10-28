import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/bookshelf_item.dart';

Color statusColor(ReadingStatus s) => switch (s) {
      ReadingStatus.read => AppColors.success,
      ReadingStatus.reading => AppColors.accent,
      ReadingStatus.saved => AppColors.warning,
    };

Color statusSoftColor(ReadingStatus s) => switch (s) {
      ReadingStatus.read => AppColors.successSoft,
      ReadingStatus.reading => AppColors.accentSoft,
      ReadingStatus.saved => AppColors.warningSoft,
    };

IconData statusIcon(ReadingStatus s) => switch (s) {
      ReadingStatus.read => Icons.check_circle_rounded,
      ReadingStatus.reading => Icons.auto_stories_rounded,
      ReadingStatus.saved => Icons.bookmark_rounded,
    };

/// Mostra ícone + texto (não depende só da cor).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusSoftColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(status.label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
