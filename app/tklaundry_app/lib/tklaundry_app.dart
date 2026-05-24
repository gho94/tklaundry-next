import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tklaundry_app/core/router/app_router.dart';
import 'package:tklaundry_app/core/theme/app_theme.dart';

class TkLaundryApp extends ConsumerWidget {
  const TkLaundryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TKLaundry',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
