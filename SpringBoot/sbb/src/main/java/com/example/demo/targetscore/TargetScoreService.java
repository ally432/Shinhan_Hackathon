package com.example.demo.targetscore;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.user.TargetScore;
import com.example.demo.user.TargetScoreRepository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TargetScoreService {

 private final TargetScoreRepository repo;

 @Transactional
 public TargetScore upsertByUserKey(String userKey, BigDecimal s1, BigDecimal s2) {
     Optional<TargetScore> opt = repo.findByUserKey(userKey);
     if (opt.isPresent()) {
         TargetScore ts = opt.get();
         if (s1 != null) ts.setGoalSem1(scale2(s1));
         if (s2 != null) ts.setGoalSem2(scale2(s2));
         // updatedAt는 @PreUpdate로 자동 갱신
         return repo.save(ts);
     } else {
         TargetScore ts = new TargetScore();
         ts.setUserKey(userKey);
         ts.setGoalSem1(s1 == null ? null : scale2(s1));
         ts.setGoalSem2(s2 == null ? null : scale2(s2));
         // createdAt/updatedAt는 @PrePersist로 자동 세팅
         return repo.save(ts);
     }
 }

 @Transactional(readOnly = true)
 public TargetScore get(String userKey) {
     return repo.findByUserKey(userKey).orElse(null);
 }

 private BigDecimal scale2(BigDecimal v) {
     return v.setScale(2, RoundingMode.HALF_UP); // 예: 4.3 -> 4.30
 }
}
