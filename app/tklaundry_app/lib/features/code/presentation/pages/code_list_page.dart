import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tklaundry_app/core/network/api_exception.dart';
import 'package:tklaundry_app/core/providers/api_providers.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';
import 'package:tklaundry_app/core/theme/app_typography.dart';
import 'package:tklaundry_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:tklaundry_app/features/code/data/datasources/code_remote_data_source.dart';
import 'package:tklaundry_app/features/code/data/models/code_item_model.dart';
import 'package:tklaundry_app/features/code/domain/code_tree_node.dart';
import 'package:tklaundry_app/features/code/presentation/widgets/code_tree_panel.dart';
import 'package:tklaundry_app/shared/widgets/tk_api_error_banner.dart';
import 'package:tklaundry_app/shared/widgets/tk_button.dart';

class CodeListPage extends ConsumerStatefulWidget {
  const CodeListPage({super.key});

  @override
  ConsumerState<CodeListPage> createState() => _CodeListPageState();
}

class _CodeListPageState extends ConsumerState<CodeListPage> {
  List<CodeTreeNode> _roots = [];
  final Set<String> _expandedIds = {};
  bool _isLoading = true;
  Object? _error;
  CodeItemModel? _selected;

  CodeRemoteDataSource get _dataSource =>
      ref.read(codeRemoteDataSourceProvider);

  String? get _actorUserId => ref.read(authSessionProvider)?.userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _rebuildTree(List<CodeItemModel> items) {
    _roots = buildCodeTree(items);
    final expandable = collectExpandableCodeIds(_roots);
    _expandedIds.removeWhere((id) => !expandable.contains(id));
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _dataSource.fetchCodes();
      if (!mounted) return;
      setState(() {
        _rebuildTree(items);
        _isLoading = false;
        if (_selected != null) {
          final previousId = _selected!.codeId;
          final matches = items.where((e) => e.codeId == previousId);
          _selected = matches.isEmpty ? null : matches.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  void _toggleExpand(String codeId) {
    setState(() {
      if (_expandedIds.contains(codeId)) {
        _expandedIds.remove(codeId);
      } else {
        _expandedIds.add(codeId);
      }
    });
  }

  Future<void> _showCreateDialog({CodeItemModel? parent}) async {
    final nameController = TextEditingController();
    String? nextId;
    var loadingNextId = true;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> loadNextId() async {
              setDialogState(() => loadingNextId = true);
              try {
                final id = await _dataSource.fetchNextCodeId(
                  pCodeId: parent?.codeId ?? 'Root',
                );
                setDialogState(() {
                  nextId = id;
                  loadingNextId = false;
                });
              } catch (e) {
                setDialogState(() => loadingNextId = false);
              }
            }

            if (loadingNextId && nextId == null) {
              loadNextId();
            }

            return AlertDialog(
              title: Text(parent == null ? '최상위 코드 추가' : '하위 코드 추가'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (parent != null)
                      Text('상위: ${parent.codeName} (${parent.codeId})'),
                    if (parent == null) const Text('상위: Root (최상위)'),
                    const SizedBox(height: AppSpacing.s3),
                    Text(
                      loadingNextId
                          ? '코드 ID 조회 중...'
                          : '코드 ID: ${nextId ?? '-'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '코드명',
                        isDense: true,
                      ),
                      autofocus: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    try {
                      await _dataSource.createCode(
                        pCodeId: parent?.codeId ?? 'Root',
                        codeName: name,
                        insertUserId: _actorUserId,
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      await _load();
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            e is ApiException ? e.message : e.toString(),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
    nameController.dispose();
  }

  Future<void> _showEditDialog(CodeItemModel item) async {
    final nameController = TextEditingController(text: item.codeName);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('코드 수정'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('코드 ID: ${item.codeId}'),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '코드명',
                  isDense: true,
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (saved != true) {
      nameController.dispose();
      return;
    }

    try {
      await _dataSource.updateCode(
        codeId: item.codeId,
        codeName: nameController.text.trim(),
        updateUserId: _actorUserId,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : e.toString()),
        ),
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _confirmDelete(CodeItemModel item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('코드 삭제'),
        content: Text(
          '"${item.codeName}" (${item.codeId}) 및 하위 코드가 모두 삭제됩니다.\n계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _dataSource.deleteCode(item.codeId);
      if (_selected?.codeId == item.codeId) {
        setState(() => _selected = null);
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : e.toString()),
        ),
      );
    }
  }

  Widget _buildDetailPanel(BuildContext context) {
    final selected = _selected;
    if (selected == null) {
      return Center(
        child: Text(
          '트리에서 코드를 선택하세요.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('선택한 코드', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s4),
          _DetailRow(label: '코드 ID', value: selected.codeId, mono: true),
          _DetailRow(label: '코드명', value: selected.codeName),
          _DetailRow(label: '상위 ID', value: selected.pCodeId ?? 'ROOT'),
          _DetailRow(label: '등급', value: '${selected.grade}'),
          const Spacer(),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              TkButton(
                label: '하위 추가',
                variant: TkButtonVariant.secondary,
                compact: true,
                onPressed: () => _showCreateDialog(parent: selected),
              ),
              TkButton(
                label: '수정',
                variant: TkButtonVariant.secondary,
                compact: true,
                onPressed: () => _showEditDialog(selected),
              ),
              TkButton(
                label: '삭제',
                variant: TkButtonVariant.danger,
                compact: true,
                onPressed: () => _confirmDelete(selected),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: '설정으로',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              Text('코드 관리', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TkButton(
                label: '최상위 추가',
                variant: TkButtonVariant.secondary,
                compact: true,
                onPressed: _isLoading ? null : () => _showCreateDialog(),
              ),
              const SizedBox(width: AppSpacing.s2),
              IconButton(
                tooltip: '모두 펼치기',
                onPressed: _isLoading || _roots.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _expandedIds
                            ..clear()
                            ..addAll(collectExpandableCodeIds(_roots));
                        });
                      },
                icon: const Icon(Icons.unfold_more),
              ),
              IconButton(
                tooltip: '모두 접기',
                onPressed: _isLoading || _roots.isEmpty
                    ? null
                    : () => setState(_expandedIds.clear),
                icon: const Icon(Icons.unfold_less),
              ),
              IconButton(
                tooltip: '새로고침',
                onPressed: _isLoading ? null : _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          if (_error != null) ...[
            TkApiErrorBanner(error: _error!),
            const SizedBox(height: AppSpacing.s3),
          ],
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.neutral0,
                      border: Border.all(color: AppColors.neutral200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: CodeTreePanel(
                            roots: _roots,
                            expandedIds: _expandedIds,
                            selected: _selected,
                            onToggleExpand: _toggleExpand,
                            onSelect: (item) =>
                                setState(() => _selected = item),
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          flex: 2,
                          child: _buildDetailPanel(context),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? AppTypography.mono(context)
                  : theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
