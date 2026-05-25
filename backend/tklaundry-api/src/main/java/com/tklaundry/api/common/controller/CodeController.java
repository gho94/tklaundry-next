package com.tklaundry.api.common.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.common.model.ComBaseData;
import com.tklaundry.api.common.service.ComBaseDataService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/codes")
@RequiredArgsConstructor
public class CodeController {

	private final ComBaseDataService comBaseDataService;

	@GetMapping
	public List<ComBaseData> list() {
		return comBaseDataService.getCodeList();
	}

	@GetMapping("/next-header")
	public String nextHeader() {
		return comBaseDataService.selectLastCodeHeader();
	}

	@GetMapping("/next-id")
	public String nextId(
			@RequestParam("pCodeId") String pCodeId,
			@RequestParam(value = "header", required = false) String header) {
		return comBaseDataService.resolveNextCodeId(pCodeId.trim(), header != null ? header.trim() : null);
	}

	@PostMapping
	public ResponseEntity<ComBaseData> create(@Valid @RequestBody ComBaseData request) {
		if (request.getPCodeId() != null) {
			request.setPCodeId(request.getPCodeId().trim());
		}
		if (request.getCodeId() != null) {
			request.setCodeId(request.getCodeId().trim());
		}
		request.setCodeName(request.getCodeName().trim());
		ComBaseData body = comBaseDataService.createCode(request);
		return ResponseEntity.status(HttpStatus.CREATED).body(body);
	}

	@PutMapping("/{codeId}")
	public ComBaseData update(@PathVariable String codeId, @Valid @RequestBody ComBaseData request) {
		return comBaseDataService.updateCode(codeId.trim(), request);
	}

	@DeleteMapping("/{codeId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable String codeId) {
		comBaseDataService.deleteCode(codeId.trim());
	}
}
