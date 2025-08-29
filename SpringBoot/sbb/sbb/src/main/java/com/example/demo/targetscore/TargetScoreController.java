package com.example.demo.targetscore;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.demo.user.TargetScore;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/target-score")
public class TargetScoreController {

    private final TargetScoreService svc;

    @GetMapping
    public ResponseEntity<?> get(@RequestParam("userKey") String userKey) { // ← 이름 명시!
        TargetScore ts = svc.get(userKey);
        if (ts == null) {
            // 404를 유지하면 프론트는 로컬 캐시로 폴백(지금 로직과 합치됨)
            return ResponseEntity.status(404).body(Map.of("message", "not found"));
            // 항상 200을 원하면 아래처럼 바꾸세요:
            // return ResponseEntity.ok(Map.of("userKey", userKey, "goalSem1", null, "goalSem2", null));
        }
        return ResponseEntity.ok(Map.of(
                "userKey", ts.getUserKey(),
                "goalSem1", ts.getGoalSem1(),
                "goalSem2", ts.getGoalSem2(),
                "updatedAt", ts.getUpdatedAt()
        ));
    }

    /** upsert: 존재하면 수정, 없으면 생성 (userKey만 기준) */
    @PostMapping
    public ResponseEntity<?> upsert(@RequestBody UpsertReq req) {
        if (req.getUserKey() == null || req.getUserKey().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "userKey required"));
        }
        if (req.getGoalSem1() == null && req.getGoalSem2() == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "at least one of goalSem1, goalSem2 required"));
        }

        TargetScore saved = svc.upsertByUserKey(req.getUserKey(), req.getGoalSem1(), req.getGoalSem2());
        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", Map.of(
                        "userKey",  saved.getUserKey(),
                        "goalSem1", saved.getGoalSem1(),
                        "goalSem2", saved.getGoalSem2(),
                        "updatedAt", saved.getUpdatedAt()
                )
        ));
    }

    @Data
    public static class UpsertReq {
        private String userKey;
        private BigDecimal goalSem1;
        private BigDecimal goalSem2;
    }
}
