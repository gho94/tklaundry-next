import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tklaundry_app/core/constants/route_paths.dart';
import 'package:tklaundry_app/core/theme/app_colors.dart';
import 'package:tklaundry_app/core/theme/app_layout.dart';
import 'package:tklaundry_app/core/theme/app_spacing.dart';
import 'package:tklaundry_app/features/auth/presentation/providers/auth_session_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(authSessionProvider)?.userName ?? '';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(currentPath: location),
          Expanded(
            child: Column(
              children: [
                _TopBar(dateLabel: today, userName: userName),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppLayout.sidebarWidth,
      color: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Text(
              'TKLaundry',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.neutral0,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          _NavItem(
            icon: Icons.inbox_outlined,
            label: '접수',
            path: RoutePaths.orders,
            isActive: currentPath.startsWith(RoutePaths.orders),
          ),
          const Spacer(),
          const Divider(color: AppColors.neutral600, height: 1),
          _NavItem(
            icon: Icons.settings_outlined,
            label: '설정',
            path: RoutePaths.settings,
            isActive: currentPath.startsWith(RoutePaths.settings),
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final String path;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.neutral0 : AppColors.neutral400;

    return Material(
      color: isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
      child: InkWell(
        onTap: () => context.go(path),
        child: Container(
          decoration: isActive
              ? const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 3),
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.s3),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.dateLabel, required this.userName});

  final String dateLabel;
  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: AppLayout.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      decoration: const BoxDecoration(
        color: AppColors.neutral0,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(dateLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: AppSpacing.s4),
          Text(userName, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.s2),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authSessionProvider.notifier).clear();
                context.go(RoutePaths.login);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('로그아웃')),
            ],
          ),
        ],
      ),
    );
  }
}
