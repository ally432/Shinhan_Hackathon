package com.example.demo.openAccount;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Service;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@Slf4j
public class ToDepositOA {

    private final RestTemplate restTemplate;
    private final ObjectMapper om = new ObjectMapper();

    public ToDepositOA() { this.restTemplate = buildRestTemplate(); }

    private RestTemplate buildRestTemplate() {
        RestTemplate rt = new RestTemplate();
        rt.setErrorHandler(new DefaultResponseErrorHandler() {
            @Override public boolean hasError(ClientHttpResponse response) throws IOException { return false; }
        });
        rt.getInterceptors().add((req, body, ex) -> {
            System.out.println("[REQ] " + req.getMethod() + " " + req.getURI());
            req.getHeaders().forEach((k, v) -> System.out.println("  " + k + ": " + v));
            if (body != null) System.out.println("  body=" + new String(body));
            ClientHttpResponse res = ex.execute(req, body);
            System.out.println("[RES] status=" + res.getStatusCode());
            return res;
        });
        return rt;
    }

    // ===== instTxnNo 생성(초 중복 방지, suffix 고정) =====
    private static final String SUFFIX = "123473";
    private static String lastTimeStr = "";
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HHmmss");

    private static synchronized Ids nextIds() {
        String date, time;
        while (true) {
            LocalDateTime now = LocalDateTime.now();
            date = now.format(DATE_FMT);
            time = now.format(TIME_FMT);
            if (!time.equals(lastTimeStr)) { lastTimeStr = time; break; }
            try { Thread.sleep(5); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
        }
        return new Ids(date, time, date + time + SUFFIX);
    }

    private record Ids(String date, String time, String instNo) {}

    // 기존 그대로 유지
    public String deposit(String userKey, String accountNo, long amount) {
        return depositWithSummary(userKey, accountNo, amount, "(수시입출금) : 입금");
    }

    // ✅ 새로 추가: summary(메모) 지정 버전
    public String depositWithSummary(String userKey, String accountNo, long amount, String summary) {
        String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/demandDeposit/updateDemandDepositAccountDeposit";

        Ids ids = nextIds();

        Map<String, Object> header = new LinkedHashMap<>();
        header.put("apiName", "updateDemandDepositAccountDeposit");
        header.put("transmissionDate", ids.date());
        header.put("transmissionTime", ids.time());
        header.put("institutionCode", "00100");
        header.put("fintechAppNo", "001");
        header.put("apiServiceCode", "updateDemandDepositAccountDeposit");
        header.put("institutionTransactionUniqueNo", ids.instNo());
        header.put("apiKey", "a2d9331aee534c1794cf1eafd1bc7a17");
        header.put("userKey", userKey);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("Header", header);
        payload.put("accountNo", accountNo);
        payload.put("transactionBalance", String.valueOf(amount));
        // ✅ 여기서 summary 반영 (비어있으면 기본값)
        String finalSummary = (summary == null || summary.isBlank()) ? "(수시입출금) : 입금" : summary;
        payload.put("transactionSummary", finalSummary);

        try {
            log.info("[Outbound -> OpenAPI][DEPOSIT] payload=\n{}",
                    om.writerWithDefaultPrettyPrinter().writeValueAsString(payload));
        } catch (Exception ignore) { }

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_JSON);
        httpHeaders.setAccept(List.of(MediaType.APPLICATION_JSON));

        ResponseEntity<String> response = restTemplate.exchange(
                url, HttpMethod.POST, new HttpEntity<>(payload, httpHeaders), String.class);

        log.info("[Inbound <- OpenAPI][DEPOSIT] status={}, body={}", response.getStatusCodeValue(), response.getBody());
        return response.getBody();
    }

}
