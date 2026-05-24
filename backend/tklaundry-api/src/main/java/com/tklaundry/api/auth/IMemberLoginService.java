package com.tklaundry.api.auth;

import com.tklaundry.api.auth.dto.LoginResponse;

public interface IMemberLoginService {

	LoginResponse login(String userId, String password);
}
