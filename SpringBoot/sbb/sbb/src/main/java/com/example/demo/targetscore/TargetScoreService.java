package com.example.demo.targetscore;

import com.example.demo.user.TargetScore;
import com.example.demo.user.TargetScoreRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class TargetScoreService {

    private final TargetScoreRepository repo;

    public TargetScore get(String userKey) {
        return repo.findByUserKey(userKey).orElse(null);
    }

    @Transactional
    public TargetScore upsertByUserKey(String userKey, BigDecimal s1, BigDecimal s2) {
        TargetScore ts = repo.findByUserKey(userKey).orElseGet(() -> {
            TargetScore n = new TargetScore();
            n.setUserKey(userKey);
            // createdAt을 엔티티 @PrePersist로 처리하면 생략 가능
            n.setCreatedAt(LocalDateTime.now());
            return n;
        });
        if (s1 != null) ts.setGoalSem1(s1);
        if (s2 != null) ts.setGoalSem2(s2);
        ts.setUpdatedAt(LocalDateTime.now()); // 단순 갱신
        return repo.save(ts);
    }
}
