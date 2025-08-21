package com.example.demo.user;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.transaction.annotation.Transactional;

@Configuration
@Profile("seed")
public class GradeRecordSeeder {

    private static final List<String> USER_IDS = List.of(
        "123456@ssafy.com",
        "asdadsd111111@asdsdsad.com",
        "asdadsd12121@asdsdsad.com",
        "asdadsd5466@asdsdsad.com",
        "dfjsioejfemfkl@ssafy.com",
        "sdjfkslaj@ssafy.com",
        "ssafy12345687@ssafy.com",
        "ssafy51521451451458476697@ssafy.com",
        "ssafy75484566586@ssafy.com"
    );

    private static final Map<String, int[][]> TERMS_BY_USER = new LinkedHashMap<>() {{
        put("123456@ssafy.com", new int[][]{
            {2023,1},{2023,2},{2024,1},{2024,2},{2025,1}
        });
        put("asdadsd111111@asdsdsad.com", new int[][]{
            {2021,1},{2021,2},{2022,1},{2022,2},{2023,1},{2023,2},{2025,1}
        });
        put("asdadsd12121@asdsdsad.com", new int[][]{
            {2022,1},{2022,2},{2023,1},{2024,2},{2025,1}
        });
        put("asdadsd5466@asdsdsad.com", new int[][]{
            {2021,1},{2021,2},{2023,1},{2023,2},{2024,2},{2025,1}
        });
        put("dfjsioejfemfkl@ssafy.com", new int[][]{
            {2021,2},{2022,1},{2023,2},{2024,1},{2025,1}
        });
        put("sdjfkslaj@ssafy.com", new int[][]{
            {2020,2},{2021,1},{2022,2},{2024,1},{2025,1}
        });
        put("ssafy12345687@ssafy.com", new int[][]{
            {2022,1},{2022,2},{2023,1},{2024,1},{2025,1}
        });
        put("ssafy51521451451458476697@ssafy.com", new int[][]{
            {2020,1},{2020,2},{2021,2},{2023,1},{2025,1}
        });
        put("ssafy75484566586@ssafy.com", new int[][]{
            {2024,1},{2024,2},{2025,1}
        });
    }};

    @Bean
    CommandLineRunner seedGradeRecords(GradeRecordRepository gradeRepo) {
        return args -> seed(gradeRepo);
    }

    @Transactional
    protected void seed(GradeRecordRepository gradeRepo) {
        for (String userId : USER_IDS) {
            int[][] terms = TERMS_BY_USER.getOrDefault(userId, new int[0][0]);

            for (int[] term : terms) {
                int year = term[0];
                int sem  = term[1];

                if (gradeRepo.findByUserIdAndYearAndSemester(userId, year, sem).isPresent()) continue;

                GradeRecord gr = new GradeRecord();
                gr.setUserId(trunc(userId, 40));
                gr.setYear(year);
                gr.setSemester(sem);

                // 예시 기본값
                gr.setTotalCredits(15);
                gr.setTotalGpa(3.5);
                gr.setType("전공");

                gradeRepo.save(gr);
            }
        }
    }

    private static String trunc(String s, int max) {
        if (s == null) return null;
        return s.length() > max ? s.substring(0, max) : s;
    }
}
