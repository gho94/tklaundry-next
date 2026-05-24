package com.tklaundry.api.web;

import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import com.tklaundry.api.auth.InvalidCredentialsException;

@RestControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(InvalidCredentialsException.class)
	public ResponseEntity<ApiErrorBody> invalidCredentials(InvalidCredentialsException ex, WebRequest request) {
		String traceId = traceId(request);
		var body = new ApiErrorBody("UNAUTHORIZED", ex.getMessage(), traceId, null);
		return ResponseEntity.status(HttpStatus.UNAUTHORIZED).header("X-Request-Id", traceId).body(body);
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<ApiErrorBody> validation(MethodArgumentNotValidException ex, WebRequest request) {
		String traceId = traceId(request);
		var body = new ApiErrorBody(
				"VALIDATION_ERROR",
				"요청 값을 확인하세요.",
				traceId,
				Map.of());
		return ResponseEntity.status(HttpStatus.BAD_REQUEST).header("X-Request-Id", traceId).body(body);
	}

	private static String traceId(WebRequest request) {
		String header = request.getHeader("X-Request-Id");
		if (header != null && !header.isBlank()) {
			return header.trim();
		}
		return UUID.randomUUID().toString();
	}
}
