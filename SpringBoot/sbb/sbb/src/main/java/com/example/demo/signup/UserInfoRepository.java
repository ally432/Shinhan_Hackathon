package com.example.demo.signup;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.user.UserInfo;

import java.util.Optional;

public interface UserInfoRepository extends JpaRepository<UserInfo, String> {
 Optional<UserInfo> findByUserKey(String userKey);  // userKey로 조회
 Optional<UserInfo> findByUserId(String userId);    // email(userId)로 조회
}
