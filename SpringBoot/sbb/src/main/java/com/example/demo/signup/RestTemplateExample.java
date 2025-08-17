package com.example.demo.signup;

import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class RestTemplateExample {

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${app.finapi.api-key:}")
    private String apiKey;

    public MemberCreateResponse callMemberApiForDto(String userId) {
        String url = "https://finopenapi.ssafy.io/ssafy/api/v1/member";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> requestBody = Map.of(
                "apiKey", apiKey,
                "userId", userId
        );

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
        ResponseEntity<MemberCreateResponse> response =
                restTemplate.exchange(url, HttpMethod.POST, entity, MemberCreateResponse.class);

        if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
            throw new IllegalStateException("회원 생성 API 실패: " + response.getStatusCode());
        }
        return response.getBody();
    }
}
