package com.tklaundry.api.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(	
		@NotBlank String userId,
		@NotBlank String password) {
}
