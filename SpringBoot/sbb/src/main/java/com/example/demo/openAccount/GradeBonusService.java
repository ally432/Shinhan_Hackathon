package com.example.demo.openAccount;

import com.example.demo.user.DepositInfo;
import com.example.demo.user.DepositInfoRepository;
import com.example.demo.user.GradeRecord;
import com.example.demo.user.GradeRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class GradeBonusService {

 private final GradeRecordRepository gradeRepo;
 private final DepositInfoRepository depositRepo;
 private final ToDepositOA depositOA; // 기존 입금 호출기

 /**
  * userKey, 예금계좌(정기/적금) 기준으로 우대이자 합계 계산 후,
  * 출금계좌(수시입출금)로 입금한다.
  * @return 실제 입금된 우대이자 금액(원)
  */
 @Transactional
 public long applyBonusAndDeposit(String userKey, String depositAccountNo) {
     DepositInfo di = depositRepo.findByUserKeyAndAccountNo(userKey, depositAccountNo)
             .orElseThrow(() -> new IllegalArgumentException("DepositInfo not found"));

     // DepositInfo → UserInfo 연관으로 userId 획득 (user_key ↔ user_id 매핑)
     String userId = (di.getUserInfo() != null) ? di.getUserInfo().getUserId() : null;
     if (userId == null || userId.isBlank()) {
         throw new IllegalStateException("userId not found for userKey=" + userKey);
     }

     // 목표 성적 (예: "3.7", "4.0") 파싱
     double goal1 = parseDouble(di.getGoalScore1());
     double goal2 = parseDouble(di.getGoalScore2());

     // 이번 프로젝트 시드 기준: 2024-2, 2025-1 두 학기만 존재
     double gpa20242 = gradeRepo.findByUserIdAndYearAndSemester(userId, 2024, 2)
             .map(GradeRecord::getTotalGpa).orElse(0.0);
     double gpa20251 = gradeRepo.findByUserIdAndYearAndSemester(userId, 2025, 1)
             .map(GradeRecord::getTotalGpa).orElse(0.0);

     long bonus = 0L;

     // 각 학기 GPA가 그 학기의 목표 이상이면, 해당 GPA 구간의 우대금리로 계산
     if (gpa20242 >= goal1) {
         bonus += calcBonus(di, gpa20242);
     }
     if (gpa20251 >= goal2) {
         bonus += calcBonus(di, gpa20251);
     }

     // 우대이자가 있으면 출금계좌(=수시입출금)로 입금
     if (bonus > 0) {
         String demandAcc = di.getWithdrawalAccountNo(); // 수령계좌
         depositOA.deposit(userKey, demandAcc, bonus);
         log.info("[GRADE-BONUS] userKey={}, depositAcc={}, demandAcc={}, bonus={}",
                 mask(userKey), depositAccountNo, demandAcc, bonus);
     } else {
         log.info("[GRADE-BONUS] no bonus. userKey={}, depositAcc={}, gpas=({}, {}) goals=({}, {})",
                 mask(userKey), depositAccountNo, gpa20242, gpa20251, goal1, goal2);
     }

     return bonus;
 }

 /** 연 0.15/0.10/0.05% 구간 적용 + 기간 비례(구독일수/365) + 반올림(원) */
 private long calcBonus(DepositInfo di, double gpa) {
     double tier = tierRate(gpa); // % 단위 (예: 0.15)
     if (tier <= 0.0) return 0L;

     long principal = (di.getDepositBalance() != null) ? di.getDepositBalance() : 0L;
     int days = parseInt(di.getSubscriptionPeriod(), 365);

     double yrFactor = days / 365.0;                // 기간 비례
     double raw = principal * (tier / 100.0) * yrFactor;
     return Math.round(raw);                         // 원단위 반올림
 }

 /** GPA 구간 → 우대금리(%) */
 private double tierRate(double gpa) {
     if (gpa >= 4.3) return 0.15;
     if (gpa >= 4.0) return 0.10;
     if (gpa >= 3.7) return 0.05;
     return 0.0;
 }

 private static double parseDouble(String s) {
     try { return Double.parseDouble(s); } catch (Exception e) { return 0.0; }
 }
 private static int parseInt(String s, int def) {
     try { return Integer.parseInt(s); } catch (Exception e) { return def; }
 }
 private static String mask(String v) {
     if (v == null || v.length() < 8) return String.valueOf(v);
     return v.substring(0, 4) + "****" + v.substring(v.length() - 4);
 }
}
