package com.example.demo.findDeposit;

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
public class RestTemplateFindSave {

    private final RestTemplate restTemplate;
    
    private static String lastTimeStr = "";
    private static final String FIXED_SUFFIX = "123492";
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HHmmss");

    public RestTemplateFindSave() {
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

    /** 예금(입출금) 계좌 목록 조회 */
    public String findDepositProduct(String userKey) {
        String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/deposit/inquireDepositInfoList";

        // ★ 고유번호/전송일시 동시 생성 (중복 방지 포함)
        InstIds ids = nextInstIds();

        Map<String, Object> Header = new LinkedHashMap<>();
        Header.put("apiName", "inquireDepositInfoList");
        Header.put("transmissionDate", ids.date());
        Header.put("transmissionTime", ids.time());
        Header.put("institutionCode", "00100");
        Header.put("fintechAppNo", "001");
        Header.put("apiServiceCode", "inquireDepositInfoList");
        Header.put("institutionTransactionUniqueNo", ids.instTxnNo());
        Header.put("apiKey", "a2d9331aee534c1794cf1eafd1bc7a17");
        Header.put("userKey", userKey);

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("Header", Header);

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