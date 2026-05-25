import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tklaundry_app/core/network/api_exception.dart';
import 'package:tklaundry_app/core/providers/api_providers.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';
import 'package:tklaundry_app/core/theme/app_typography.dart';
import 'package:tklaundry_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:tklaundry_app/features/member/data/datasources/member_remote_data_source.dart';
import 'package:tklaundry_app/features/member/data/models/member_summary_model.dart';
import 'package:tklaundry_app/shared/widgets/tk_api_error_banner.dart';
import 'package:tklaundry_app/shared/widgets/tk_button.dart';
import 'package:tklaundry_app/shared/widgets/tk_text_field.dart';

class MemberListPage extends ConsumerStatefulWidget {
  const MemberListPage({super.key});

  @override
  ConsumerState<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends ConsumerState<MemberListPage> {
  List<MemberSummaryModel> _items = [];
  bool _isLoading = true;
  Object? _error;

  MemberRemoteDataSource get _dataSource =>
      ref.read(memberRemoteDataSourceProvider);

  String? get _actorUserId => ref.read(authSessionProvider)?.userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _dataSource.fetchMembers();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreateDialog() async {
    final userIdController = TextEditingController();
    final userNameController = TextEditingController();
    final passwordController = TextEditingController();
    final passwordConfirmController = TextEditingController();
    var isCheckingId = false;
    bool? userIdAvailable;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('회원 등록'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TkTextField(
                          label: '아이디',
                          controller: userIdController,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Padding(
                        padding: const EdgeInsets.only(top: 22),
                        child: TkButton(
                          label: '중복확인',
                          variant: TkButtonVariant.secondary,
                          compact: true,
                          isLoading: isCheckingId,
                          onPressed: () async {
                            final userId = userIdController.text.trim();
                            if (userId.isEmpty) return;
                            setDialogState(() {
                              isCheckingId = true;
                              userIdAvailable = null;
                            });
                            try {
                              final available =
                                  await _dataSource.isUserIdAvailable(userId);
                              setDialogState(() {
                                isCheckingId = false;
                                userIdAvailable = available;
                              });
                            } catch (e) {
                              setDialogState(() => isCheckingId = false);
                              if (!dialogContext.mounted) return;
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e is ApiException
                                        ? e.message
                                        : e.toString(),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (userIdAvailable == true) ...[
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      '사용 가능한 아이디입니다.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ],
                  if (userIdAvailable == false) ...[
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      '이미 사용 중인 아이디입니다.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s3),
                  TkTextField(
                    label: '이름',
                    controller: userNameController,
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  TkTextField(
                    label: '비밀번호',
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  TkTextField(
                    label: '비밀번호 확인',
                    controller: passwordConfirmController,
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('등록'),
            ),
          ],
        ),
      ),
    );

    final userId = userIdController.text.trim();
    final userName = userNameController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();
    userIdController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();

    if (saved != true) return;

    if (userId.isEmpty || userName.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해 주세요.')),
      );
      return;
    }
    if (userIdAvailable != true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디 중복 확인을 완료해 주세요.')),
      );
      return;
    }
    if (password != passwordConfirm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호 확인이 일치하지 않습니다.')),
      );
      return;
    }

    try {
      await _dataSource.registerMember(
        userId: userId,
        userName: userName,
        password: password,
        insertUserId: _actorUserId,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$userName ($userId) 회원이 등록되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : e.toString()),
        ),
      );
    }
  }

  Future<void> _showEditDialog(MemberSummaryModel member) async {
    final nameController = TextEditingController(text: member.userName);
    final passwordController = TextEditingController();
    var useYn = member.useYn;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('회원 수정 (${member.userId})'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    helperText: '변경할 비밀번호를 입력하세요.',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                DropdownButtonFormField<String>(
                  initialValue: useYn,
                  decoration: const InputDecoration(
                    labelText: '사용 여부',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Y', child: Text('사용 (Y)')),
                    DropdownMenuItem(value: 'N', child: Text('미사용 (N)')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => useYn = value);
                  },
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
      ),
    );

    if (saved != true) {
      nameController.dispose();
      passwordController.dispose();
      return;
    }

    final name = nameController.text.trim();
    final password = passwordController.text.trim();
    nameController.dispose();
    passwordController.dispose();

    if (name.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 비밀번호를 입력해 주세요.')),
      );
      return;
    }

    try {
      await _dataSource.updateMember(
        userId: member.userId,
        userName: name,
        password: password,
        useYn: useYn,
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
    }
  }

  Future<void> _confirmDelete(MemberSummaryModel member) async {
    final currentUserId = _actorUserId;
    if (currentUserId == member.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 로그인한 계정은 삭제할 수 없습니다.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 삭제'),
        content: Text('${member.userName} (${member.userId}) 계정을 삭제하시겠습니까?'),
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
      await _dataSource.deleteMember(member.userId);
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
              Text('회원 관리', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TkButton(
                label: '회원 등록',
                variant: TkButtonVariant.secondary,
                compact: true,
                onPressed: _isLoading ? null : _showCreateDialog,
              ),
              const SizedBox(width: AppSpacing.s2),
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
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('아이디')),
                          DataColumn(label: Text('이름')),
                          DataColumn(label: Text('사용')),
                          DataColumn(label: Text('최근 로그인')),
                          DataColumn(label: Text('작업')),
                        ],
                        rows: _items.map((member) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  member.userId,
                                  style: AppTypography.mono(context),
                                ),
                              ),
                              DataCell(Text(member.userName)),
                              DataCell(
                                Text(
                                  member.isActive ? 'Y' : 'N',
                                  style: TextStyle(
                                    color: member.isActive
                                        ? AppColors.success
                                        : AppColors.neutral400,
                                  ),
                                ),
                              ),
                              DataCell(Text(member.loginDate ?? '-')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: '수정',
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 20),
                                      onPressed: () => _showEditDialog(member),
                                    ),
                                    IconButton(
                                      tooltip: '삭제',
                                      icon: Icon(Icons.delete_outline,
                                          size: 20,
                                          color: AppColors.error),
                                      onPressed: () =>
                                          _confirmDelete(member),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
