import 'package:tklaundry_app/core/errors/failures.dart';
import 'package:tklaundry_app/features/auth/domain/entities/user.dart';
import 'package:tklaundry_app/features/auth/domain/repositories/auth_repository.dart';

class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<(User?, Failure?)> call({
    required String userId,
    required String password,
  }) {
    return _repository.login(userId: userId, password: password);
  }
}
