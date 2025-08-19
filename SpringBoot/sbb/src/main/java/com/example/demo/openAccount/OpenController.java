package com.example.demo.openAccount;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class OpenController {

    private final RestTemplateOpen restTemplateDeposit;

    public OpenController(RestTemplateOpen restTemplateDeposit) {
        this.restTemplateDeposit = restTemplateDeposit;
    }

    @GetMapping("/deposit/open")
    @ResponseBody
    public String createDepositProduct() {
        String apiResult = restTemplateDeposit.createDepositProduct();
        return "수시 입출금 상품 개설 요청 결과:\n" + apiResult;
    }
}

