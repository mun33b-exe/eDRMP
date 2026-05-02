import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../../theme/colors.dart';

/// Represents a single item in the [AppTimeline].
@immutable
class AppTimelineItemData {
  const AppTimelineItemData({
    required this.state,
    required this.title,
    required this.meta,
    this.note,
  });

  /// 'done' | 'active' | 'pending' | 'rejected'
  final String state;
  final String title;
  final String meta;
  final String? note;
}

/// A vertical stepper/timeline widget that renders a list of [AppTimelineItemData].
class AppTimeline extends StatelessWidget {
  const AppTimeline({required this.items, this.isDark = false, super.key});

  final List<AppTimelineItemData> items;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: AppRadius.allLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(AppPadding.md),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return _TimelineItemNode(item: item, isDark: isDark, isLast: isLast);
        }),
      ),
    );
  }
}

class _TimelineItemNode extends StatelessWidget {
  const _TimelineItemNode({
    required this.item,
    required this.isDark,
    required this.isLast,
  });

  final AppTimelineItemData item;
  final bool isDark;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDone = item.state == 'done';
    final isActive = item.state == 'active';
    final isRejected = item.state == 'rejected';

    // Dot color
    final dotColor = isDone
        ? AppColors.approved
        : isRejected
        ? AppColors.rejected
        : isActive
        ? AppColors.primary
        : (isDark ? AppColors.darkTextMuted : AppColors.border);

    // Line color
    final lineColor = isDone
        ? AppColors.approved
        : (isDark ? AppColors.darkBorder : AppColors.border);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: dot + line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone || isRejected ? dotColor : Colors.transparent,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : isRejected
                      ? const Icon(Icons.close, size: 10, color: Colors.white)
                      : isActive
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.hMd,
          // Right column: text
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppPadding.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.primary
                          : (isDone || isRejected
                                ? (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary)
                                : (isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted)),
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    item.meta,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                    ),
                  ),
                  if (item.note != null) ...[
                    AppSpacing.vXs,
                    Text(
                      item.note!,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
