package com.example.demo.findDeposit;

import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FindDepositController {

    private final RestTemplateFindSave restTemplateDeposit;

    @GetMapping(value = "/deposit/findSavingsDeposit", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> find(@RequestParam("userKey") String userKey) {
        String apiResult = restTemplateDeposit.findDepositProduct(userKey);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(apiResult);
    }
}
