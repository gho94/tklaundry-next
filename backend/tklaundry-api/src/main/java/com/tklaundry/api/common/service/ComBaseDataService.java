package com.tklaundry.api.common.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tklaundry.api.common.exception.CodeErrorCode;
import com.tklaundry.api.common.exception.CodeException;
import com.tklaundry.api.common.mapper.ComBaseDataMapper;
import com.tklaundry.api.common.model.ComBaseData;
import com.tklaundry.api.util.DateTimeUtil;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComBaseDataService {

	private final ComBaseDataMapper comBaseDataMapper;

	@Transactional(readOnly = true)
	public List<ComBaseData> getCodeList() {
		return comBaseDataMapper.selectCodeListCte();
	}

	@Transactional(readOnly = true)
	public String selectLastCodeHeader() {
		String lastCodeId = comBaseDataMapper.selectMaxCodeId();
		if (lastCodeId == null || lastCodeId.isBlank()) {
			return "A0";
		}
		char first = lastCodeId.trim().charAt(0);
		return ((char) (first + 1)) + "0";
	}

	@Transactional(readOnly = true)
	public String createLastCodeId(String header) {
		String normalizedHeader = header.trim();
		if (normalizedHeader.length() < 2) {
			throw new CodeException(CodeErrorCode.HEADER_TOO_SHORT);
		}
		String lastCodeId = comBaseDataMapper.selectLastCodeIdByHeader(normalizedHeader);
		if (lastCodeId == null || lastCodeId.isBlank()) {
			return normalizedHeader + "0001";
		}
		String trimmed = lastCodeId.trim();
		int sequence = Integer.parseInt(trimmed.substring(2)) + 1;
		return normalizedHeader + String.format("%04d", sequence);
	}

	@Transactional(readOnly = true)
	public String resolveNextCodeId(String pCodeId, String header) {
		return createLastCodeId(resolveHeader(pCodeId, header));
	}

	@Transactional
	public ComBaseData createCode(ComBaseData code) {
		code.setCodeName(code.getCodeName().trim());
		code.setPCodeId(normalizePCodeId(code.getPCodeId()));
		code.setInsertUserId(resolveInsertUserId(code.getInsertUserId()));
		code.setInsertDate(DateTimeUtil.formatDbDateTime(LocalDateTime.now()));

		String codeId = code.getCodeId();
		if (codeId == null || codeId.isBlank()) {
			code.setCodeId(resolveNextCodeId(code.getPCodeId(), null));
		} else {
			code.setCodeId(codeId.trim());
		}

		if (comBaseDataMapper.countByCodeId(code.getCodeId()) > 0) {
			throw new CodeException(CodeErrorCode.DUPLICATE_CODE_ID, code.getCodeId());
		}

		comBaseDataMapper.insertTblComBaseData(code);
		code.setGrade(findGrade(code.getCodeId()));
		return code;
	}

	@Transactional
	public ComBaseData updateCode(String codeId, ComBaseData patch) {
		String normalizedId = codeId.trim();
		ensureCodeExists(normalizedId);

		if (patch.getCodeName() == null || patch.getCodeName().isBlank()) {
			throw new CodeException(CodeErrorCode.CODE_NAME_REQUIRED);
		}

		ComBaseData update = new ComBaseData();
		update.setCodeId(normalizedId);
		update.setCodeName(patch.getCodeName().trim());
		update.setUpdateDate(DateTimeUtil.formatDbDateTime(LocalDateTime.now()));
		update.setUpdateUserId(resolveInsertUserId(patch.getUpdateUserId()));
		comBaseDataMapper.updateTblComBaseData(update);

		update.setGrade(findGrade(normalizedId));
		return update;
	}

	@Transactional
	public void deleteCode(String codeId) {
		String normalizedId = codeId.trim();
		ensureCodeExists(normalizedId);
		deleteCodeRecursive(normalizedId);
	}

	private void deleteCodeRecursive(String codeId) {
		for (String childId : comBaseDataMapper.selectCodeIdsByPCodeId(codeId)) {
			deleteCodeRecursive(childId.trim());
		}
		comBaseDataMapper.deleteTblComBaseData(codeId);
	}

	private String resolveHeader(String pCodeId, String header) {
		if (header != null && !header.isBlank()) {
			return header.trim();
		}
		if (isRootParent(pCodeId)) {
			return selectLastCodeHeader();
		}
		ComBaseData parent = findCode(pCodeId);
		String parentCodeId = parent.getCodeId().trim();
		return parentCodeId.substring(0, 1) + (parent.getGrade() + 1);
	}

	private ComBaseData findCode(String codeId) {
		return getCodeList().stream()
				.filter(code -> code.getCodeId().trim().equalsIgnoreCase(codeId.trim()))
				.findFirst()
				.orElseThrow(() -> new CodeException(CodeErrorCode.CODE_NOT_FOUND, codeId));
	}

	private int findGrade(String codeId) {
		return findCode(codeId).getGrade();
	}

	private void ensureCodeExists(String codeId) {
		if (comBaseDataMapper.countByCodeId(codeId) == 0) {
			throw new CodeException(CodeErrorCode.CODE_NOT_FOUND, codeId);
		}
	}

	private static boolean isRootParent(String pCodeId) {
		if (pCodeId == null) {
			return false;
		}
		String normalized = pCodeId.trim();
		return "Root".equalsIgnoreCase(normalized) || "ROOT".equalsIgnoreCase(normalized);
	}

	private static String normalizePCodeId(String pCodeId) {
		if (pCodeId == null || pCodeId.isBlank()) {
			throw new CodeException(CodeErrorCode.P_CODE_ID_REQUIRED);
		}
		String trimmed = pCodeId.trim();
		if (isRootParent(trimmed)) {
			return "Root";
		}
		return trimmed;
	}

	private static String resolveInsertUserId(String insertUserId) {
		if (insertUserId == null || insertUserId.isBlank()) {
			return "system";
		}
		return insertUserId.trim();
	}
}
