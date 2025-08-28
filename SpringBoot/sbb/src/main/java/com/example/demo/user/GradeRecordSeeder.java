package com.example.demo.user;

import java.util.List;
import java.util.Map;

import static java.util.Map.entry;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.*;
import org.springframework.transaction.annotation.Transactional;

@Configuration
@Profile("seed")
public class GradeRecordSeeder {

 // 시드 대상 사용자들 (기존 리스트 유지)
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

 // 이번에 생성할 학기만 고정
 private static final int[][] TERMS = new int[][] {
     {2025, 1},
     {2024, 2}
 };

 // 🔒 사용자/학기별 고정 GPA 테이블 (대부분 3점대)
 // 키는 "yyyy-s" 형식 (예: "2025-1", "2024-2")
 private static final Map<String, Map<String, Double>> FIXED_GPA = Map.ofEntries(
     entry("123456@ssafy.com", Map.of("2025-1", 3.92, "2024-2", 3.78)),
     entry("asdadsd111111@asdsdsad.com", Map.of("2025-1", 4.5, "2024-2", 3.45)),
     entry("asdadsd12121@asdsdsad.com", Map.of("2025-1", 3.05, "2024-2", 4.29)),
     entry("asdadsd5466@asdsdsad.com", Map.of("2025-1", 3.78, "2024-2", 4.19)),
     entry("dfjsioejfemfkl@ssafy.com", Map.of("2025-1", 3.88, "2024-2", 3.34)),
     entry("sdjfkslaj@ssafy.com", Map.of("2025-1", 4.21, "2024-2", 3.09)),
     entry("ssafy12345687@ssafy.com", Map.of("2025-1", 3.73, "2024-2", 3.56)),
     entry("ssafy51521451451458476697@ssafy.com", Map.of("2025-1", 3.49, "2024-2", 3.14)),
     entry("ssafy75484566586@ssafy.com", Map.of("2025-1", 3.84, "2024-2", 3.26))
 );

 @Bean
 CommandLineRunner seedGradeRecords(GradeRecordRepository gradeRepo) {
     return args -> seed(gradeRepo);
 }

 @Transactional
 protected void seed(GradeRecordRepository gradeRepo) {
     for (String userId : USER_IDS) {
         for (int[] term : TERMS) {
             int year = term[0];
             int sem  = term[1];

             if (gradeRepo.findByUserIdAndYearAndSemester(userId, year, sem).isPresent()) {
                 continue;
             }

             GradeRecord gr = new GradeRecord();
             gr.setUserId(trunc(userId, 40));
             gr.setYear(year);
             gr.setSemester(sem);

             // 학점: 간단히 학기별 고정 (원하면 테이블로 더 쪼개도 됨)
             gr.setTotalCredits(sem == 1 ? 18 : 15);

             // GPA: 테이블에서 고정값 주입 (없으면 기본 3.33)
             double gpa = gpaFor(userId, year, sem);
             gr.setTotalGpa(gpa);

             gr.setType("전공");

             gradeRepo.save(gr);
         }
     }
 }

 private static double gpaFor(String userId, int year, int sem) {
     String key = year + "-" + sem; // ex) "2025-1"
     return FIXED_GPA.getOrDefault(userId, Map.of())
                     .getOrDefault(key, 3.33);
 }

 private static String trunc(String s, int max) {
     if (s == null) return null;
     return s.length() > max ? s.substring(0, max) : s;
 }
}
