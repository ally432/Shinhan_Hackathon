package com.example.demo.openDeposit;

import jakarta.servlet.http.HttpServletRequest;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/deposit")
@CrossOrigin(origins = "*")
@Slf4j
public class OpenDepositController {

 private final RestTemplateOpenDeposite openService;

 @PostMapping(
     value = "/openDeposit",
     consumes = MediaType.APPLICATION_JSON_VALUE,
     produces = MediaType.APPLICATION_JSON_VALUE
 )
 public ResponseEntity<String> createDepositProduct(
         @RequestBody OpenDepositReq req,
         HttpServletRequest http) {

     if (isBlank(req.getUserKey()) ||
         isBlank(req.getWithdrawalAccountNo()) ||
         isBlank(req.getDepositBalance())) {
         return ResponseEntity.badRequest()
                 .contentType(MediaType.APPLICATION_JSON)
                 .body("{\"code\":\"INVALID_REQUEST\"}");
     }

     log.info("[/deposit/openDeposit] userKey={}, wAcc={}, amount={}, ua={}",
             mask(req.getUserKey()), maskAcc(req.getWithdrawalAccountNo()),
             req.getDepositBalance(), http.getHeader("User-Agent"));

     String apiResult = openService.createDepositProduct(
             req.getUserKey(),
             req.getWithdrawalAccountNo(),
             req.getDepositBalance()
     );

     return ResponseEntity.ok()
             .contentType(MediaType.APPLICATION_JSON)
             .body(apiResult); // ← JSON 원문 그대로
 }

 private boolean isBlank(String s){ return s == null || s.isBlank(); }

 private String mask(String v) {
     if (v == null || v.length() < 8) return String.valueOf(v);
     return v.substring(0, 4) + "****" + v.substring(v.length() - 4);
 }
 private String maskAcc(String v) {
     if (v == null || v.length() < 4) return String.valueOf(v);
     return "****" + v.substring(v.length() - 4);
 }

 @Data
 public static class OpenDepositReq {
     private String userKey;
     private String withdrawalAccountNo;
     private String depositBalance;      // API 규격이 문자열이면 String 유지
 }
}
