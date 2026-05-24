import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tklaundry_app/core/constants/api_constants.dart';
import 'package:tklaundry_app/core/network/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiConstants.apiPrefix}$path');
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          ...?headers,
        },
        body: body == null ? null : jsonEncode(body),
      );
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'API 요청 중 오류가 발생했습니다: $e');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final status = response.statusCode;
    Map<String, dynamic>? jsonBody;
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        jsonBody = decoded;
      }
    }

    if (status >= 200 && status < 300) {
      return jsonBody ?? {};
    }

    final message = jsonBody?['message'] as String? ??
        '서버 응답을 처리할 수 없습니다. (HTTP $status)';
    throw ApiException(
      message: message,
      statusCode: status,
      code: jsonBody?['code'] as String?,
      traceId: jsonBody?['traceId'] as String?,
    );
  }
}
