import 'package:tklaundry_app/core/enums/order_status_kind.dart';

class OrderListItem {
  const OrderListItem({
    required this.orderNo,
    required this.receivedAt,
    required this.customerName,
    required this.phoneMasked,
    required this.statusKind,
    required this.statusLabel,
    required this.amount,
  });

  final String orderNo;
  final DateTime receivedAt;
  final String customerName;
  final String phoneMasked;
  final OrderStatusKind statusKind;
  final String statusLabel;
  final int amount;
}
