package com.example.demo.findOneAccount;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FindOneAccountController {

 private final RestTemplateFindOne restTemplateDeposit;

 @PostMapping(
     value = "/deposit/findOneOpenDeposit",
     consumes = MediaType.APPLICATION_JSON_VALUE,
     produces = MediaType.APPLICATION_JSON_VALUE
 )
 public ResponseEntity<String> find(@RequestBody FindReq req) {
     if (req.userKey == null || req.userKey.isBlank()
             || req.accountNo == null || req.accountNo.isBlank()) {
         return ResponseEntity.badRequest().body("{\"error\":\"USER_KEY_AND_ACCOUNT_NO_REQUIRED\"}");
     }
     String apiResult = restTemplateDeposit.findDepositProduct(req.userKey, req.accountNo);
     return ResponseEntity.ok(apiResult);
 }

 @Data
 public static class FindReq {
     private String userKey;
     private String accountNo;
 }
}
