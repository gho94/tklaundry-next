package com.tklaundry.api.common.dto;

public record MemberSummary(
		String userId,
		String userName,
		String loginDate,
		String useYn,
		String insertDate,
		String updateDate,
		String insertUserId,
		String updateUserId) {}
