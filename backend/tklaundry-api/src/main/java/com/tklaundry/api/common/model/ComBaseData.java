package com.tklaundry.api.common.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ComBaseData {

	@Size(max = 6)
	private String codeId;
	@NotBlank
	private String codeName;
	@Size(max = 6)
	private String pCodeId;
	private int grade;
	private String insertUserId;
	private String insertDate;
	private String updateUserId;
	private String updateDate;
}
