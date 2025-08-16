// com.example.demo.signup.MemberCreateResponse
package com.example.demo.signup;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.OffsetDateTime;

public class MemberCreateResponse {
    private String userId;

    @JsonProperty("userName")
    private String username;

    private String institutionCode;
    private String userKey;

    // 2025-08-16T21:38:32.901976593+09:00 형식
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSXXX")
    private OffsetDateTime created;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSXXX")
    private OffsetDateTime modified;

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getInstitutionCode() { return institutionCode; }
    public void setInstitutionCode(String institutionCode) { this.institutionCode = institutionCode; }
    public String getUserKey() { return userKey; }
    public void setUserKey(String userKey) { this.userKey = userKey; }
    public OffsetDateTime getCreated() { return created; }
    public void setCreated(OffsetDateTime created) { this.created = created; }
    public OffsetDateTime getModified() { return modified; }
    public void setModified(OffsetDateTime modified) { this.modified = modified; }
}
