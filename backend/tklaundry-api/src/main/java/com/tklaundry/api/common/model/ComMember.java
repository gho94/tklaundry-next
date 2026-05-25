package com.tklaundry.api.common.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ComMember {

	@NotBlank
	private String userId;
	@NotBlank
	@JsonProperty("password")
	private String userPw;
	private String userName;
	private String loginDate;
	private String useYn;
	private String insertUserId;
	private String updateUserId;
	private String insertDate;
	private String updateDate;
}
