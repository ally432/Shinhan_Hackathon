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
    private static final String SUFFIX = "123473"; // ← 너희 규칙에 맞춰 고정
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

    /** ✅ 입금 호출 */
    public String deposit(String userKey, String accountNo, long amount) {
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
        // 사양이 숫자/문자열 중 무엇을 기대하는지에 따라 조정. 기존 예시에 맞춰 문자열로 전송.
        payload.put("transactionBalance", String.valueOf(amount));
        payload.put("transactionSummary", "(수시입출금) : 입금");

        try { log.info("[Outbound -> OpenAPI][DEPOSIT] payload=\n{}",
                om.writerWithDefaultPrettyPrinter().writeValueAsString(payload)); } catch (Exception ignore) {}

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_JSON);
        httpHeaders.setAccept(List.of(MediaType.APPLICATION_JSON));

        ResponseEntity<String> response = restTemplate.exchange(
                url, HttpMethod.POST, new HttpEntity<>(payload, httpHeaders), String.class);

        log.info("[Inbound <- OpenAPI][DEPOSIT] status={}, body={}", response.getStatusCodeValue(), response.getBody());
        return response.getBody();
    }
}
