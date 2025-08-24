package com.example.demo.openAccount;

import jakarta.servlet.http.HttpServletRequest;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/deposit")
@Slf4j
public class OpenController {

    private final RestTemplateOpen openService;

    @PostMapping("/open")
    public ResponseEntity<String> createDepositProduct(@RequestBody CreateDepositReq req,
                                                       HttpServletRequest http) {
        // 임시 콘솔/로그 출력
        log.info("[/deposit/open] userKey={}, remoteIp={}, ua={}",
                mask(req.getUserKey()), http.getRemoteAddr(), http.getHeader("User-Agent"));

        String apiResult = openService.createDepositProduct(req.getUserKey());

        // 결과 본문도 찍기
        log.info("[/deposit/open] result preview: {}", apiResult);
        return ResponseEntity.ok(apiResult);
    }

    private String mask(String v) {
        if (v == null || v.length() < 8) return String.valueOf(v);
        return v.substring(0, 4) + "****" + v.substring(v.length() - 4);
    }

    @Data
    public static class CreateDepositReq {
        private String userKey;
    }
}

/*
package com.example.demo.openAccount;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/deposit")
public class OpenController {

    private final RestTemplateOpen openService;

    @PostMapping("/open")
    public ResponseEntity<String> createDepositProduct(@RequestBody CreateDepositReq req) {
        if (req.getUserKey() == null || req.getUserKey().isBlank()) {
            return ResponseEntity.badRequest().body("USER_KEY_REQUIRED");
        }
        String apiResult = openService.createDepositProduct(req.getUserKey());
        return ResponseEntity.ok(apiResult);
    }

    @Data
    public static class CreateDepositReq {
        private String userKey;
    }
}

*/