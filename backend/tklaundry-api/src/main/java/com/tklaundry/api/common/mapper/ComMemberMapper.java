package com.tklaundry.api.common.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.common.dto.MemberSummary;
import com.tklaundry.api.common.model.ComMember;

@Mapper
public interface ComMemberMapper {

	ComMember getTblComMember(@Param("userId") String userId, @Param("userPw") String userPw);

	int updateTblComMember(ComMember member);

	int countByUserId(@Param("userId") String userId);

	int insertTblComMember(ComMember member);

	int updateTblComMemberProfile(ComMember member);

	List<MemberSummary> selectAllTblComMember();

	int deleteTblComMember(@Param("userId") String userId);
}
