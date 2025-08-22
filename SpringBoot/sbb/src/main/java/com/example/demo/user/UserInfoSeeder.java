package com.example.demo.user;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import com.example.demo.signup.UserInfoRepository;

@Configuration
@Profile("seed")
public class UserInfoSeeder {

    // 마이크로초(소수점) 자릿수 0~9 허용
    private static final DateTimeFormatter FLEX =
        new DateTimeFormatterBuilder()
            .appendPattern("yyyy-MM-dd HH:mm:ss")
            .optionalStart().appendLiteral('.').appendFraction(ChronoField.MICRO_OF_SECOND, 1, 9, false).optionalEnd()
            .toFormatter();

    // userId, created, institutionCode, modified, userKey, username
    private static final List<String[]> RAW = List.of(
        new String[]{"123456@ssafy.com","2025-08-17 07:57:53.954714","00100","2025-08-17 07:57:53.954714","e8a7d57a-8bb7-41d2-ab3d-f03f0cb20ff8","123456"},
        new String[]{"asdadsd111111@asdsdsad.com","2025-08-16 13:16:05.062144","00100","2025-08-16 13:16:05.062144","760a0369-3f4b-4157-95ce-67725398a33a","asdadsd111"},
        new String[]{"asdadsd12121@asdsdsad.com","2025-08-16 12:55:11.761292","00100","2025-08-16 12:55:11.761292","38182920-441a-48a9-8eae-8606df75ba25","asdadsd121"},
        new String[]{"asdadsd5466@asdsdsad.com","2025-08-16 12:53:02.993955","00100","2025-08-16 12:53:02.993955","90c0cf18-cf26-4e26-b1ac-48311c999231","asdadsd546"},
        new String[]{"dfjsioejfemfkl@ssafy.com","2025-08-17 09:48:38.013204","00100","2025-08-17 09:48:38.013204","7296256f-25ac-44ae-a761-1a7b6a24e1ae","dfjsioejfe"},
        new String[]{"sdjfkslaj@ssafy.com","2025-08-17 09:39:03.415603","00100","2025-08-17 09:39:03.415603","97eef193-dd2f-41a3-8880-a957800ee1b9","sdjfkslaj"},
        new String[]{"ssafy12345687@ssafy.com","2025-08-17 07:40:16.849169","00100","2025-08-17 07:40:16.849169","d0f22cc4-f59a-47ee-88df-11d9b59e1da5","ssafy12345"},
        new String[]{"ssafy51521451451458476697@ssafy.com","2025-08-17 07:56:57.475606","00100","2025-08-17 07:56:57.475606","eb1a1865-f9be-49ab-80b7-a9698f9bf1a0","ssafy51521"},
        new String[]{"ssafy75484566586@ssafy.com","2025-08-17 07:48:37.476168","00100","2025-08-17 07:48:37.476168","865f4ca0-fea4-41be-8c02-37a61c819210","ssafy75484"}
    );

    @Bean
    CommandLineRunner seedUserInfo(UserInfoRepository repo) {
        return args -> {
            for (String[] r : RAW) {
                String userId = r[0];
                String institutionCode = r[2];
                String userKey = r[4];
                String username = r[5];

                LocalDateTime created  = parseFlex(r[1]);
                LocalDateTime modified = parseFlex(r[3]);

                repo.findById(userId).ifPresentOrElse(existing -> {
                    // ✅ 업데이트 (upsert)
                    existing.setInstitutionCode(trunc(institutionCode, 40));
                    existing.setUserKey(trunc(userKey, 60));
                    existing.setUsername(trunc(username, 10));
                    existing.setModified(modified != null ? modified : LocalDateTime.now());
                    repo.save(existing);
                }, () -> {
                    // ✅ 신규 생성
                    UserInfo u = new UserInfo();
                    u.setUserId(trunc(userId, 40));
                    u.setInstitutionCode(trunc(institutionCode, 40));
                    u.setUserKey(trunc(userKey, 60));
                    u.setUsername(trunc(username, 10));
                    u.setCreated(created != null ? created : LocalDateTime.now());
                    u.setModified(modified != null ? modified : u.getCreated());
                    repo.save(u);
                });
            }
        };
    }

    private static LocalDateTime parseFlex(String s) {
        if (s == null) return null;
        try {
            return LocalDateTime.parse(s, FLEX);
        } catch (Exception e) {
            return null; // 실패 시 호출부에서 now() 대입
        }
    }

    private static String trunc(String s, int max) {
        if (s == null) return null;
        return s.length() > max ? s.substring(0, max) : s;
        // 필요하면 잘림 로깅 추가 가능
    }
}
