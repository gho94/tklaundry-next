package com.tklaundry.api.common.exception;

import lombok.Getter;

@Getter
public class CodeException extends RuntimeException {

	private final CodeErrorCode errorCode;

	public CodeException(CodeErrorCode errorCode) {
		super(errorCode.getMessageTemplate());
		this.errorCode = errorCode;
	}

	public CodeException(CodeErrorCode errorCode, Object... messageArgs) {
		super(errorCode.formatMessage(messageArgs));
		this.errorCode = errorCode;
	}
}
