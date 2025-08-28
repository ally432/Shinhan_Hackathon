package com.example.demo.signup;

import com.example.demo.signup.MemberCreateResponse;
import com.example.demo.user.UserInfo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserInfoService {

 private final UserInfoRepository userInfoRepository;
 
 @Transactional(readOnly = true)
 public String findUserIdByUserKey(String userKey) {
     return userInfoRepository.findByUserKey(userKey)
             .map(UserInfo::getUserId)
             .orElse(null);  // 없으면 null → 컨트롤러에서 404 처리
 }

 @Transactional
 public UserInfo saveFromApi(MemberCreateResponse dto) {
     UserInfo u = new UserInfo();
     u.setUserId(trunc(dto.getUserId(), 40));
     u.setUsername(trunc(dto.getUsername(), 10));
     u.setInstitutionCode(trunc(dto.getInstitutionCode(), 40));
     u.setUserKey(trunc(dto.getUserKey(), 60));

     u.setCreated(dto.getCreated().toLocalDateTime());
     u.setModified(dto.getModified().toLocalDateTime());

     return userInfoRepository.save(u);
 }

 private String trunc(String s, int max) {
     if (s == null) return null;
     return s.length() > max ? s.substring(0, max) : s;
 }
}
