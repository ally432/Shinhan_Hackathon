// com.example.demo.MainController
package com.example.demo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.example.demo.signup.RestTemplateExample;

@Controller
public class MainController {

    @GetMapping("/sbb")
    @ResponseBody
    public String index() {
        String welcome = "안녕하세요. 환영합니다.\n\n";

        return welcome;
    }
}
