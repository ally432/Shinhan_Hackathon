package com.example.demo.auto;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserLookupServiceImpl implements UserLookupService {

private final JdbcTemplate jdbc;

private static final String SQL_USERKEY_BY_EMAIL =
   "SELECT user_key FROM user_info WHERE user_id = ? LIMIT 1";

private static final String SQL_DEMAND_ACC_BY_USERKEY =
   "SELECT account_no FROM demand_deposit_account " +
   "WHERE user_key = ? ORDER BY created DESC LIMIT 1";

@Override
public UserAccount resolveByEmail(String email) {
 String userKey = jdbc.queryForObject(SQL_USERKEY_BY_EMAIL, String.class, email);
 String accountNo = jdbc.queryForObject(SQL_DEMAND_ACC_BY_USERKEY, String.class, userKey);
 return new UserAccount(userKey, accountNo);
}

@Override
public String findLatestDemandAccountNoByUserKey(String userKey) {
 try {
   return jdbc.queryForObject(SQL_DEMAND_ACC_BY_USERKEY, String.class, userKey);
 } catch (EmptyResultDataAccessException e) {
   throw new IllegalStateException("수시입출금 계좌 없음: userKey=" + mask(userKey));
 }
}

private String mask(String v) {
 if (v == null || v.length() < 8) return "****";
 return v.substring(0, 4) + "****" + v.substring(v.length() - 4);
}
}
