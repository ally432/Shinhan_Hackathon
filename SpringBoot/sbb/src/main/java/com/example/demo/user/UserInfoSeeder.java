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
import com.example.demo.user.UserInfo; // ✅ 누락 import 유지

@Configuration
@Profile("seed")
public class UserInfoSeeder {

    // 마이크로초(소수점) 자릿수 0~9 허용
    private static final DateTimeFormatter FLEX =
        new DateTimeFormatterBuilder()
            .appendPattern("yyyy-MM-dd HH:mm:ss")
            .optionalStart().appendLiteral('.')
            .appendFraction(ChronoField.MICRO_OF_SECOND, 1, 9, false)
            .optionalEnd()
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
        new String[]{"ssafy75484566586@ssafy.com","2025-08-17 07:48:37.476168","00100","2025-08-17 07:48:37.476168","865f4ca0-fea4-41be-8c02-37a61c819210","ssafy75484"},
        new String[]{"dd@dd.com","2025-08-27 03:14:40.579948","00100","2025-08-27 03:14:40.579948","7861c30c-0478-4fce-ab53-b4a2ec0a193b","dd"},
        new String[]{"ASWDAWDAW@ADCS.COM","2025-08-27 03:23:01.013014","00100","2025-08-27 03:23:01.013014","5764269e-a7c3-40fc-bf74-180aaca7540e","ASWDAWDAW"},
        new String[]{"AAaa@AAA.com","2025-08-27 03:34:43.794285","00100","2025-08-27 03:34:43.794285","da5e83cb-696a-4956-a17f-e0024c42548a","AAaa"},
        new String[]{"dwdawD@DASDKSD.com","2025-08-28 00:02:58.055257","00100","2025-08-28 00:02:58.055257","1a44d7ad-6d5c-4726-a767-e837a360e3cb","dwdawD"},
        new String[]{"skyblue927@gmail.com","2025-08-28 06:59:21.467725","00100","2025-08-28 06:59:21.467725","e4687795-8304-444f-ae55-24386e47f358","skyblue927"},
        new String[]{"green.stone21@gmail.com","2025-08-28 06:59:50.180075","00100","2025-08-28 06:59:50.180075","f9b3e041-dafc-4d87-ab32-71e245f260dd","green.ston"},
        new String[]{"windrunner83@naver.com","2025-08-28 07:01:13.423625","00100","2025-08-28 07:01:13.423625","f01f6a5a-3d16-409d-a709-1b9da0eed5da","windrunner"},
        new String[]{"cocoa_latte7@naver.com","2025-08-28 07:01:31.705599","00100","2025-08-28 07:01:31.705599","35cc29ab-796c-4762-8b75-2524a3d454dc","cocoa_latt"},
        new String[]{"mintnova90@naver.com","2025-08-28 07:01:51.142337","00100","2025-08-28 07:01:51.142337","2736ae48-c933-4dc0-b242-2c41f13f64ca","mintnova90"},
        new String[]{"brightmoon02@daum.net","2025-08-28 07:02:05.013979","00100","2025-08-28 07:02:05.013979","d83f9d29-a622-401b-86eb-125e0e5322f4","brightmoon"},
        new String[]{"silverline88@daum.net","2025-08-28 07:02:20.201122","00100","2025-08-28 07:02:20.201122","272d7249-2752-4341-8621-4c66d5317822","silverline"},
        new String[]{"nightowl710@hanmail.net","2025-08-28 07:02:32.991733","00100","2025-08-28 07:02:32.991733","e5a352ad-8e1e-49fd-85f6-8f26e1d3bb7b","nightowl71"},
        new String[]{"softwave33@hanmail.net","2025-08-28 07:02:45.348755","00100","2025-08-28 07:02:45.348755","508fb377-e991-43e4-87d1-3abc4d6c8855","softwave33"},
        new String[]{"pixel.note14@outlook.com","2025-08-28 07:02:57.861964","00100","2025-08-28 07:02:57.861964","54e668f9-6471-4b03-b052-290d18bd6206","pixel.note"},
        new String[]{"coralleaf99@outlook.com","2025-08-28 07:03:11.306971","00100","2025-08-28 07:03:11.306971","d60126ec-b6df-4a7d-b32d-560821ae34eb","coralleaf9"},
        new String[]{"duskcloud17@hotmail.com","2025-08-28 07:03:23.394175","00100","2025-08-28 07:03:23.394175","85605624-dfbb-4a45-a8c6-475b812fc2fc","duskcloud1"},
        new String[]{"oceantrail58@yahoo.com","2025-08-28 07:03:34.69002","00100","2025-08-28 07:03:34.69002","818266cb-62a6-4477-93cc-8877f2ac6efb","oceantrail"},
        new String[]{"maplepath73@nate.com","2025-08-28 07:03:44.067853","00100","2025-08-28 07:03:44.067853","cea44007-5e66-4920-9312-44e793441738","maplepath7"},
        new String[]{"cloudbook12@icloud.com","2025-08-28 07:04:19.296667","00100","2025-08-28 07:04:19.296667","2229c1e3-cc69-4376-938e-b524ca53e1f9","cloudbook1"},
        new String[]{"swiftpeak64@icloud.com","2025-08-28 07:04:30.650655","00100","2025-08-28 07:04:30.650655","a9cbedf9-5e9e-4e3d-9913-d989bb577654","swiftpeak6"},
        new String[]{"lemonriver27@proton.me","2025-08-28 07:04:43.449754","00100","2025-08-28 07:04:43.449754","542234aa-b1c7-4fdb-a0d4-6eeb5bceebd5","lemonriver"},
        new String[]{"stonebridge46@gmail.com","2025-08-28 07:04:55.310169","00100","2025-08-28 07:04:55.310169","d98d95c7-1154-4357-9390-49eec9a604b6","stonebridg"},
        new String[]{"orchidwave82@gmail.com","2025-08-28 07:08:08.828722","00100","2025-08-28 07:08:08.828722","92b37710-8e02-402f-9bdf-d8ecf9ed8ac9","orchidwave"},
        new String[]{"bluehorizon24@naver.com","2025-08-28 07:08:24.606455","00100","2025-08-28 07:08:24.606455","d30c22f7-084f-4a97-8782-873be8a5ab2c","bluehorizo"},

        // ===== ✅ 추가(요청하신 신규 항목들) =====
        new String[]{"qwertyuiop@qwertyuiop.com","2025-08-26 15:09:49.409818","00100","2025-08-26 15:09:49.409818","950c0f9f-7541-40d1-a56a-f85ee89c58c4","qwertyuiop"},
        new String[]{"Shin@ssafy.com","2025-08-28 13:42:16.788908","00100","2025-08-28 13:42:16.788908","899fdb7d-3dd6-4b26-9329-35360abec2f4","Shin"},
        new String[]{"spring.morning@naver.com","2025-08-27 14:13:51.281852","00100","2025-08-27 14:13:51.281852","5a3a442b-af8f-4756-bd67-bb3b16e116d1","spring.mor"},
        new String[]{"stonebridge46@ssafy.com","2025-08-28 13:26:39.640048","00100","2025-08-28 13:26:39.640048","043020bf-3583-4fe1-8b21-26ef09a6fe84","stonebridg"},
        new String[]{"sunny.sundae@gmail.com","2025-08-27 14:13:02.194358","00100","2025-08-27 14:13:02.194358","6ef69c0f-5c5e-4ee5-84e8-a65b50c3dc36","sunny.sund"},
        new String[]{"surf61@ssafy.com","2025-08-28 13:35:07.783342","00100","2025-08-28 13:35:07.783342","9dc79970-e5c2-4a23-9c5b-ea255ee9ff8e","surf61"},
        new String[]{"vanilla.sketch@gmail.com","2025-08-27 14:15:24.290768","00100","2025-08-27 14:15:24.290768","384f8cd7-a909-4f8a-81ff-2476882ef749","vanilla.sk"},
        new String[]{"velvet.stream29@ssafy.com","2025-08-28 13:39:37.383817","00100","2025-08-28 13:39:37.383817","ee66b298-6ccd-442b-b5eb-1749e5a732ee","velvet.str"},
        new String[]{"warm.tangerine@daum.net","2025-08-27 14:14:31.679559","00100","2025-08-27 14:14:31.679559","e7704773-8099-458b-b149-d90c372b50b8","warm.tange"}
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
        try { return LocalDateTime.parse(s, FLEX); }
        catch (Exception e) { return null; }
    }

    private static String trunc(String s, int max) {
        if (s == null) return null;
        return s.length() > max ? s.substring(0, max) : s;
    }
}
