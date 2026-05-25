import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tklaundry_app/core/constants/route_paths.dart';
import 'package:tklaundry_app/features/auth/presentation/pages/login_page.dart';
import 'package:tklaundry_app/features/auth/presentation/pages/register_page.dart';
import 'package:tklaundry_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:tklaundry_app/features/code/presentation/pages/code_list_page.dart';
import 'package:tklaundry_app/features/member/presentation/pages/member_list_page.dart';
import 'package:tklaundry_app/features/order/presentation/pages/order_list_page.dart';
import 'package:tklaundry_app/features/settings/presentation/pages/settings_page.dart';
import 'package:tklaundry_app/shared/layout/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(authSessionProvider, (previous, next) {
    refreshNotifier.value++;
  });
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RoutePaths.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final loggedIn = ref.read(authSessionProvider) != null;
      final location = state.matchedLocation;
      final isPublic = RoutePaths.publicPaths.contains(location);

      if (!loggedIn && !isPublic) return RoutePaths.login;
      if (loggedIn && (location == RoutePaths.login || location == RoutePaths.register)) {
        return RoutePaths.orders;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.orders,
            builder: (context, state) => const OrderListPage(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'codes',
                builder: (context, state) => const CodeListPage(),
              ),
              GoRoute(
                path: 'members',
                builder: (context, state) => const MemberListPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
