package com.tklaundry.api.common.dto;

import java.util.List;

import com.tklaundry.api.common.model.ComBaseData;

public record LoginResult(String userId, String userName, List<ComBaseData> codes) {}
