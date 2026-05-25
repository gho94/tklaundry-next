import 'package:tklaundry_app/core/network/api_client.dart';
import 'package:tklaundry_app/features/member/data/models/member_summary_model.dart';

abstract class MemberRemoteDataSource {
  Future<List<MemberSummaryModel>> fetchMembers();

  Future<bool> isUserIdAvailable(String userId);

  Future<void> registerMember({
    required String userId,
    required String userName,
    required String password,
    String? insertUserId,
  });

  Future<MemberSummaryModel> updateMember({
    required String userId,
    required String userName,
    required String password,
    required String useYn,
    String? updateUserId,
  });

  Future<void> deleteMember(String userId);
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  const MemberRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<MemberSummaryModel>> fetchMembers() async {
    final list = await _client.getJsonList('/auth/members');
    return list.map(MemberSummaryModel.fromJson).toList();
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
  Future<void> registerMember({
    required String userId,
    required String userName,
    required String password,
    String? insertUserId,
  }) async {
    await _client.postJson(
      '/auth/register',
      body: {
        'userId': userId,
        'password': password,
        'userName': userName,
        if (insertUserId != null && insertUserId.isNotEmpty) 'insertUserId': insertUserId,
      },
    );
  }

  @override
  Future<MemberSummaryModel> updateMember({
    required String userId,
    required String userName,
    required String password,
    required String useYn,
    String? updateUserId,
  }) async {
    await _client.putJson(
      '/auth/members/$userId',
      body: {
        'userId': userId,
        'password': password,
        'userName': userName,
        'useYn': useYn,
        if (updateUserId != null && updateUserId.isNotEmpty) 'updateUserId': updateUserId,
      },
    );
    final members = await fetchMembers();
    return members.firstWhere((m) => m.userId == userId);
  }

  @override
  Future<void> deleteMember(String userId) async {
    await _client.delete('/auth/members/$userId');
  }
}
