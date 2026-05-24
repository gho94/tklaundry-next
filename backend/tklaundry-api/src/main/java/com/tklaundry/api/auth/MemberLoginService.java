package com.tklaundry.api.auth;

import java.time.LocalDateTime;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tklaundry.api.auth.dto.LoginResponse;
import com.tklaundry.api.member.ComMember;
import com.tklaundry.api.member.ComMemberMapper;
import com.tklaundry.api.util.DateTimeUtil;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberLoginService implements IMemberLoginService {

	private final ComMemberMapper comMemberMapper;

	@Override
	@Transactional
	public LoginResponse login(String userId, String password) {
		ComMember member = comMemberMapper.getTblComMember(userId, password);
		if (member == null) {
			throw new InvalidCredentialsException();
		}
		String loginDate = DateTimeUtil.formatLogInDate(LocalDateTime.now());
		comMemberMapper.updateTblComMember(userId, loginDate);
		return new LoginResponse(member.getUserId(), member.getUserName());
	}
}
