package com.example.demo.createDeposit;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class RestTemplateDeposit {

    private final RestTemplate restTemplate;

    public RestTemplateDeposit() {
        this.restTemplate = new RestTemplate();
    }

    /**
     * 예금 상품 생성 API 호출 (수정된 요청값 적용)
     */
    public String createDepositProduct() {
        String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/deposit/createDepositProduct";

        Map<String, Object> header = new HashMap<>();
        header.put("apiName", "createDepositProduct");
        header.put("transmissionDate", "20250817");
        header.put("transmissionTime", "195100");
        header.put("institutionCode", "00100");
        header.put("fintechAppNo", "001");
        header.put("apiServiceCode", "createDepositProduct");
        header.put("institutionTransactionUniqueNo", "20250817195100123498");
        header.put("apiKey", "");

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("Header", header);
        requestBody.put("bankCode", "088");
        requestBody.put("accountName", "시험보험");
        requestBody.put("accountDescription", "성적 기반 금융 위로 서비스");
        requestBody.put("subscriptionPeriod", "365");
        requestBody.put("minSubscriptionBalance", "500000");
        requestBody.put("maxSubscriptionBalance", "100000000");
        requestBody.put("interestRate", "2.05");
        requestBody.put("rateDescription", "목표달성에 따른 추가 우대 금리 적용(연 최대 2.2%)");

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        ResponseEntity<String> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                entity,
                String.class
        );

        return response.getBody();
    }
}
