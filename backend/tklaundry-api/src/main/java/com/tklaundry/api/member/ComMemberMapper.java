package com.tklaundry.api.member;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ComMemberMapper {

	ComMember getTblComMember(@Param("userId") String userId, @Param("userPw") String userPw);

	int updateTblComMember(@Param("userId") String userId, @Param("loginDate") String loginDate);
}
