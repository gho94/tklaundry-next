import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tklaundry_app/core/constants/route_paths.dart';
import 'package:tklaundry_app/core/providers/api_providers.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_radius.dart';
import 'package:tklaundry_app/core/theme/app_shadows.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';
import 'package:tklaundry_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:tklaundry_app/shared/widgets/tk_button.dart';
import 'package:tklaundry_app/shared/widgets/tk_text_field.dart';


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '아이디와 비밀번호를 입력해 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final (user, failure) = await ref.read(loginProvider)(
      userId: userId,
      password: password,
    );

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = failure.message;
      });
      return;
    }

    ref.read(authSessionProvider.notifier).setUser(user!);
    if (!mounted) return;
    context.go(RoutePaths.orders);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Center(
        child: Container(
          width: 400,
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
              Text(
                'TKLaundry',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                '세탁소 관리 시스템',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.s6),
              TkTextField(
                label: '아이디',
                controller: _userIdController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.s4),
              TkTextField(
                label: '비밀번호',
                controller: _passwordController,
                obscureText: true,
                errorText: _errorMessage,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.s6),
              TkButton(
                label: '로그인',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.s3),
              TkButton(
                label: '회원가입',
                variant: TkButtonVariant.ghost,
                onPressed: _isLoading
                    ? null
                    : () => context.push(RoutePaths.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
