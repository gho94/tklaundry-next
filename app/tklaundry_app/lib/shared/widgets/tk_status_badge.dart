import 'package:flutter/material.dart';
import 'package:tklaundry_app/core/enums/order_status_kind.dart';
import 'package:tklaundry_app/core/theme/app_radius.dart';
import 'package:tklaundry_app/core/theme/extensions/app_status_colors.dart';

class TkStatusBadge extends StatelessWidget {
  const TkStatusBadge({
    super.key,
    required this.label,
    required this.kind,
  });

  final String label;
  final OrderStatusKind kind;

  @override
  Widget build(BuildContext context) {
    final style = context.statusColors.styleFor(kind);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        border: Border.all(color: style.border),
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: style.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: style.foreground,
                ),
          ),
        ],
      ),
    );
  }
}
