import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tklaundry_app/core/enums/order_status_kind.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_layout.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';
import 'package:tklaundry_app/core/theme/app_typography.dart';
import 'package:tklaundry_app/features/order/domain/entities/order_list_item.dart';
import 'package:tklaundry_app/shared/widgets/tk_filter_chip.dart';
import 'package:tklaundry_app/shared/widgets/tk_status_badge.dart';
import 'package:tklaundry_app/shared/widgets/tk_summary_bar.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  int _selectedPreset = 0;
  static const _presets = ['오늘', '어제', '7일', '이번 달'];

  late final List<OrderListItem> _items = [
    OrderListItem(
      orderNo: 'O250525-001',
      receivedAt: DateTime(2026, 5, 25, 9, 12),
      customerName: '김민수',
      phoneMasked: '010-****-1234',
      statusKind: OrderStatusKind.inProgress,
      statusLabel: '작업중',
      amount: 28000,
    ),
    OrderListItem(
      orderNo: 'O250525-002',
      receivedAt: DateTime(2026, 5, 25, 9, 45),
      customerName: '이서연',
      phoneMasked: '010-****-5678',
      statusKind: OrderStatusKind.received,
      statusLabel: '접수대기',
      amount: 15000,
    ),
    OrderListItem(
      orderNo: 'O250524-018',
      receivedAt: DateTime(2026, 5, 24, 17, 30),
      customerName: '박지훈',
      phoneMasked: '010-****-9012',
      statusKind: OrderStatusKind.readyToShip,
      statusLabel: '출고대기',
      amount: 42000,
    ),
  ];

  int get _totalAmount =>
      _items.fold(0, (sum, item) => sum + item.amount);

  Map<String, int> get _statusCounts {
    final counts = <String, int>{};
    for (final item in _items) {
      counts[item.statusLabel] = (counts[item.statusLabel] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM-dd HH:mm');
    final amountFormat = NumberFormat('#,###');

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('접수 목록', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                tooltip: '새로고침',
                onPressed: () {},
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          _buildFilterBar(),
          const SizedBox(height: AppSpacing.s3),
          TkSummaryBar(
            totalCount: _items.length,
            totalAmount: _totalAmount,
            statusCounts: _statusCounts,
          ),
          const SizedBox(height: AppSpacing.s3),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                border: Border.all(color: AppColors.neutral200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('접수번호')),
                    DataColumn(label: Text('접수일시')),
                    DataColumn(label: Text('고객명')),
                    DataColumn(label: Text('연락처')),
                    DataColumn(label: Text('상태')),
                    DataColumn(label: Text('금액'), numeric: true),
                  ],
                  rows: _items.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item.orderNo,
                            style: AppTypography.mono(context),
                          ),
                        ),
                        DataCell(Text(dateFormat.format(item.receivedAt))),
                        DataCell(Text(item.customerName)),
                        DataCell(Text(item.phoneMasked)),
                        DataCell(
                          TkStatusBadge(
                            label: item.statusLabel,
                            kind: item.statusKind,
                          ),
                        ),
                        DataCell(
                          Text(
                            amountFormat.format(item.amount),
                            style: AppTypography.amount(context),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'API 연동 전 목 데이터입니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: AppLayout.filterBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _presets.length; i++) ...[
            TkFilterChip(
              label: _presets[i],
              selected: _selectedPreset == i,
              onSelected: (_) => setState(() => _selectedPreset = i),
            ),
            if (i < _presets.length - 1) const SizedBox(width: AppSpacing.s2),
          ],
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: '고객명·연락처 검색',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
