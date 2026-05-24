import 'package:flutter/material.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';

enum TkButtonVariant { primary, secondary, ghost, danger }

class TkButton extends StatelessWidget {
  const TkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TkButtonVariant.primary,
    this.isLoading = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final TkButtonVariant variant;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 36.0 : 40.0;
    final child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == TkButtonVariant.primary ||
                      variant == TkButtonVariant.danger
                  ? AppColors.neutral0
                  : AppColors.primary,
            ),
          )
        : Text(label);

    final effectiveOnPressed = isLoading ? null : onPressed;

    return switch (variant) {
      TkButtonVariant.primary => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(minimumSize: Size(80, height)),
          child: child,
        ),
      TkButtonVariant.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(minimumSize: Size(80, height)),
          child: child,
        ),
      TkButtonVariant.ghost => TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      TkButtonVariant.danger => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(80, height),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.neutral0,
          ),
          child: child,
        ),
    };
  }
}
