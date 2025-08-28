package com.example.demo.user;

import java.math.BigDecimal;
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

    @Bean
    CommandLineRunner seedTargetScores() {
        return args -> {
            // (userKey, goalSem1, goalSem2)
            record Row(String userKey, BigDecimal s1, BigDecimal s2) {}

            List<Row> rows = List.of(
                new Row("1a44d7ad-6d5c-4726-a767-e837a360e3cb", bd("4.30"), bd("4.00")),
                new Row("38182920-441a-48a9-8eae-8606df75ba25", bd("3.70"), bd("3.70")),
                new Row("5764269e-a7c3-40fc-bf74-180aaca7540e", bd("3.70"), bd("4.30")),
                new Row("7296256f-25ac-44ae-a761-1a7b6a24e1ae", bd("4.30"), bd("4.00")),
                new Row("760a0369-3f4b-4157-95ce-67725398a33a", bd("3.70"), bd("4.00")),
                new Row("7861c30c-0478-4fce-ab53-b4a2ec0a193b", bd("3.70"), bd("4.30")),
                new Row("865f4ca0-fea4-41be-8c02-37a61c819210", bd("4.30"), bd("4.00")),
                new Row("90c0cf18-cf26-4e26-b1ac-48311c999231", bd("3.70"), bd("3.70")),
                new Row("97eef193-dd2f-41a3-8880-a957800ee1b9", bd("3.70"), bd("3.70")),
                new Row("d0f22cc4-f59a-47ee-88df-11d9b59e1da5", bd("4.30"), bd("4.00")),
                new Row("da5e83cb-696a-4956-a17f-e0024c42548a", bd("3.70"), bd("3.70")),
                new Row("e8a7d57a-8bb7-41d2-ab3d-f03f0cb20ff8", bd("3.70"), bd("4.30")),
                new Row("eb1a1865-f9be-49ab-80b7-a9698f9bf1a0", bd("4.30"), bd("4.00"))
            );

            for (Row r : rows) {
                TargetScore ts = repo.findByUserKey(r.userKey()).orElseGet(TargetScore::new);
                if (ts.getId() == null) ts.setUserKey(r.userKey());
                ts.setGoalSem1(r.s1());
                ts.setGoalSem2(r.s2());
                repo.save(ts);
            }
        };
    }

    private static BigDecimal bd(String v) { return new BigDecimal(v); }
}
