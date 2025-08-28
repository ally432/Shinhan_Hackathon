package com.example.demo.targetscore;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.demo.user.TargetScore;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/target-score")
public class TargetScoreController {

 private final TargetScoreService svc;

 @GetMapping
 public ResponseEntity<?> get(@RequestParam String userKey) {
     TargetScore ts = svc.get(userKey);
     if (ts == null) {
         return ResponseEntity.status(404).body(Map.of("message", "not found"));
     }
     return ResponseEntity.ok(Map.of(
             "userKey", ts.getUserKey(),
             "goalSem1", ts.getGoalSem1(),
             "goalSem2", ts.getGoalSem2(),
             "updatedAt", ts.getUpdatedAt()
     ));
 }

 /** upsert: 존재하면 수정, 없으면 생성 */
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
                     "userKey", saved.getUserKey(),
                     "goalSem1", saved.getGoalSem1(),
                     "goalSem2", saved.getGoalSem2()
             )
     ));
 }

 @Data
 public static class UpsertReq {
     private String userKey;
     private BigDecimal goalSem1; // JSON 숫자/문자열 모두 BigDecimal로 매핑 가능
     private BigDecimal goalSem2;
 }
}
