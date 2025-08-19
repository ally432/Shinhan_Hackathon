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
        String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/demandDeposit/createDemandDeposit";

        Map<String, Object> header = new HashMap<>();
        header.put("apiName", "createDemandDeposit");
        header.put("transmissionDate", "20250819");
        header.put("transmissionTime", "215700");
        header.put("institutionCode", "00100");
        header.put("fintechAppNo", "001");
        header.put("apiServiceCode", "createDemandDeposit");
        header.put("institutionTransactionUniqueNo", "20250819215700123560");
        header.put("apiKey", "a2d9331aee534c1794cf1eafd1bc7a17");

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("Header", header);
        requestBody.put("bankCode", "088");
        requestBody.put("accountName", "쏠편한 입출금통장");
        requestBody.put("accountDescription", "이체수수료(모바일, 인터넷, 폰뱅킹ARS), 인출수수료 (신한은행CD/ATM), 타행자동이체수수료가 무제한 면제되는 통장");

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
