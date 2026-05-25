package com.tklaundry.api.common.exception;

import org.springframework.http.HttpStatus;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum MemberErrorCode {

	INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "아이디 또는 비밀번호가 올바르지 않습니다."),
	DUPLICATE_USER_ID(HttpStatus.CONFLICT, "DUPLICATE_USER_ID", "이미 사용중인 아이디입니다."),
	MEMBER_NOT_FOUND(HttpStatus.NOT_FOUND, "MEMBER_NOT_FOUND", "회원을 찾을 수 없습니다: %s"),
	USER_NAME_REQUIRED(HttpStatus.BAD_REQUEST, "USER_NAME_REQUIRED", "회원명을 입력해 주세요.");

	private final HttpStatus httpStatus;
	private final String apiCode;
	private final String messageTemplate;

	public String formatMessage(Object... args) {
		return args == null || args.length == 0 ? messageTemplate : String.format(messageTemplate, args);
	}
}
