class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.traceId,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final String? traceId;

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}
