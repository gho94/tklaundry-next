import 'package:tklaundry_app/features/code/data/models/code_item_model.dart';

class CodeTreeNode {
  const CodeTreeNode({
    required this.item,
    required this.children,
  });

  final CodeItemModel item;
  final List<CodeTreeNode> children;

  bool get hasChildren => children.isNotEmpty;
}

bool isCodeRootParent(String? pCodeId) {
  if (pCodeId == null || pCodeId.isEmpty) return true;
  return pCodeId.trim().toUpperCase() == 'ROOT';
}

String codeParentKey(CodeItemModel item) {
  if (isCodeRootParent(item.pCodeId)) return '';
  return item.pCodeId!.trim();
}

List<CodeTreeNode> buildCodeTree(List<CodeItemModel> items) {
  final childrenByParent = <String, List<CodeItemModel>>{};
  for (final item in items) {
    final key = codeParentKey(item);
    childrenByParent.putIfAbsent(key, () => []).add(item);
  }
  for (final group in childrenByParent.values) {
    group.sort((a, b) => a.codeId.compareTo(b.codeId));
  }

  List<CodeTreeNode> buildLevel(String parentKey) {
    final levelItems = childrenByParent[parentKey] ?? [];
    return levelItems
        .map(
          (item) => CodeTreeNode(
            item: item,
            children: buildLevel(item.codeId),
          ),
        )
        .toList();
  }

  return buildLevel('');
}

Set<String> collectExpandableCodeIds(List<CodeTreeNode> nodes) {
  final ids = <String>{};
  void walk(List<CodeTreeNode> level) {
    for (final node in level) {
      if (node.hasChildren) {
        ids.add(node.item.codeId);
        walk(node.children);
      }
    }
  }

  walk(nodes);
  return ids;
}
