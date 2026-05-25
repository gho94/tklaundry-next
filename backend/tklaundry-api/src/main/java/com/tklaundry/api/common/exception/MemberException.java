package com.tklaundry.api.common.exception;

import lombok.Getter;

@Getter
public class MemberException extends RuntimeException {

	private final MemberErrorCode errorCode;

	public MemberException(MemberErrorCode errorCode) {
		super(errorCode.getMessageTemplate());
		this.errorCode = errorCode;
	}

	public MemberException(MemberErrorCode errorCode, Object... messageArgs) {
		super(errorCode.formatMessage(messageArgs));
		this.errorCode = errorCode;
	}
}
