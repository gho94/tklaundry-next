package com.tklaundry.api.web;

import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import com.tklaundry.api.common.exception.CodeException;
import com.tklaundry.api.common.exception.MemberException;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(MemberException.class)
	public ResponseEntity<ApiErrorBody> memberException(MemberException ex, WebRequest request) {
		var code = ex.getErrorCode();
		return logAndRespond(ex, code.getHttpStatus(), code.getApiCode(), ex.getMessage(), request);
	}

	@ExceptionHandler(CodeException.class)
	public ResponseEntity<ApiErrorBody> codeException(CodeException ex, WebRequest request) {
		var code = ex.getErrorCode();
		return logAndRespond(ex, code.getHttpStatus(), code.getApiCode(), ex.getMessage(), request);
	}

	@ExceptionHandler(IllegalArgumentException.class)
	public ResponseEntity<ApiErrorBody> badRequest(IllegalArgumentException ex, WebRequest request) {
		return logAndRespond(ex, HttpStatus.BAD_REQUEST, "BAD_REQUEST", ex.getMessage(), request);
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<ApiErrorBody> validation(MethodArgumentNotValidException ex, WebRequest request) {
		String traceId = traceId(request);
		log.warn("[{}] VALIDATION_ERROR {} — {}", traceId, requestPath(request), ex.getMessage());
		var body = new ApiErrorBody("VALIDATION_ERROR", "요청 값을 확인하세요.", traceId, Map.of());
		return ResponseEntity.status(HttpStatus.BAD_REQUEST).header("X-Request-Id", traceId).body(body);
	}

	@ExceptionHandler(Exception.class)
	public ResponseEntity<ApiErrorBody> unexpected(Exception ex, WebRequest request) {
		String traceId = traceId(request);
		log.error("[{}] INTERNAL_ERROR {} — {}", traceId, requestPath(request), ex.getMessage(), ex);
		var body = new ApiErrorBody("INTERNAL_ERROR", "서버 오류가 발생했습니다.", traceId, Map.of());
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).header("X-Request-Id", traceId).body(body);
	}

	private ResponseEntity<ApiErrorBody> logAndRespond(
			Exception ex,
			HttpStatus status,
			String code,
			String message,
			WebRequest request) {
		String traceId = traceId(request);
		log.warn("[{}] {} {} — {}", traceId, code, requestPath(request), message);
		var body = new ApiErrorBody(code, message, traceId, Map.of());
		return ResponseEntity.status(status).header("X-Request-Id", traceId).body(body);
	}

	private static String requestPath(WebRequest request) {
		return request.getDescription(false).replace("uri=", "");
	}

	private static String traceId(WebRequest request) {
		String header = request.getHeader("X-Request-Id");
		if (header != null && !header.isBlank()) {
			return header.trim();
		}
		return UUID.randomUUID().toString();
	}
}
