package com.example.demo.auth;

import com.example.demo.user.UserInfo;
import com.example.demo.signup.UserInfoRepository;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
public class AuthController {

 private final UserInfoRepository userInfoRepository;

 @PostMapping("/login")
 public ResponseEntity<?> login(@RequestBody LoginRequest req) {
     if (req.getUserId() == null || req.getUserId().isBlank()) {
         return ResponseEntity.badRequest().body(new ErrorResponse("USER_ID_REQUIRED"));
     }

     Optional<UserInfo> opt = userInfoRepository.findById(req.getUserId());
     if (opt.isEmpty()) {
         return ResponseEntity.status(401).body(new ErrorResponse("INVALID_CREDENTIALS"));
     }

     UserInfo u = opt.get();
     return ResponseEntity.ok(new LoginSuccess(u.getUserId(), u.getUsername(), u.getUserKey()));
 }

 @Data
 public static class LoginRequest {
     private String userId;
 }

 @Data
 public static class LoginSuccess {
     private final String userId;
     private final String username;
     private final String userKey;
 }

 @Data
 public static class ErrorResponse {
     private final String code;
 }
}
