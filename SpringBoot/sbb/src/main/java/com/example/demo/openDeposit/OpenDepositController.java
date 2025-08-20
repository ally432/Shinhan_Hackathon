package com.example.demo.openDeposit;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class OpenDepositController {

    private final RestTemplateOpenDeposite restTemplateDeposit;

    public OpenDepositController(RestTemplateOpenDeposite restTemplateDeposit) {
        this.restTemplateDeposit = restTemplateDeposit;
    }

    @GetMapping("/deposit/openDeposit")
    @ResponseBody
    public String createDepositProduct() {
        String apiResult = restTemplateDeposit.createDepositProduct();
        return "예금 상품 개설 요청 결과:\n" + apiResult;
    }
}

