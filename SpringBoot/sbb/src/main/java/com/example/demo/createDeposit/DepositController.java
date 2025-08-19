package com.example.demo.createDeposit;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class DepositController {

    private final RestTemplateDeposit restTemplateDeposit;

    public DepositController(RestTemplateDeposit restTemplateDeposit) {
        this.restTemplateDeposit = restTemplateDeposit;
    }

    @GetMapping("/deposit/create")
    @ResponseBody
    public String createDepositProduct() {
        String apiResult = restTemplateDeposit.createDepositProduct();
        return "수시 입출금 상품 생성 요청 결과:\n" + apiResult;
    }
}

