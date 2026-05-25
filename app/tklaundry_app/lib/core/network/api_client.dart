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

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _send(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
    final decoded = _decodeBody(response);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException(message: '서버 응답 형식이 올바르지 않습니다.');
  }

  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _send(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
    final decoded = _decodeBody(response);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw ApiException(message: '서버 응답 형식이 올바르지 않습니다.');
  }

  Future<dynamic> getValue(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _send(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
    return _decodeBody(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _send(
      'POST',
      path,
      body: body,
      headers: headers,
    );
    final decoded = _decodeBody(response);
    if (decoded is Map<String, dynamic>) return decoded;
    return {};
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _send(
      'PUT',
      path,
      body: body,
      headers: headers,
    );
    final decoded = _decodeBody(response);
    if (decoded is Map<String, dynamic>) return decoded;
    return {};
  }

  Future<void> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    await _send('DELETE', path, headers: headers);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiConstants.apiPrefix}$path')
        .replace(queryParameters: queryParameters);
    final commonHeaders = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      ...?headers,
    };
    try {
      final encodedBody = body == null ? null : jsonEncode(body);
      final response = switch (method) {
        'GET' => await _client.get(uri, headers: commonHeaders),
        'POST' => await _client.post(uri, headers: commonHeaders, body: encodedBody),
        'PUT' => await _client.put(uri, headers: commonHeaders, body: encodedBody),
        'DELETE' => await _client.delete(uri, headers: commonHeaders),
        _ => throw ApiException(message: '지원하지 않는 HTTP 메서드입니다: $method'),
      };
      _decodeBody(response);
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'API 요청 중 오류가 발생했습니다: $e');
    }
  }

  dynamic _decodeBody(http.Response response) {
    final status = response.statusCode;
    Map<String, dynamic>? jsonBody;
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        jsonBody = decoded;
      }
    }

    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
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
