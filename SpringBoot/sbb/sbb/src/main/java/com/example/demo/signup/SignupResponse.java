package com.example.demo.signup;

public class SignupResponse {
	public String userId;
    public String username;
    public String institutionCode;
    public String userKey;

    public SignupResponse(String userId, String username, String institutionCode, String userKey) {
        this.userId = userId;
        this.username = username;
        this.institutionCode = institutionCode;
        this.userKey = userKey;
    }
}
