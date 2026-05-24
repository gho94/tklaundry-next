import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tklaundry_app/core/constants/route_paths.dart';
import 'package:tklaundry_app/features/auth/presentation/pages/login_page.dart';
import 'package:tklaundry_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:tklaundry_app/features/order/presentation/pages/order_list_page.dart';
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
      final onLogin = state.matchedLocation == RoutePaths.login;

      if (!loggedIn && !onLogin) return RoutePaths.login;
      if (loggedIn && onLogin) return RoutePaths.orders;
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
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
            builder: (context, state) => const _PlaceholderPage(title: '설정'),
          ),
        ],
      ),
    ],
  );
});

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title 준비중'));
  }
}
