package com.example.demo.openAccount;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import org.springframework.http.*;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Service;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.RestTemplate;

@Service
public class ToDepositOA {

    private final RestTemplate restTemplate;

    public ToDepositOA() {
        this.restTemplate = buildRestTemplate();
    }

    private RestTemplate buildRestTemplate() {
        RestTemplate rt = new RestTemplate();

        // 에러라도 바디 확인
        rt.setErrorHandler(new DefaultResponseErrorHandler() {
            @Override
            public boolean hasError(ClientHttpResponse response) throws IOException {
                return false;
            }
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

    /**
     * 예금(입출금) 계좌 생성 API 호출 - Header + accountTypeUniqueNo 루트 구조
     */
    public String createDepositProduct() {
        String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/demandDeposit/updateDemandDepositAccountDeposit";

        // 날짜/시간/고유거래번호
        String nowDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String nowTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("HHmmss"));
        String instTxnNo = nowDate + nowTime + "0123560";;
        // ↑ 고유성 보장 위해 뒤에 랜덤 일부 추가(규격 길이가 정해져 있으면 문서 규칙대로 맞추세요)

        // ==== JSON Body 구성 ====
        Map<String, Object> Header = new LinkedHashMap<>(); // 순서 보존(가독 목적)
        Header.put("apiName", "updateDemandDepositAccountDeposit");
        Header.put("transmissionDate", nowDate);
        Header.put("transmissionTime", nowTime);
        Header.put("institutionCode", "00100");
        Header.put("fintechAppNo", "001");
        Header.put("apiServiceCode", "updateDemandDepositAccountDeposit");
        Header.put("institutionTransactionUniqueNo", "20250817195100123498");
        Header.put("apiKey", "a2d9331aee534c1794cf1eafd1bc7a17"); // 문서 규정대로 이 위치에 필요
        Header.put("userKey", "e8a7d57a-8bb7-41d2-ab3d-f03f0cb20ff8");

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("Header", Header);
        body.put("accountNo", "0888692626841303");
        body.put("transactionBalance", "100000000");
        body.put("transactionSummary", "(수시입출금) : 입금");

        // ==== HTTP 헤더 ====
        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_JSON);
        httpHeaders.setAccept(List.of(MediaType.APPLICATION_JSON));

        // ※ 문서가 HTTP 헤더 인증을 요구하지 않으면 추가하지 마세요.
        // 요구한다면 아래 중 하나 사용:
        // httpHeaders.add("X-API-KEY", "a2d9331aee534c1794cf1eafd1bc7a17");
        // httpHeaders.setBearerAuth("<YOUR_TOKEN>");

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, httpHeaders);

        ResponseEntity<String> response = restTemplate.exchange(
                url, HttpMethod.POST, entity, String.class
        );

        System.out.println("HTTP " + response.getStatusCodeValue());
        System.out.println(response.getBody());

        return response.getBody();
    }
}
