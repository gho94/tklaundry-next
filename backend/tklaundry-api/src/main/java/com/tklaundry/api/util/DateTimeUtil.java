package com.tklaundry.api.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public final class DateTimeUtil {

	private static final DateTimeFormatter DB_DATETIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

	private DateTimeUtil() {
	}

	public static String formatDbDateTime(LocalDateTime dateTime) {
		return DB_DATETIME_FORMATTER.format(dateTime);
	}
}
