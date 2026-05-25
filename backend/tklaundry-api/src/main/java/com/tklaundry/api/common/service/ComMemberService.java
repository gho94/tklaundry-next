package com.tklaundry.api.common.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tklaundry.api.common.dto.LoginResult;
import com.tklaundry.api.common.dto.MemberProfile;
import com.tklaundry.api.common.dto.MemberSummary;
import com.tklaundry.api.common.exception.MemberErrorCode;
import com.tklaundry.api.common.exception.MemberException;
import com.tklaundry.api.common.mapper.ComMemberMapper;
import com.tklaundry.api.common.model.ComBaseData;
import com.tklaundry.api.common.model.ComMember;
import com.tklaundry.api.util.DateTimeUtil;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComMemberService {

	private final ComMemberMapper comMemberMapper;
	private final ComBaseDataService comBaseDataService;

	@Transactional
	public LoginResult login(String userId, String userPw) {
		ComMember tblComMember = comMemberMapper.getTblComMember(userId, userPw);
		if (tblComMember == null) {
			throw new MemberException(MemberErrorCode.INVALID_CREDENTIALS);
		}
		ComMember loginUpdate = new ComMember();
		loginUpdate.setUserId(userId);
		loginUpdate.setLoginDate(DateTimeUtil.formatDbDateTime(LocalDateTime.now()));
		comMemberMapper.updateTblComMember(loginUpdate);
		List<ComBaseData> codes = comBaseDataService.getCodeList();
		return new LoginResult(tblComMember.getUserId(), tblComMember.getUserName(), codes);
	}

	@Transactional(readOnly = true)
	public List<MemberSummary> listMembers() {
		return comMemberMapper.selectAllTblComMember();
	}

	@Transactional(readOnly = true)
	public boolean isUserIdAvailable(String userId) {
		return comMemberMapper.countByUserId(userId) == 0;
	}

	@Transactional
	public MemberProfile register(ComMember member) {
		String userId = member.getUserId();
		String userName = member.getUserName();
		if (userName == null || userName.isBlank()) {
			throw new MemberException(MemberErrorCode.USER_NAME_REQUIRED);
		}
		if (comMemberMapper.countByUserId(userId) > 0) {
			throw new MemberException(MemberErrorCode.DUPLICATE_USER_ID);
		}

		member.setInsertDate(DateTimeUtil.formatDbDateTime(LocalDateTime.now()));
		member.setInsertUserId(resolveRegisterInsertUserId(member.getInsertUserId(), userId));
		member.setUseYn("Y");
		comMemberMapper.insertTblComMember(member);

		return new MemberProfile(userId, member.getUserName());
	}

	@Transactional
	public MemberProfile updateMember(String userId, ComMember member) {
		if (comMemberMapper.countByUserId(userId) == 0) {
			throw new MemberException(MemberErrorCode.MEMBER_NOT_FOUND, userId);
		}

		if (member.getUseYn() == null || member.getUseYn().isBlank()) {
			member.setUseYn("Y");
		} else {
			member.setUseYn(member.getUseYn().trim());
		}

		if (member.getUpdateUserId() == null || member.getUpdateUserId().isBlank()) {
			member.setUpdateUserId(userId);
		} else {
			member.setUpdateUserId(member.getUpdateUserId().trim());
		}

		member.setUserId(userId);
		member.setUserPw(member.getUserPw().trim());
		member.setUserName(member.getUserName().trim());
		member.setUpdateDate(DateTimeUtil.formatDbDateTime(LocalDateTime.now()));
		comMemberMapper.updateTblComMemberProfile(member);

		return new MemberProfile(userId, member.getUserName());
	}

	@Transactional
	public void deleteMember(String userId) {
		if (comMemberMapper.countByUserId(userId) == 0) {
			throw new MemberException(MemberErrorCode.MEMBER_NOT_FOUND, userId);
		}
		comMemberMapper.deleteTblComMember(userId);
	}

	private static String resolveRegisterInsertUserId(String insertUserId, String newUserId) {
		if (insertUserId != null && !insertUserId.isBlank()) {
			return insertUserId.trim();
		}
		return newUserId;
	}
}
