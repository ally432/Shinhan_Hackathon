package com.example.demo.user;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import lombok.RequiredArgsConstructor;

@Configuration
@Profile("seed")
@RequiredArgsConstructor
public class TargetScoreSeeder {

    private final TargetScoreRepository repo;

    // 예: 2025-08-28 20:49:26.192567 형태 유연 파서
    private static final DateTimeFormatter FLEX = new DateTimeFormatterBuilder()
            .appendPattern("yyyy-MM-dd HH:mm:ss")
            .optionalStart().appendLiteral('.')
            .appendFraction(ChronoField.MICRO_OF_SECOND, 1, 9, false)
            .optionalEnd()
            .toFormatter();

    @Bean
    CommandLineRunner seedTargetScores() {
        return args -> {
            // userKey, goal1, goal2, created, updated
            record Row(String uk, String s1, String s2, String created, String updated) {}

            List<Row> rows = List.of(
                // --- 기존 1~18행 (네 코드 그대로) ---
                new Row("1a44d7ad-6d5c-4726-a767-e837a360e3cb","4.30","4.00","2025-08-28 20:49:26.192567","2025-08-28 20:49:26.192567"),
                new Row("38182920-441a-48a9-8eae-8606df75ba25","3.70","3.70","2025-08-28 20:49:26.226200","2025-08-28 20:49:26.226200"),
                new Row("5764269e-a7c3-40fc-bf74-180aaca7540e","3.70","4.30","2025-08-28 20:49:26.232994","2025-08-28 20:49:26.232994"),
                new Row("7296256f-25ac-44ae-a761-1a7b6a24e1ae","4.30","4.00","2025-08-28 20:49:26.238929","2025-08-28 20:49:26.238929"),
                new Row("760a0369-3f4b-4157-95ce-67725398a33a","3.70","4.00","2025-08-28 20:49:26.244173","2025-08-28 20:49:26.244173"),
                new Row("7861c30c-0478-4fce-ab53-b4a2ec0a193b","3.70","4.30","2025-08-28 20:49:26.249403","2025-08-28 20:49:26.249403"),
                new Row("865f4ca0-fea4-41be-8c02-37a61c819210","4.30","4.00","2025-08-28 20:49:26.255065","2025-08-28 20:49:26.255065"),
                new Row("90c0cf18-cf26-4e26-b1ac-48311c999231","3.70","3.70","2025-08-28 20:49:26.259152","2025-08-28 20:49:26.259152"),
                new Row("97eef193-dd2f-41a3-8880-a957800ee1b9","3.70","3.70","2025-08-28 20:49:26.265869","2025-08-28 20:49:26.265869"),
                new Row("d0f22cc4-f59a-47ee-88df-11d9b59e1da5","4.30","4.00","2025-08-28 20:49:26.272963","2025-08-28 20:49:26.272963"),
                new Row("da5e83cb-696a-4956-a17f-e0024c42548a","3.70","3.70","2025-08-28 20:49:26.278890","2025-08-28 20:49:26.278890"),
                new Row("e8a7d57a-8bb7-41d2-ab3d-f03f0cb20ff8","3.70","4.30","2025-08-28 20:49:26.283925","2025-08-28 20:49:26.283925"),
                new Row("eb1a1865-f9be-49ab-80b7-a9698f9bf1a0","4.30","4.00","2025-08-28 20:49:26.289281","2025-08-28 20:49:26.289281"),
                new Row("2736ae48-c933-4dc0-b242-2c41f13f64ca","4.30","3.70","2025-08-28 20:54:35.318027","2025-08-28 21:17:25.245703"),
                new Row("e4687795-8304-444f-ae55-24386e47f358","4.00","4.30","2025-08-28 20:57:53.841711","2025-08-28 21:00:20.946762"),
                new Row("f9b3e041-dafc-4d87-ab32-71e245f260dd","3.70","4.00","2025-08-28 21:06:17.785303","2025-08-28 21:06:17.785303"),
                new Row("f01f6a5a-3d16-409d-a709-1b9da0eed5da","4.30","4.00","2025-08-28 21:09:16.588301","2025-08-28 21:09:21.049058"),
                new Row("35cc29ab-796c-4762-8b75-2524a3d454dc","4.00","4.00","2025-08-28 21:11:24.592372","2025-08-28 21:14:41.621645"),

                // --- 추가 19~37행 ---
                new Row("d83f9d29-a622-401b-86eb-125e0e5322f4","3.70","4.00","2025-08-28 21:28:51.439790","2025-08-28 21:28:51.439790"),
                new Row("272d7249-2752-4341-8621-4c66d5317822","4.30","4.30","2025-08-28 21:31:23.360110","2025-08-28 21:31:23.360110"),
                new Row("e5a352ad-8e1e-49fd-85f6-8f26e1d3bb7b","4.00","4.30","2025-08-28 21:33:48.040101","2025-08-28 21:33:48.040101"),
                new Row("508fb377-e991-43e4-87d1-3abc4d6c8855","3.70","3.70","2025-08-28 21:43:16.465795","2025-08-28 21:43:16.465795"),
                new Row("54e668f9-6471-4b03-b052-290d18bd6206","4.30","4.00","2025-08-28 21:46:19.099842","2025-08-28 21:46:19.099842"),
                new Row("d60126ec-b6df-4a7d-b32d-560821ae34eb","4.00","3.70","2025-08-28 21:49:05.661157","2025-08-28 21:49:05.661157"),
                new Row("85605624-dfbb-4a45-a8c6-475b812fc2fc","4.30","3.70","2025-08-28 21:51:34.602465","2025-08-28 21:51:51.048927"),
                new Row("818266cb-62a6-4477-93cc-8877f2ac6efb","4.00","4.00","2025-08-28 21:56:41.525401","2025-08-28 21:56:41.525401"),
                new Row("cea44007-5e66-4920-9312-44e793441738","3.70","4.30","2025-08-28 22:09:44.054473","2025-08-28 22:09:44.054473"),
                new Row("2229c1e3-cc69-4376-938e-b524ca53e1f9","3.70","4.30","2025-08-28 22:12:59.564293","2025-08-28 22:12:59.564293"),
                new Row("a9cbedf9-5e9e-4e3d-9913-d989bb577654","4.00","4.30","2025-08-28 22:19:43.936436","2025-08-28 22:19:43.936436"),
                new Row("f82001f4-1da9-461b-8673-ba1f6c4a1c6d","4.30","4.30","2025-08-28 22:24:20.412894","2025-08-28 22:25:45.453118"),
                new Row("043020bf-3583-4fe1-8b21-26ef09a6fe84","3.70","4.30","2025-08-28 22:27:48.076500","2025-08-28 22:27:48.076500"),
                new Row("92b37710-8e02-402f-9bdf-d8ecf9ed8ac9","3.70","4.00","2025-08-28 22:29:58.451473","2025-08-28 22:30:04.979410"),
                new Row("d30c22f7-084f-4a97-8782-873be8a5ab2c","4.00","4.30","2025-08-28 22:32:17.102782","2025-08-28 22:32:17.102782"),
                new Row("9dc79970-e5c2-4a23-9c5b-ea255ee9ff8e","4.00","4.30","2025-08-28 22:36:10.648461","2025-08-28 22:36:10.648461"),
                new Row("ba017686-0c08-4093-be3a-6c495a87d16d","3.70","3.70","2025-08-28 22:38:19.230991","2025-08-28 22:38:19.230991"),
                new Row("ee66b298-6ccd-442b-b5eb-1749e5a732ee","4.00","3.70","2025-08-28 22:40:47.592111","2025-08-28 22:40:47.592111"),
                new Row("899fdb7d-3dd6-4b26-9329-35360abec2f4","4.30","4.30","2025-08-28 22:43:43.285232","2025-08-28 22:43:43.285232")
            );

            for (Row r : rows) {
                LocalDateTime created = parseFlex(r.created());
                LocalDateTime updated = parseFlex(r.updated());

                var ts = repo.findByUserKey(r.uk()).orElseGet(TargetScore::new);
                if (ts.getId() == null) {
                    ts.setUserKey(r.uk());
                    ts.setCreatedAt(created != null ? created : LocalDateTime.now());
                }
                ts.setGoalSem1(bd(r.s1()));
                ts.setGoalSem2(bd(r.s2()));
                ts.setUpdatedAt(updated != null ? updated
                        : (ts.getCreatedAt() != null ? ts.getCreatedAt() : LocalDateTime.now()));
                repo.save(ts);
            }
        };
    }

    private static BigDecimal bd(String v) { return new BigDecimal(v); }

    private static LocalDateTime parseFlex(String s) {
        if (s == null) return null;
        try { return LocalDateTime.parse(s, FLEX); }
        catch (Exception e) { return null; }
    }
}
