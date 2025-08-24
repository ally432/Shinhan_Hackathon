package com.example.demo.findAccount;

import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FindAccountController {

    private final RestTemplateFind restTemplateDeposit;

    @GetMapping(value = "/deposit/findOpenDeposit", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> find(@RequestParam("userKey") String userKey) {
        String apiResult = restTemplateDeposit.findDepositProduct(userKey);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(apiResult);
    }
}
