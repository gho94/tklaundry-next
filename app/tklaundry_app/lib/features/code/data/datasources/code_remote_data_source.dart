import 'package:tklaundry_app/core/network/api_client.dart';
import 'package:tklaundry_app/features/code/data/models/code_item_model.dart';

abstract class CodeRemoteDataSource {
  Future<List<CodeItemModel>> fetchCodes();

  Future<String> fetchNextCodeId({required String pCodeId, String? header});

  Future<CodeItemModel> createCode({
    required String pCodeId,
    required String codeName,
    String? codeId,
    String? insertUserId,
  });

  Future<CodeItemModel> updateCode({
    required String codeId,
    required String codeName,
    String? updateUserId,
  });

  Future<void> deleteCode(String codeId);
}

class CodeRemoteDataSourceImpl implements CodeRemoteDataSource {
  const CodeRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<CodeItemModel>> fetchCodes() async {
    final list = await _client.getJsonList('/codes');
    return list.map(CodeItemModel.fromJson).toList();
  }

  @override
  Future<String> fetchNextCodeId({
    required String pCodeId,
    String? header,
  }) async {
    final value = await _client.getValue(
      '/codes/next-id',
      queryParameters: {
        'pCodeId': pCodeId,
        if (header != null && header.isNotEmpty) 'header': header,
      },
    );
    return value as String;
  }

  @override
  Future<CodeItemModel> createCode({
    required String pCodeId,
    required String codeName,
    String? codeId,
    String? insertUserId,
  }) async {
    final json = await _client.postJson(
      '/codes',
      body: {
        'pCodeId': pCodeId,
        'codeName': codeName,
        if (codeId != null && codeId.isNotEmpty) 'codeId': codeId,
        if (insertUserId != null && insertUserId.isNotEmpty) 'insertUserId': insertUserId,
      },
    );
    return CodeItemModel.fromJson(json);
  }

  @override
  Future<CodeItemModel> updateCode({
    required String codeId,
    required String codeName,
    String? updateUserId,
  }) async {
    final json = await _client.putJson(
      '/codes/$codeId',
      body: {
        'codeName': codeName,
        if (updateUserId != null && updateUserId.isNotEmpty) 'updateUserId': updateUserId,
      },
    );
    return CodeItemModel.fromJson(json);
  }

  @override
  Future<void> deleteCode(String codeId) async {
    await _client.delete('/codes/$codeId');
  }
}
