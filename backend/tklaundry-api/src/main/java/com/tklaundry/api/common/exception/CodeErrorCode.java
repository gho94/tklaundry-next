package com.tklaundry.api.common.exception;

import org.springframework.http.HttpStatus;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum CodeErrorCode {

	CODE_NOT_FOUND(HttpStatus.NOT_FOUND, "CODE_NOT_FOUND", "코드를 찾을 수 없습니다: %s"),
	DUPLICATE_CODE_ID(HttpStatus.CONFLICT, "DUPLICATE_CODE_ID", "이미 등록된 코드입니다: %s"),
	CODE_NAME_REQUIRED(HttpStatus.BAD_REQUEST, "CODE_NAME_REQUIRED", "코드명을 입력해 주세요."),
	P_CODE_ID_REQUIRED(HttpStatus.BAD_REQUEST, "P_CODE_ID_REQUIRED", "상위 코드를 선택해 주세요."),
	HEADER_TOO_SHORT(HttpStatus.BAD_REQUEST, "HEADER_TOO_SHORT", "코드 헤더는 2자 이상이어야 합니다.");

	private final HttpStatus httpStatus;
	private final String apiCode;
	private final String messageTemplate;

	public String formatMessage(Object... args) {
		return args == null || args.length == 0 ? messageTemplate : String.format(messageTemplate, args);
	}
}
