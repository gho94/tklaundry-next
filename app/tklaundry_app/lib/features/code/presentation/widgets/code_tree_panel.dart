import 'package:flutter/material.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';
import 'package:tklaundry_app/core/theme/app_typography.dart';
import 'package:tklaundry_app/features/code/data/models/code_item_model.dart';
import 'package:tklaundry_app/features/code/domain/code_tree_node.dart';

class CodeTreePanel extends StatelessWidget {
  const CodeTreePanel({
    super.key,
    required this.roots,
    required this.expandedIds,
    required this.selected,
    required this.onToggleExpand,
    required this.onSelect,
  });

  final List<CodeTreeNode> roots;
  final Set<String> expandedIds;
  final CodeItemModel? selected;
  final ValueChanged<String> onToggleExpand;
  final ValueChanged<CodeItemModel> onSelect;

  @override
  Widget build(BuildContext context) {
    if (roots.isEmpty) {
      return Center(
        child: Text(
          '등록된 코드가 없습니다.\n최상위 추가로 코드를 등록하세요.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      children: [
        for (final node in roots)
          _CodeTreeTile(
            node: node,
            depth: 0,
            expandedIds: expandedIds,
            selectedId: selected?.codeId,
            onToggleExpand: onToggleExpand,
            onSelect: onSelect,
          ),
      ],
    );
  }
}

class _CodeTreeTile extends StatelessWidget {
  const _CodeTreeTile({
    required this.node,
    required this.depth,
    required this.expandedIds,
    required this.selectedId,
    required this.onToggleExpand,
    required this.onSelect,
  });

  final CodeTreeNode node;
  final int depth;
  final Set<String> expandedIds;
  final String? selectedId;
  final ValueChanged<String> onToggleExpand;
  final ValueChanged<CodeItemModel> onSelect;

  @override
  Widget build(BuildContext context) {
    final item = node.item;
    final isSelected = selectedId == item.codeId;
    final isExpanded = expandedIds.contains(item.codeId);
    final hasChildren = node.hasChildren;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: isSelected
              ? AppColors.primaryMuted
              : Colors.transparent,
          child: GestureDetector(
            onDoubleTap: hasChildren
                ? () => onToggleExpand(item.codeId)
                : null,
            child: InkWell(
              onTap: () => onSelect(item),
              child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.s2 + depth * 20.0,
                right: AppSpacing.s2,
                top: AppSpacing.s1,
                bottom: AppSpacing.s1,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: hasChildren
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: isExpanded ? '접기' : '펼치기',
                            icon: Icon(
                              isExpanded
                                  ? Icons.expand_more
                                  : Icons.chevron_right,
                              size: 20,
                            ),
                            onPressed: () => onToggleExpand(item.codeId),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Icon(
                    hasChildren
                        ? (isExpanded
                            ? Icons.folder_open_outlined
                            : Icons.folder_outlined)
                        : Icons.label_outline,
                    size: 18,
                    color: isSelected ? AppColors.primary : AppColors.neutral600,
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Expanded(
                    child: Text(
                      item.codeName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Text(
                    item.codeId,
                    style: AppTypography.mono(context).copyWith(
                      color: AppColors.neutral600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
        if (isExpanded && hasChildren)
          for (final child in node.children)
            _CodeTreeTile(
              node: child,
              depth: depth + 1,
              expandedIds: expandedIds,
              selectedId: selectedId,
              onToggleExpand: onToggleExpand,
              onSelect: onSelect,
            ),
      ],
    );
  }
}
