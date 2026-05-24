import 'package:flutter/material.dart';
import 'package:tklaundry_app/core/enums/order_status_kind.dart';

@immutable
class OrderStatusStyle {
  const OrderStatusStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.received,
    required this.inProgress,
    required this.completed,
    required this.readyToShip,
    required this.shipped,
    required this.cancelled,
  });

  final OrderStatusStyle received;
  final OrderStatusStyle inProgress;
  final OrderStatusStyle completed;
  final OrderStatusStyle readyToShip;
  final OrderStatusStyle shipped;
  final OrderStatusStyle cancelled;

  static const light = AppStatusColors(
    received: OrderStatusStyle(
      background: Color(0xFFF1F5F9),
      foreground: Color(0xFF475569),
      border: Color(0xFFE2E8F0),
    ),
    inProgress: OrderStatusStyle(
      background: Color(0xFFDBEAFE),
      foreground: Color(0xFF1D4ED8),
      border: Color(0xFFBFDBFE),
    ),
    completed: OrderStatusStyle(
      background: Color(0xFFDCFCE7),
      foreground: Color(0xFF15803D),
      border: Color(0xFFBBF7D0),
    ),
    readyToShip: OrderStatusStyle(
      background: Color(0xFFFEF3C7),
      foreground: Color(0xFFB45309),
      border: Color(0xFFFDE68A),
    ),
    shipped: OrderStatusStyle(
      background: Color(0xFFD1FAE5),
      foreground: Color(0xFF047857),
      border: Color(0xFFA7F3D0),
    ),
    cancelled: OrderStatusStyle(
      background: Color(0xFFFEE2E2),
      foreground: Color(0xFFB91C1C),
      border: Color(0xFFFECACA),
    ),
  );

  OrderStatusStyle styleFor(OrderStatusKind kind) => switch (kind) {
        OrderStatusKind.received => received,
        OrderStatusKind.inProgress => inProgress,
        OrderStatusKind.completed => completed,
        OrderStatusKind.readyToShip => readyToShip,
        OrderStatusKind.shipped => shipped,
        OrderStatusKind.cancelled => cancelled,
      };

  @override
  AppStatusColors copyWith({
    OrderStatusStyle? received,
    OrderStatusStyle? inProgress,
    OrderStatusStyle? completed,
    OrderStatusStyle? readyToShip,
    OrderStatusStyle? shipped,
    OrderStatusStyle? cancelled,
  }) {
    return AppStatusColors(
      received: received ?? this.received,
      inProgress: inProgress ?? this.inProgress,
      completed: completed ?? this.completed,
      readyToShip: readyToShip ?? this.readyToShip,
      shipped: shipped ?? this.shipped,
      cancelled: cancelled ?? this.cancelled,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppStatusColorsX on BuildContext {
  AppStatusColors get statusColors =>
      Theme.of(this).extension<AppStatusColors>() ?? AppStatusColors.light;
}
