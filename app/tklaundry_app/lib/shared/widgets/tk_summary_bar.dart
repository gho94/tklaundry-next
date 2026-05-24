import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';

class TkSummaryBar extends StatelessWidget {
  const TkSummaryBar({
    super.key,
    required this.totalCount,
    required this.totalAmount,
    required this.statusCounts,
  });

  final int totalCount;
  final int totalAmount;
  final Map<String, int> statusCounts;

  @override
  Widget build(BuildContext context) {
    final amountText = NumberFormat('#,###').format(totalAmount);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('총 $totalCount건', style: theme.textTheme.titleLarge),
          _divider(),
          Text(
            '₩ $amountText',
            style: theme.textTheme.titleLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          _divider(),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.s3,
              runSpacing: AppSpacing.s1,
              children: statusCounts.entries
                  .map(
                    (e) => Text(
                      '${e.key} ${e.value}',
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      color: AppColors.neutral200,
    );
  }
}
