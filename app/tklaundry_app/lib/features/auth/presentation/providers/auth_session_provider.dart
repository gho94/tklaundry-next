import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tklaundry_app/features/auth/domain/entities/user.dart';

class AuthSessionNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User user) => state = user;

  void clear() => state = null;
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, User?>(AuthSessionNotifier.new);

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(authSessionProvider) != null,
);
