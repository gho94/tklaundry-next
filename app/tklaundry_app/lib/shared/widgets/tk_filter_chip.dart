import 'package:flutter/material.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';

class TkFilterChip extends StatelessWidget {
  const TkFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: selected ? AppColors.primary : AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
      backgroundColor: AppColors.neutral0,
      selectedColor: AppColors.primaryMuted,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.neutral200,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
    );
  }
}
