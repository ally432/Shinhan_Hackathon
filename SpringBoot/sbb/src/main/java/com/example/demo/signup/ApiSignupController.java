package com.example.demo.signup;

import com.example.demo.signup.SignupRequest;
import com.example.demo.signup.SignupResponse;
import com.example.demo.user.UserInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api")
public class ApiSignupController {

    private final RestTemplateExample restTemplateExample;
    private final UserInfoService userInfoService;

    @PostMapping("/signup")
    public ResponseEntity<SignupResponse> signup(@RequestBody SignupRequest req) {
        var dto = restTemplateExample.callMemberApiForDto(req.getEmail());
        
        UserInfo saved = userInfoService.saveFromApi(dto);
        
        return ResponseEntity.ok(
            new SignupResponse(
                saved.getUserId(),
                saved.getUsername(),
                saved.getInstitutionCode(),
                saved.getUserKey()
            )
        );
    }
}
