package com.example.demo.signup;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.user.UserInfo;

public interface UserInfoRepository extends JpaRepository<UserInfo, String> {
	
}
