sealed class Failure {
  const Failure(this.message, {this.traceId});

  final String message;
  final String? traceId;
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.traceId});
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크 연결을 확인해 주세요.']);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = '아이디 또는 비밀번호가 올바르지 않습니다.',
    String? traceId,
  ]) : super(traceId: traceId);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
