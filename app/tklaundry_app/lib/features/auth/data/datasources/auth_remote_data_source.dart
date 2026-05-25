import 'package:tklaundry_app/core/network/api_client.dart';
import 'package:tklaundry_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String userId,
    required String password,
  });

  Future<bool> isUserIdAvailable(String userId);

  Future<UserModel> register({
    required String userId,
    required String password,
    required String userName,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<UserModel> login({
    required String userId,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/auth/login',
      body: {'userId': userId, 'password': password},
    );
    return UserModel.fromJson(json);
  }

  @override
  Future<bool> isUserIdAvailable(String userId) async {
    final value = await _client.getValue(
      '/auth/check-user-id',
      queryParameters: {'userId': userId},
    );
    return value == true;
  }

  @override
  Future<UserModel> register({
    required String userId,
    required String password,
    required String userName,
  }) async {
    final json = await _client.postJson(
      '/auth/register',
      body: {
        'userId': userId,
        'password': password,
        'userName': userName,
      },
    );
    return UserModel.fromJson(json);
  }
}
