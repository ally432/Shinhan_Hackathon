// com.example.demo.signup.SuccessController (클래스명/경로는 너가 쓰는 대로)
package com.example.demo.signup;

import com.example.demo.user.UserInfo;
import com.example.demo.signup.UserInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
@RequestMapping("/signup")
public class SuccessController {

    private final RestTemplateExample restTemplateExample;
    private final UserInfoService userInfoService;

    @GetMapping("/success")
    @ResponseBody
    public String success(@RequestParam("email") String email) {
        var welcome = "안녕하세요. 환영합니다.\n\n";

        // 1) 외부 API 호출 → DTO
        var dto = restTemplateExample.callMemberApiForDto(email);

        // 2) DB 저장
        UserInfo saved = userInfoService.saveFromApi(dto);

        // 3) 결과 간단 표시
        return welcome +
                "[저장 완료]\n" +
                "userId=" + saved.getUserId() + "\n" +
                "username=" + saved.getUsername() + "\n" +
                "institutionCode=" + saved.getInstitutionCode() + "\n" +
                "userKey=" + saved.getUserKey() + "\n" +
                "created=" + saved.getCreated() + "\n" +
                "modified=" + saved.getModified() + "\n";
    }
}
