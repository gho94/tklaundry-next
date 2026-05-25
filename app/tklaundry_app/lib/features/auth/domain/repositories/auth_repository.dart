import 'package:tklaundry_app/core/errors/failures.dart';
import 'package:tklaundry_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<(User?, Failure?)> login({
    required String userId,
    required String password,
  });

  Future<(bool?, Failure?)> isUserIdAvailable(String userId);

  Future<(User?, Failure?)> register({
    required String userId,
    required String password,
    required String userName,
  });
}
