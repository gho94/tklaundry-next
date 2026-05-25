import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tklaundry_app/core/network/api_client.dart';
import 'package:tklaundry_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tklaundry_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tklaundry_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:tklaundry_app/features/auth/domain/usecases/login.dart';
import 'package:tklaundry_app/features/code/data/datasources/code_remote_data_source.dart';
import 'package:tklaundry_app/features/member/data/datasources/member_remote_data_source.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

final loginProvider = Provider<Login>(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);

final codeRemoteDataSourceProvider = Provider<CodeRemoteDataSource>(
  (ref) => CodeRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final memberRemoteDataSourceProvider = Provider<MemberRemoteDataSource>(
  (ref) => MemberRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
