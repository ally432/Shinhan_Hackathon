package com.example.demo.details.account;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DetailAccountController {

    private final RestTemplateDetails restTemplateDeposit;

    @GetMapping(value = "/deposit/detailsAccount", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> findByGet(
            @RequestParam(value = "userKey", required = false) String userKey,
            @RequestParam(value = "accountNo", required = false) String accountNo
    ) {
        // 테스트용
        if (userKey == null || userKey.isBlank() || accountNo == null || accountNo.isBlank()) {
        	userKey = "e8a7d57a-8bb7-41d2-ab3d-f03f0cb20ff8";
        	accountNo = "0888692626841303";
        }

        // 정상 처리
        String apiResult = restTemplateDeposit.findDepositProduct(userKey, accountNo);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(apiResult);
    }

    // 기존 POST도 유지: 바디 찍고, 서비스 호출
    @PostMapping(
        value = "/deposit/detailsAccount",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<String> find(@RequestBody FindReq req) {
        log.info("[POST /deposit/detailsAccount] req={}", req);

        if (req.userKey == null || req.userKey.isBlank()
                || req.accountNo == null || req.accountNo.isBlank()) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"error\":\"USER_KEY_AND_ACCOUNT_NO_REQUIRED\"}");
        }

        String apiResult = restTemplateDeposit.findDepositProduct(req.userKey, req.accountNo);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(apiResult);
    }

    @Data
    public static class FindReq {
        private String userKey;
        private String accountNo;
    }
}
