package com.tklaundry.api.member;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ComMember {

	private String userId;
	private String userPw;
	private String userName;
	private String loginDate;
	private String useYn;
}
