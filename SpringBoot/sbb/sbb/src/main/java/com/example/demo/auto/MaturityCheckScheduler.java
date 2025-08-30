// src/main/java/com/example/demo/auto/MaturityCheckScheduler.java
package com.example.demo.auto;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.example.demo.user.*;
import com.example.demo.openAccount.ToDepositOA;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MaturityCheckScheduler {

    private final DepositContractMinRepository repo;
    private final GradeRecordRepository gradeRepo;
    private final TargetScoreRepository targetRepo;
    private final com.example.demo.signup.UserInfoRepository userInfoRepo;

    // ⬇️ 추가
    private final ApiAccountResolver accountResolver;
    private final ToDepositOA toDepositOA;

    // 매일 오전 10:24 (원하면 정각은 "0 0 10 * * *")
    @Scheduled(cron = "0 40 10 * * *", zone = "Asia/Seoul")
    public void checkTodayMaturity() {
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Seoul"));

        var list = repo.findByMaturityDate(today);
        if (list.isEmpty()) {
            log.info("[MATURITY CHECK] {} 만기 계좌 없음.", today);
            return;
        }

        String emails = list.stream().map(DepositContractMin::getEmail).collect(Collectors.joining(", "));
        log.info("[MATURITY CHECK] {} 만기 계좌 {}건 발견. emails=[{}]", today, list.size(), emails);

        for (var c : list) {
            String email = c.getEmail();

            // 1) email -> userKey (UserInfo)
            UserInfo ui = userInfoRepo.findById(email).orElse(null);
            if (ui == null || ui.getUserKey() == null || ui.getUserKey().isBlank()) {
                log.info("[MATURITY BONUS] email={} → UserInfo/userKey 없음 → 추가이자율 0% (지급 스킵)", email);
                continue;
            }
            String userKey = ui.getUserKey();

            // 2) 목표성적
            TargetScore ts = targetRepo.findByUserKey(userKey).orElse(null);
            if (ts == null) {
                log.info("[MATURITY BONUS] email={} userKey={} 목표성적 없음 → 추가이자율 0% (지급 스킵)", email, mask(userKey));
                continue;
            }

            // 3) 최근 두 학기 성적
            var recent = fetchRecentTwoByPair(email, today);
            if (recent.isEmpty()) {
                log.info("[MATURITY BONUS] email={} 성적데이터 없음 → 추가이자율 0% (지급 스킵)", email);
                continue;
            }

            // 4) 보너스율(%)
            BigDecimal bonusRatePct = chooseBonusRate(ts, recent); // 0.00 / 0.10 / 0.15
            if (bonusRatePct.compareTo(BigDecimal.ZERO) <= 0) {
            	c.setMaturity(2);
                log.info("[MATURITY BONUS] email={} bonusRate=0% → 지급 스킵", email);
                continue;
            }

            // 5) 지급액 = round( principal * (rate%/100) * days / 365 )
            long days = java.time.temporal.ChronoUnit.DAYS.between(c.getOpenedDate(), c.getMaturityDate());
            if (days <= 0) {
                log.info("[MATURITY BONUS] email={} days<=0 → 지급 스킵", email);
                continue;
            }
            BigDecimal principal = BigDecimal.valueOf(c.getPrincipalKrw());
            BigDecimal rateFraction = bonusRatePct.movePointLeft(2); // % → 소수
            BigDecimal amountBD = principal.multiply(rateFraction)
                    .multiply(BigDecimal.valueOf(days))
                    .divide(BigDecimal.valueOf(365), 0, RoundingMode.HALF_UP);
            long amount = amountBD.longValue();
            if (amount <= 0) {
                log.info("[MATURITY BONUS] email={} amount=0 → 지급 스킵", email);
                continue;
            }

            // 6) 계좌번호를 OpenAPI로 조회 (이 코드!)
            String accountNo;
            try {
                accountNo = accountResolver.findAccountNoOrThrow(userKey);
            } catch (Exception e) {
                log.warn("[BONUS PAY] email={} userKey={} 계좌조회 실패: {} → 지급 스킵",
                        email, mask(userKey), e.getMessage());
                continue;
            }

            // 7) 입금 호출
            String memo = "만기 추가이자(" + today + ", " + bonusRatePct + "%)";
            try {
                String res = toDepositOA.depositWithSummary(userKey, accountNo, amount, memo);
                c.setMaturity(1);
                log.info("[BONUS PAY][OK] email={} userKey={} accNo={} principal={}원 days={} rate={}%(={}) 지급액={}원 memo='{}' resp={}",
                        email, mask(userKey), maskAcc(accountNo), c.getPrincipalKrw(), days,
                        bonusRatePct, rateFraction, amount, memo, cut(res, 300));
            } catch (Exception e) {
                log.error("[BONUS PAY][FAIL] email={} userKey={} accNo={} 지급액={}원 이유={}",
                        email, mask(userKey), maskAcc(accountNo), amount, e.toString());
            }
        }
    }

    // ===== 아래 보조 메서드는 기존 그대로 =====
    private java.util.List<GradeRecord> fetchRecentTwoByPair(String email, LocalDate baseDate) {
        int y = baseDate.getYear();
        int s = (baseDate.getMonthValue() >= 7) ? 2 : 1;

        var out = new ArrayList<GradeRecord>(2);
        gradeRepo.findByUserIdAndYearAndSemester(email, y, s).ifPresent(out::add);

        int prevY = (s == 1) ? (y - 1) : y;
        int prevS = (s == 1) ? 2 : 1;
        gradeRepo.findByUserIdAndYearAndSemester(email, prevY, prevS).ifPresent(out::add);
        return out;
    }

    private BigDecimal chooseBonusRate(TargetScore ts, java.util.List<GradeRecord> recent) {
        if (recent.isEmpty()) return BigDecimal.ZERO;
        double goal1 = ts.getGoalSem1() != null ? ts.getGoalSem1().doubleValue() : 0.0;
        double goal2 = ts.getGoalSem2() != null ? ts.getGoalSem2().doubleValue() : 0.0;
        int met = 0;
        if (recent.size() >= 1 && recent.get(0).getTotalGpa() != null) {
            if (recent.get(0).getTotalGpa() >= goal2) met++;
        }
        if (recent.size() >= 2 && recent.get(1).getTotalGpa() != null) {
            if (recent.get(1).getTotalGpa() >= goal1) met++;
        }
        if (met >= 2) return new BigDecimal("0.15");
        if (met == 1) return new BigDecimal("0.10");
        return BigDecimal.ZERO;
    }

    private String mask(String v) {
        if (v == null || v.length() < 8) return "****";
        return v.substring(0, 4) + "****" + v.substring(v.length() - 4);
    }
    private String maskAcc(String v) {
        if (v == null || v.length() < 6) return "****";
        return "****" + v.substring(v.length() - 4);
    }
    private String cut(String s, int n) {
        if (s == null) return null;
        return s.length() <= n ? s : s.substring(0, n) + "...";
    }
}