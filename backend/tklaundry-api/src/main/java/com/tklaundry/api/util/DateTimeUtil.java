package com.tklaundry.api.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public final class DateTimeUtil {

	private static final DateTimeFormatter LOG_IN_DATE_FORMATTER =
			DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

	private DateTimeUtil() {
	}

	public static String formatLogInDate(LocalDateTime dateTime) {
		return LOG_IN_DATE_FORMATTER.format(dateTime);
	}
}
