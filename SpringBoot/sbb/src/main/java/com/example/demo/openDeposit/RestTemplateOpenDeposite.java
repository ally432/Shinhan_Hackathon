package com.example.demo.openDeposit;

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
public class RestTemplateOpenDeposite {

 private final RestTemplate restTemplate;
 private final ObjectMapper om = new ObjectMapper();

 // 중복 방지용
 private static String lastTimeSec = "";
 private static final String FIXED_SUFFIX = "123492"; // 요구사항 유지
 private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");
 private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HHmmss");

 public RestTemplateOpenDeposite() {
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

 // 같은 초 중복 방지: 초가 바뀔 때까지 5ms sleep
 private static synchronized String[] nextIds() {
     while (true) {
         LocalDateTime now = LocalDateTime.now();
         String date = now.format(DATE_FMT);
         String time = now.format(TIME_FMT);
         if (!time.equals(lastTimeSec)) {
             lastTimeSec = time;
             String instTxnNo = date + time + FIXED_SUFFIX; // 20자리
             return new String[]{date, time, instTxnNo};
         }
         try { Thread.sleep(5); } catch (InterruptedException e) {
             Thread.currentThread().interrupt();
             throw new RuntimeException(e);
         }
     }
 }

 public String createDepositProduct(
         String userKey,
         String withdrawalAccountNo,
         String depositBalance
 ) {
     String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/deposit/createDepositAccount";

     String[] ids = nextIds();
     String nowDate = ids[0];
     String nowTime = ids[1];
     String instTxnNo = ids[2];

     Map<String, Object> Header = new LinkedHashMap<>();
     Header.put("apiName", "createDepositAccount");
     Header.put("transmissionDate", nowDate);
     Header.put("transmissionTime", nowTime);
     Header.put("institutionCode", "00100");
     Header.put("fintechAppNo", "001");
     Header.put("apiServiceCode", "createDepositAccount");
     Header.put("institutionTransactionUniqueNo", instTxnNo);
     Header.put("apiKey", "a2d9331aee534c1794cf1eafd1bc7a17");
     Header.put("userKey", userKey);

     Map<String, Object> payload = new LinkedHashMap<>();
     payload.put("Header", Header);
     payload.put("withdrawalAccountNo", withdrawalAccountNo);
     payload.put("accountTypeUniqueNo", "088-2-bfa47ec4b77748");//088-2-bfa47ec4b77748
     payload.put("depositBalance", depositBalance);

     try {
         log.info("[Outbound -> OpenAPI] payload=\n{}",
                 om.writerWithDefaultPrettyPrinter().writeValueAsString(payload));
     } catch (Exception ignore) {}

     HttpHeaders httpHeaders = new HttpHeaders();
     httpHeaders.setContentType(MediaType.APPLICATION_JSON);
     httpHeaders.setAccept(List.of(MediaType.APPLICATION_JSON));

     HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, httpHeaders);
     ResponseEntity<String> response =
             restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

     log.info("[Inbound <- OpenAPI] status={}, body={}", response.getStatusCodeValue(), response.getBody());
     return response.getBody();
 }
}
