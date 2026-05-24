import 'package:tklaundry_app/core/network/api_client.dart';
import 'package:tklaundry_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String userId,
    required String password,
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
}
