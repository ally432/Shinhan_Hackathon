package com.example.demo.openAccount;

import com.example.demo.findAccount.RestTemplateFind;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Comparator;
import java.util.concurrent.ThreadLocalRandom;

@RestController
@RequiredArgsConstructor
@RequestMapping("/deposit")
@Slf4j
public class OpenController {

    private final RestTemplateOpen openService;
    private final ToDepositOA depositService;
    private final RestTemplateFind findService; // ← 계좌목록 조회용
    private final ObjectMapper om = new ObjectMapper();

    @PostMapping("/open")
    public ResponseEntity<String> createDepositProduct(@RequestBody CreateDepositReq req,
                                                       HttpServletRequest http) throws Exception {
        String userKey = req.getUserKey();
        if (userKey == null || userKey.isBlank()) {
            return ResponseEntity.badRequest().body("{\"error\":\"USER_KEY_REQUIRED\"}");
        }

        log.info("[/deposit/open] userKey={}, ip={}, ua={}",
                mask(userKey), http.getRemoteAddr(), http.getHeader("User-Agent"));

        // 1) 계좌 개설
        String openRes = openService.createDepositProduct(userKey);
        JsonNode openJson = om.readTree(openRes);
        String code = openJson.path("Header").path("responseCode").asText("");

        // 기본 응답 객체
        var out = om.createObjectNode();
        out.set("open", openJson);

        if (!"H0000".equals(code)) {
            // 개설 실패면 바로 리턴
            return ResponseEntity.ok(om.writerWithDefaultPrettyPrinter().writeValueAsString(out));
        }

        // 2) accountNo 확보
        String accountNo = openJson.path("accountNo").asText(""); // 혹시 바로 내려줄 때
        if (accountNo == null || accountNo.isBlank()) {
            // 없으면 목록 조회해서 가장 최근(생성일 최신) 계좌 사용
            String listRes = findService.findDepositProduct(userKey);
            JsonNode listJson = om.readTree(listRes);
            JsonNode rec = listJson.path("REC");
            if (rec.isArray() && rec.size() > 0) {
                // accountCreatedDate 기준 내림차순(최신 우선)
                JsonNode newest = null;
                for (JsonNode r : rec) {
                    if (newest == null) newest = r;
                    else {
                        String a = r.path("accountCreatedDate").asText("");
                        String b = newest.path("accountCreatedDate").asText("");
                        if (a.compareTo(b) > 0) newest = r; // 문자열 비교(yyyyMMdd 형식)
                    }
                }
                accountNo = newest.path("accountNo").asText("");
                out.set("accountList", listJson); // 참고용으로 함께 반환(선택)
            }
        }

        if (accountNo == null || accountNo.isBlank()) {
            // 안전장치: 계좌번호를 못 찾으면 여기까지
            out.put("autoDepositSkipped", true);
            out.put("reason", "accountNo not found");
            return ResponseEntity.ok(om.writerWithDefaultPrettyPrinter().writeValueAsString(out));
        }

        // 3) 랜덤 금액 결정 (500,000 ~ 100,000,000) - 상한 포함
        long amount = ThreadLocalRandom.current().nextLong(500_000L, 100_000_001L);

        // 4) 자동 입금
        String depRes = depositService.deposit(userKey, accountNo, amount);
        JsonNode depJson = om.readTree(depRes);
        out.put("autoDepositAmount", amount);
        out.put("autoDepositAccountNo", accountNo);
        out.set("deposit", depJson);

        // 5) 반환
        String pretty = om.writerWithDefaultPrettyPrinter().writeValueAsString(out);
        log.info("[/deposit/open] done. accountNo={}, amount={}, result.depositCode={}",
                accountNo, amount, depJson.path("Header").path("responseCode").asText(""));
        return ResponseEntity.ok(pretty);
    }

    private String mask(String v) {
        if (v == null || v.length() < 8) return String.valueOf(v);
        return v.substring(0, 4) + "****" + v.substring(v.length() - 4);
    }

    @Data
    public static class CreateDepositReq { private String userKey; }
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