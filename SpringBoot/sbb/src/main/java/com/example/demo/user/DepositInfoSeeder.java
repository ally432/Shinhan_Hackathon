package com.example.demo.user;

import java.util.List;
import java.util.Optional;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.signup.UserInfoRepository;

@Configuration
@Profile("seed")
public class DepositInfoSeeder {

 // 예시로 사용할 userKey 2개 (이미 UserInfo에 존재해야 FK가 성립합니다)
 // 없으면 해당 레코드는 건너뜁니다.
 private static final String UKEY_A = "97eef193-dd2f-41a3-8880-a957800ee1b9";
 private static final String UKEY_B = "e8a7d57a-8bb7-41d2-ab3d-f03f0cb20ff8";

 @Bean
 CommandLineRunner seedDepositInfo(DepositInfoRepository depositRepo,
                                   UserInfoRepository userInfoRepo) {
     return args -> seed(depositRepo, userInfoRepo);
 }

 @Transactional
 protected void seed(DepositInfoRepository depositRepo,
                     UserInfoRepository userInfoRepo) {

     // A 사용자 (예: 만기이자 조회 예시 JSON 기반)
     maybeInsert(depositRepo, userInfoRepo,
         build(
             /*accountNo*/           "0884106269",
             /*userKey*/             UKEY_A,
             /*bankCode*/            "088",
             /*bankName*/            "신한은행",
             /*accountName*/         "시험보험(test)",
             /*withdrawalBankCode*/  "088",
             /*withdrawalAccountNo*/ "0888692626841303",
             /*subscriptionPeriod*/  "2",            // 20250827 ~ 20250829 → 2일
             /*depositBalance*/      1_500_000L,
             /*interestRate*/        2.05,
             /*createDate*/          "20250827",
             /*expiryDate*/          "20250829",
             /*goal1*/               "4.0",
             /*goal2*/               "4.0"
         )
     );
 }

 private void maybeInsert(DepositInfoRepository depositRepo,
                          UserInfoRepository userInfoRepo,
                          DepositInfo d) {
     // FK(UserInfo.userKey) 존재 확인
     Optional<UserInfo> ui = userInfoRepo.findAll().stream()
             .filter(u -> d.getUserKey().equals(u.getUserKey()))
             .findFirst();

     if (ui.isEmpty()) {
         System.out.println("[DepositInfoSeeder] SKIP (UserInfo not found for userKey=" + d.getUserKey() + ")");
         return;
     }

     if (depositRepo.existsById(d.getAccountNo())) {
         System.out.println("[DepositInfoSeeder] SKIP (already exists accountNo=" + d.getAccountNo() + ")");
         return;
     }

     depositRepo.save(d);
     System.out.println("[DepositInfoSeeder] INSERTED accountNo=" + d.getAccountNo());
 }

 private DepositInfo build(String accountNo,
                           String userKey,
                           String bankCode,
                           String bankName,
                           String accountName,
                           String withdrawalBankCode,
                           String withdrawalAccountNo,
                           String subscriptionPeriod,
                           Long   depositBalance,
                           Double interestRate,
                           String accountCreateDate,
                           String accountExpiryDate,
                           String goalScore1,
                           String goalScore2) {
     DepositInfo d = new DepositInfo();
     d.setAccountNo(trunc(accountNo, 16));
     d.setUserKey(trunc(userKey, 60));
     d.setBankCode(trunc(bankCode, 3));
     d.setBankName(trunc(bankName, 20));
     d.setAccountName(trunc(accountName, 20));
     d.setWithdrawalBankCode(trunc(withdrawalBankCode, 3));
     d.setWithdrawalAccountNo(trunc(withdrawalAccountNo, 16));
     d.setSubscriptionPeriod(trunc(subscriptionPeriod, 20));
     d.setDepositBalance(depositBalance != null ? depositBalance : 0L);
     d.setInterestRate(interestRate != null ? interestRate : 0.0);
     d.setAccountCreateDate(trunc(accountCreateDate, 8)); // yyyyMMdd
     d.setAccountExpiryDate(trunc(accountExpiryDate, 8)); // yyyyMMdd
     d.setGoalScore1(trunc(goalScore1, 3));
     d.setGoalScore2(trunc(goalScore2, 3));
     return d;
 }

 private String trunc(String s, int max) {
     if (s == null) return null;
     return s.length() > max ? s.substring(0, max) : s;
 }
}
