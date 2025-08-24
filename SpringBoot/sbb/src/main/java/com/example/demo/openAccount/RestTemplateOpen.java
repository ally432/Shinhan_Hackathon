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
public class RestTemplateOpen {

    private final RestTemplate restTemplate;
    private final ObjectMapper om = new ObjectMapper();

    public RestTemplateOpen() {
        this.restTemplate = buildRestTemplate();
    }

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

    public String createDepositProduct(String userKey) {
        String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/demandDeposit/createDemandDepositAccount";

        String nowDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String nowTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("HHmmss"));
        String instTxnNo = nowDate + nowTime + "123457";

        Map<String, Object> Header = new LinkedHashMap<>();
        Header.put("apiName", "createDemandDepositAccount");
        Header.put("transmissionDate", nowDate);
        Header.put("transmissionTime", nowTime);
        Header.put("institutionCode", "00100");
        Header.put("fintechAppNo", "001");
        Header.put("apiServiceCode", "createDemandDepositAccount");
        Header.put("institutionTransactionUniqueNo", instTxnNo);
        Header.put("apiKey", "a2d9331aee534c1794cf1eafd1bc7a17");
        Header.put("userKey", userKey);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("Header", Header);
        payload.put("accountTypeUniqueNo", "088-1-b12a2d6449184e");

        // 외부로 나가기 전에 찍기
        try {
            log.info("[Outbound -> OpenAPI] payload=\n{}",
                    om.writerWithDefaultPrettyPrinter().writeValueAsString(payload));
        } catch (Exception ignore) {}

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_JSON);
        httpHeaders.setAccept(List.of(MediaType.APPLICATION_JSON));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, httpHeaders);
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

        // 응답 바디도 찍기
        log.info("[Inbound <- OpenAPI] status={}, body={}", response.getStatusCodeValue(), response.getBody());

        return response.getBody();
    }
}
