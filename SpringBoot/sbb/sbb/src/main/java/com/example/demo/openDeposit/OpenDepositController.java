package com.example.demo.openDeposit;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequiredArgsConstructor
@RequestMapping("/deposit")
@CrossOrigin(origins = "*")
@Slf4j
public class OpenDepositController {

    private final RestTemplateOpenDeposite openService;
    private final ObjectMapper om = new ObjectMapper(); // ← pretty 로그용

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

        // 클라이언트 IP, UA
        final String ip = Optional.ofNullable(http.getHeader("X-Forwarded-For"))
                .map(v -> v.split(",")[0].trim())
                .orElseGet(http::getRemoteAddr);
        final String ua = Optional.ofNullable(http.getHeader("User-Agent")).orElse("-");

        // 마스킹된 요청 바디 pretty 로그
        try {
            var maskedReq = om.createObjectNode()
                    .put("userKey", mask(req.getUserKey()))
                    .put("withdrawalAccountNo", maskAcc(req.getWithdrawalAccountNo()))
                    .put("depositBalance", req.getDepositBalance());
            log.info("[/deposit/openDeposit] inbound from ip={}, ua={}\n{}",
                    ip, ua, om.writerWithDefaultPrettyPrinter().writeValueAsString(maskedReq));
        } catch (Exception ignore) {
            log.info("[/deposit/openDeposit] userKey={}, wAcc={}, amount={}, ip={}, ua={}",
                    mask(req.getUserKey()), maskAcc(req.getWithdrawalAccountNo()),
                    req.getDepositBalance(), ip, ua);
        }

        // OpenAPI 호출
        String apiResult = openService.createDepositProduct(
                req.getUserKey(),
                req.getWithdrawalAccountNo(),
                req.getDepositBalance()
        );

        // 응답 요약/원문 로그
        try {
            JsonNode root = om.readTree(apiResult);
            String code = root.path("Header").path("responseCode").asText("");
            String msg  = root.path("Header").path("responseMessage").asText("");
            String acc  = root.path("accountNo").asText(""); // 응답에 있으면 마스킹하여 표시
            log.info("[/deposit/openDeposit] OpenAPI result code={}, msg={}, accountNo={}",
                    code, msg, acc.isEmpty() ? "-" : maskAcc(acc));

            // 상세 원문도 보기 원하면(DEBUG에서만)
            if (log.isDebugEnabled()) {
                log.debug("[/deposit/openDeposit] raw response\n{}",
                        om.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            }
        } catch (Exception e) {
            // JSON이 아니거나 파싱 실패 시 원문 그대로
            log.info("[/deposit/openDeposit] raw response(non-JSON?)={}", apiResult);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(apiResult); // JSON 원문 그대로 반환
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
        private String depositBalance; // API 규격이 문자열이면 String 유지
    }
}