import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tklaundry_app/core/constants/route_paths.dart';
import 'package:tklaundry_app/core/providers/api_providers.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_radius.dart';
import 'package:tklaundry_app/core/theme/app_shadows.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';
import 'package:tklaundry_app/shared/widgets/tk_button.dart';
import 'package:tklaundry_app/shared/widgets/tk_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _userIdController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  bool _isCheckingId = false;
  bool? _userIdAvailable;
  String? _errorMessage;

  @override
  void dispose() {
    _userIdController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _checkUserId() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() {
        _errorMessage = '아이디를 입력한 뒤 중복 확인을 해 주세요.';
        _userIdAvailable = null;
      });
      return;
    }

    setState(() {
      _isCheckingId = true;
      _errorMessage = null;
    });

    final (available, failure) =
        await ref.read(authRepositoryProvider).isUserIdAvailable(userId);

    if (!mounted) return;

    setState(() {
      _isCheckingId = false;
      if (failure != null) {
        _errorMessage = failure.message;
        _userIdAvailable = null;
        return;
      }
      _userIdAvailable = available;
      if (available == false) {
        _errorMessage = '이미 사용 중인 아이디입니다.';
      }
    });
  }

  Future<void> _submit() async {
    final userId = _userIdController.text.trim();
    final userName = _userNameController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();

    if (userId.isEmpty || userName.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '필수 항목을 모두 입력해 주세요.');
      return;
    }
    if (_userIdAvailable != true) {
      setState(() => _errorMessage = '아이디 중복 확인을 완료해 주세요.');
      return;
    }
    if (password != passwordConfirm) {
      setState(() => _errorMessage = '비밀번호 확인이 일치하지 않습니다.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final (_, failure) = await ref.read(authRepositoryProvider).register(
          userId: userId,
          password: password,
          userName: userName,
        );

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = failure.message;
      });
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해 주세요.')),
    );
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            margin: const EdgeInsets.all(AppSpacing.s4),
            padding: const EdgeInsets.all(AppSpacing.s6),
            decoration: BoxDecoration(
              color: AppColors.neutral0,
              borderRadius: AppRadius.lg,
              boxShadow: AppShadows.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('회원가입', style: theme.textTheme.displayLarge),
                const SizedBox(height: AppSpacing.s1),
                Text('관리자 계정을 등록합니다.', style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.s6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TkTextField(
                        label: '아이디',
                        controller: _userIdController,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: TkButton(
                        label: '중복확인',
                        variant: TkButtonVariant.secondary,
                        compact: true,
                        isLoading: _isCheckingId,
                        onPressed: _checkUserId,
                      ),
                    ),
                  ],
                ),
                if (_userIdAvailable == true) ...[
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    '사용 가능한 아이디입니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s4),
                TkTextField(
                  label: '이름',
                  controller: _userNameController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.s4),
                TkTextField(
                  label: '비밀번호',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.s4),
                TkTextField(
                  label: '비밀번호 확인',
                  controller: _passwordConfirmController,
                  obscureText: true,
                  errorText: _errorMessage,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.s6),
                TkButton(
                  label: '가입하기',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.s3),
                TkButton(
                  label: '로그인으로 돌아가기',
                  variant: TkButtonVariant.ghost,
                  onPressed: () => context.go(RoutePaths.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
