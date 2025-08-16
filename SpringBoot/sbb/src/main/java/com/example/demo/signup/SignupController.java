package com.example.demo.signup;

import lombok.Data;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/user")
public class SignupController {

    @GetMapping("/signup")
    public String showForm(Model model) {
        model.addAttribute("form", new SignupForm());
        return "signup_form";
    }

    @PostMapping("/signup")
    public String submit(@ModelAttribute("form") SignupForm form) {
        String encoded = java.net.URLEncoder.encode(form.getEmail(), java.nio.charset.StandardCharsets.UTF_8);
        return "redirect:/signup/success?email=" + encoded;
    }


    @Data
    public static class SignupForm {
        private String email;
    }
}
