package com.tklaundry.api.common.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.common.dto.LoginResult;
import com.tklaundry.api.common.dto.MemberProfile;
import com.tklaundry.api.common.dto.MemberSummary;
import com.tklaundry.api.common.model.ComMember;
import com.tklaundry.api.common.service.ComMemberService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class MemberController {

	private final ComMemberService comMemberService;

	@PostMapping("/login")
	public ResponseEntity<LoginResult> login(@Valid @RequestBody ComMember request) {
		LoginResult body = comMemberService.login(request.getUserId().trim(), request.getUserPw().trim());
		return ResponseEntity.ok(body);
	}

	@GetMapping("/members")
	public List<MemberSummary> listMembers() {
		return comMemberService.listMembers();
	}

	@GetMapping("/check-user-id")
	public boolean checkUserId(@RequestParam("userId") String userId) {
		return comMemberService.isUserIdAvailable(userId.trim());
	}

	@PostMapping("/register")
	public ResponseEntity<MemberProfile> register(@Valid @RequestBody ComMember request) {
		request.setUserId(request.getUserId().trim());
		request.setUserPw(request.getUserPw().trim());
		request.setUserName(request.getUserName().trim());
		MemberProfile body = comMemberService.register(request);
		return ResponseEntity.status(HttpStatus.CREATED).body(body);
	}

	@PutMapping("/members/{userId}")
	public MemberProfile updateMember(@PathVariable String userId, @Valid @RequestBody ComMember request) {
		return comMemberService.updateMember(userId.trim(), request);
	}

	@DeleteMapping("/members/{userId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deleteMember(@PathVariable String userId) {
		comMemberService.deleteMember(userId.trim());
	}
}
