import 'package:tklaundry_app/core/errors/failures.dart';
import 'package:tklaundry_app/core/network/api_exception.dart';
import 'package:tklaundry_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tklaundry_app/features/auth/domain/entities/user.dart';
import 'package:tklaundry_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<(User?, Failure?)> login({
    required String userId,
    required String password,
  }) async {
    try {
      final model = await _remote.login(userId: userId, password: password);
      return (model.toEntity(), null);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        return (null, UnauthorizedFailure(e.message, e.traceId));
      }
      return (null, ServerFailure(e.message, traceId: e.traceId));
    } catch (_) {
      return (null, const NetworkFailure());
    }
  }

  @override
  Future<(bool?, Failure?)> isUserIdAvailable(String userId) async {
    try {
      final available = await _remote.isUserIdAvailable(userId);
      return (available, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message, traceId: e.traceId));
    } catch (_) {
      return (null, const NetworkFailure());
    }
  }

  @override
  Future<(User?, Failure?)> register({
    required String userId,
    required String password,
    required String userName,
  }) async {
    try {
      final model = await _remote.register(
        userId: userId,
        password: password,
        userName: userName,
      );
      return (model.toEntity(), null);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        return (null, ValidationFailure(e.message));
      }
      return (null, ServerFailure(e.message, traceId: e.traceId));
    } catch (_) {
      return (null, const NetworkFailure());
    }
  }
}
