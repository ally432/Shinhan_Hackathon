package com.example.demo.openAccount;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/demand")
@RequiredArgsConstructor
@Slf4j
public class DemandDepositController {

    private final ToDepositOA toDepositOA;              // ✅ 너가 만든 OpenAPI 호출 서비스
    private final ObjectMapper om = new ObjectMapper();

    @PostMapping("/deposit")
    public ResponseEntity<?> depositToDemand(@RequestBody DepositReq req,
                                             HttpServletRequest http) {
        try {
            // 1) 검증
            if (req.getUserKey() == null || req.getUserKey().isBlank()) {
                return ResponseEntity.badRequest().body(
                        "{\"error\":\"USER_KEY_REQUIRED\"}");
            }
            if (req.getAccountNo() == null || req.getAccountNo().isBlank()) {
                return ResponseEntity.badRequest().body(
                        "{\"error\":\"ACCOUNT_NO_REQUIRED\"}");
            }
            if (req.getAmount() == null || req.getAmount() <= 0) {
                return ResponseEntity.badRequest().body(
                        "{\"error\":\"AMOUNT_INVALID\"}");
            }

            // 2) 계좌번호 정규화(숫자만)
            String cleanAccNo = req.getAccountNo().replaceAll("\\D", "");

            log.info("[/demand/deposit] userKey={}, ip={}, ua={}, amount={}, accNo={}",
                    mask(req.getUserKey()), http.getRemoteAddr(),
                    http.getHeader("User-Agent"), req.getAmount(), cleanAccNo);

            // 3) OpenAPI 호출
            String apiBody = toDepositOA.deposit(req.getUserKey(), cleanAccNo, req.getAmount());

            // 4) 응답 파싱(성공/실패 코드 확인)
            JsonNode root = om.readTree(apiBody);
            String code = root.path("Header").path("responseCode").asText("");
            boolean success = "H0000".equals(code);

            // 프런트에서 그대로 쓰기 좋게 래핑
            var out = om.createObjectNode();
            out.put("success", success);
            out.put("userKey", req.getUserKey());
            out.put("accountNo", cleanAccNo);
            out.put("amount", req.getAmount());
            out.put("memo", req.getMemo());
            out.set("raw", root); // 원본 응답도 같이 넘겨줌

            return ResponseEntity.ok(om.writerWithDefaultPrettyPrinter().writeValueAsString(out));
        } catch (Exception e) {
            log.error("depositToDemand error", e);
            return ResponseEntity.internalServerError().body(
                    "{\"error\":\"INTERNAL_ERROR\",\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    private String mask(String v) {
        if (v == null || v.length() < 8) return String.valueOf(v);
        return v.substring(0, 4) + "****" + v.substring(v.length() - 4);
    }

    @Data
    public static class DepositReq {
        private String userKey;
        private String accountNo; // 수시입출금 계좌
        private Long amount;      // 입금 금액(추가 이자)
        private String memo;      // 선택
        // bankName 등 추가 필드가 필요하면 여기에 확장해도 됨(서버에서는 안 씀)
    }
}
