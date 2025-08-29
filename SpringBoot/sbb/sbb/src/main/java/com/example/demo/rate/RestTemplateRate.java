package com.example.demo.rate;

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
public class RestTemplateRate {

    private final RestTemplate restTemplate;
    // @Value("${app.finapi.api-key}") private String apiKey;
    // @Value("${app.finapi.institution-code:00100}") private String institutionCode;
    private static final String API_KEY = "a2d9331aee534c1794cf1eafd1bc7a17"; // TODO: 외부화
    private static final String INSTITUTION_CODE = "00100";

    private static String lastTimeStr = "";

    private static final String FIXED_SUFFIX = "123459";
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HHmmss");
    private static final DateTimeFormatter MS_FMT   = DateTimeFormatter.ofPattern("SSS");

    public RestTemplateRate() {
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

    private static synchronized InstIds nextInstIds() {
        String date, time;

        while (true) {
            LocalDateTime now = LocalDateTime.now();
            date = now.format(DATE_FMT);
            time = now.format(TIME_FMT);

            if (!time.equals(lastTimeStr)) {
                // 이 초는 아직 안 썼다 → 사용
                lastTimeStr = time;
                String instTxnNo = date + time + FIXED_SUFFIX; // 14 + 6 = 20자리
                return new InstIds(date, time, instTxnNo);
            }

            // 같은 초를 이미 썼다 → 잠깐 대기 후 재시도 (5ms)
            try { Thread.sleep(5); } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                throw new RuntimeException(ie);
            }
        }
    }

    private record InstIds(String date, String time, String instTxnNo) {}

    /** 예금해지 조회 */
    public String findDepositProduct(String userKey, String accountNo) {
        final String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/deposit/inquireDepositExpiryInterest";
        InstIds ids = nextInstIds();

        Map<String, Object> Header = new LinkedHashMap<>();
        Header.put("apiName", "inquireDepositExpiryInterest");
        Header.put("transmissionDate", ids.date());
        Header.put("transmissionTime", ids.time());
        Header.put("institutionCode", INSTITUTION_CODE);
        Header.put("fintechAppNo", "001");
        Header.put("apiServiceCode", "inquireDepositExpiryInterest");
        Header.put("institutionTransactionUniqueNo", ids.instTxnNo());
        Header.put("apiKey", API_KEY);
        Header.put("userKey", userKey);

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("Header", Header);
        body.put("accountNo", accountNo);

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_JSON);
        httpHeaders.setAccept(List.of(MediaType.APPLICATION_JSON));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, httpHeaders);
        ResponseEntity<String> response =
                restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

        System.out.println("HTTP " + response.getStatusCodeValue());
        System.out.println(response.getBody());
        return response.getBody();
    }
}
