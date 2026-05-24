package com.tklaundry.api.web;

import java.util.Map;

public record ApiErrorBody(String code, String message, String traceId, Map<String, Object> details) {
}
