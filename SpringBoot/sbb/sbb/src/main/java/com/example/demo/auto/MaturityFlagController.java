package com.example.demo.auto;

import com.example.demo.user.DepositContractMin;
import com.example.demo.user.DepositContractMinRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Map;

@RestController
@RequestMapping("/deposit")
@RequiredArgsConstructor
public class MaturityFlagController {

 private final DepositContractMinRepository repo;

 // 예: GET /deposit/maturity-flag?email=skyblue927@gmail.com
 @GetMapping("/maturity-flag")
 public ResponseEntity<Map<String, Object>> getMaturityFlag(@RequestParam String email) {
     var today = LocalDate.now(ZoneId.of("Asia/Seoul"));
     var opt = repo.findByEmailAndMaturityDate(email, today);

     int maturity = opt.map(DepositContractMin::getMaturity).orElse(0); // 없으면 0(만기 아님)
     long principal = opt.map(DepositContractMin::getPrincipalKrw).orElse(0L);

     return ResponseEntity.ok(Map.of(
         "email", email,
         "date", today.toString(),
         "maturity", maturity,      // 0/1/2
         "principalKrw", principal  // 참고용
     ));
 }
}
