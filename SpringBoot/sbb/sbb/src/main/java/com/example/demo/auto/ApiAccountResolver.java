package com.example.demo.auto;

import com.example.demo.findAccount.RestTemplateFind;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ApiAccountResolver {

 private final RestTemplateFind rest;  // 네가 준 호출기
 private final ObjectMapper om = new ObjectMapper();

 /**
  * userKey로 OpenAPI를 조회해서 가장 우선 계좌번호 하나를 반환.
  * - 여러 개면 첫 번째 사용 (원하면 우선순위 로직 확장)
  * - 하이픈/공백 제거
  */
 public String findAccountNoOrThrow(String userKey) {
     String json = rest.findDepositProduct(userKey);
     try {
         JsonNode root = om.readTree(json);

         // 응답 코드 체크(가능하면)
         String code = root.path("Header").path("responseCode").asText("");
         if (!code.isEmpty() && !"H0000".equals(code)) {
             throw new IllegalStateException("API responseCode=" + code);
         }

         List<String> accs = new ArrayList<>();
         collectAccountNos(root, accs);

         if (accs.isEmpty()) {
             throw new IllegalStateException("API에서 accountNo를 찾지 못함");
         }

         String raw = accs.get(0);
         String clean = raw.replaceAll("\\D", ""); // 숫자만
         if (clean.isEmpty()) {
             throw new IllegalStateException("계좌번호 정규화 실패: " + raw);
         }

         log.info("[AccountResolver] userKey={} -> accountNo(raw='{}', clean='{}')",
                 mask(userKey), raw, maskAcc(clean));
         return clean;

     } catch (Exception e) {
         log.error("[AccountResolver] userKey={} 계좌 조회/파싱 실패: {}",
                 mask(userKey), e.toString());
         throw new IllegalStateException("계좌 조회 실패", e);
     }
 }

 /** JSON 트리를 순회하며 'accountNo' 필드를 모두 수집 */
 private void collectAccountNos(JsonNode node, List<String> out) {
     if (node == null) return;

     if (node.isObject()) {
         node.fields().forEachRemaining(e -> {
             String name = e.getKey();
             JsonNode v = e.getValue();
             if ("accountNo".equalsIgnoreCase(name) && v.isTextual()) {
                 out.add(v.asText());
             }
             // 계속 순회
             collectAccountNos(v, out);
         });
     } else if (node.isArray()) {
         for (JsonNode child : node) {
             collectAccountNos(child, out);
         }
     }
 }

 private String mask(String v) {
     if (v == null || v.length() < 8) return "****";
     return v.substring(0, 4) + "****" + v.substring(v.length() - 4);
 }
 private String maskAcc(String v) {
     if (v == null || v.length() < 6) return "****";
     return "****" + v.substring(v.length() - 4);
 }
}
