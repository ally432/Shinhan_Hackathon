package com.example.demo.auto;

public interface UserLookupService {
record UserAccount(String userKey, String accountNo) {}
UserAccount resolveByEmail(String email);

// ⬇️ 추가: userKey로 최신 수시입출금 계좌 구하기
String findLatestDemandAccountNoByUserKey(String userKey);
}
