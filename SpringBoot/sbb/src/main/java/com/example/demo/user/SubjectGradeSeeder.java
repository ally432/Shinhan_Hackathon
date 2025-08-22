package com.example.demo.user;

import java.util.List;
import java.util.Objects;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.*;
import org.springframework.transaction.annotation.Transactional;

@Configuration
@Profile("seed")
public class SubjectGradeSeeder {

    // 과목 풀 (원하면 추가/수정하세요)
    private static final List<String> SUBJECT_POOL = List.of(
        "자료구조", "운영체제", "알고리즘", "데이터베이스", "컴퓨터구조",
        "네트워크", "웹프로그래밍", "소프트웨어공학", "인공지능개론",
        "모바일프로그래밍", "클라우드컴퓨팅", "빅데이터분석",
        "영어회화", "기초통계", "사고와표현", "철학개론"
    );

    private static final String[] LETTERS = {"A+", "A", "B+", "B", "C+", "C", "D", "F"};
    private static final double[] WEIGHT  = { 0.18, 0.32, 0.20, 0.15, 0.08, 0.05, 0.015, 0.005 };

    @Bean
    CommandLineRunner seedSubjectGrades(GradeRecordRepository gradeRepo,
                                        SubjectGradeRepository subjectRepo) {
        return args -> seed(gradeRepo, subjectRepo);
    }

    @Transactional
    protected void seed(GradeRecordRepository gradeRepo,
                        SubjectGradeRepository subjectRepo) {

        List<GradeRecord> records = gradeRepo.findAll();

        for (GradeRecord gr : records) {
            // 이미 과목이 있으면 스킵
            if (subjectRepo.countByGradeRecordId(gr.getId()) > 0) continue;

            // 학기당 4~6과목 생성 (결정적 난수)
            int count = randBetween(4, 6, gr);

            double sumWeighted = 0.0;
            int    sumCredits  = 0;

            for (int i = 0; i < count; i++) {
                String subject = pickSubject(gr, i);
                double credit  = pickCredit(gr, i);     // 2.0 or 3.0
                String letter  = pickLetter(gr, i);     // A+ ~ F
                double point   = letterToPoint(letter); // 4.5 만점 기준

                SubjectGrade sg = new SubjectGrade();
                sg.setSubjectName(subject);
                sg.setCredit(credit);
                sg.setGrade(letter);
                sg.setScore(point);
                sg.setGradeRecord(gr);
                subjectRepo.save(sg);

                sumCredits  += (int) credit;
                sumWeighted += point * credit;
            }

            // GradeRecord 갱신(가중 평균 GPA, 총 이수학점)
            double gpa = (sumCredits == 0) ? 0.0 : (sumWeighted / sumCredits);
            gr.setTotalCredits(sumCredits);
            gr.setTotalGpa(round(gpa, 2));
            gradeRepo.save(gr);
        }
    }

    // ---------- helpers ----------
    private static int randBetween(int min, int max, GradeRecord gr) {
        long seed = Objects.hash(gr.getUserId(), gr.getYear(), gr.getSemester(), "cnt");
        int span = max - min + 1;
        return min + (int)(Math.abs(seed) % span);
    }

    private static String pickSubject(GradeRecord gr, int idx) {
        int i = (int)(rand(gr, idx) % SUBJECT_POOL.size());
        return SUBJECT_POOL.get(i);
    }

    private static double pickCredit(GradeRecord gr, int idx) {
        return (rand(gr, idx) % 2 == 0) ? 3.0 : 2.0;
    }

    private static String pickLetter(GradeRecord gr, int idx) {
        double r = rand01(gr, idx);
        double acc = 0.0;
        for (int i = 0; i < LETTERS.length; i++) {
            acc += WEIGHT[i];
            if (r <= acc) return LETTERS[i];
        }
        return LETTERS[LETTERS.length - 1];
    }

    private static double letterToPoint(String letter) {
        return switch (letter) {
            case "A+" -> 4.5;
            case "A"  -> 4.0;
            case "B+" -> 3.5;
            case "B"  -> 3.0;
            case "C+" -> 2.5;
            case "C"  -> 2.0;
            case "D"  -> 1.0;
            default   -> 0.0; // F
        };
    }

    private static long rand(GradeRecord gr, int idx) {
        return Math.abs(Objects.hash(gr.getUserId(), gr.getYear(), gr.getSemester(), idx));
    }

    private static double rand01(GradeRecord gr, int idx) {
        long x = rand(gr, idx);
        return (x % 10_000) / 10_000.0; // [0, 1)
    }

    private static double round(double v, int s) {
        double p = Math.pow(10, s);
        return Math.round(v * p) / p;
    }
}
