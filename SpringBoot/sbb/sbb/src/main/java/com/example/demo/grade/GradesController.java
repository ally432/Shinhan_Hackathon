package com.example.demo.grade;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.signup.UserInfoService;
import com.example.demo.user.GradeRecord;
import com.example.demo.user.GradeRecordRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/grades")
@RequiredArgsConstructor
public class GradesController {

  private final GradeRecordRepository repo;
  private final UserInfoService userInfoService;

  /** 개별 학기 조회 */
  @GetMapping("/record")
  public ResponseEntity<?> getRecord(
      @RequestParam("userKey") String userKey,
      @RequestParam("year") int year,
      @RequestParam("semester") int semester) {

    if (semester != 1 && semester != 2) {
      return ResponseEntity.badRequest().body(Map.of("message", "semester must be 1 or 2"));
    }

    final String userId = userInfoService.findUserIdByUserKey(userKey);
    if (userId == null) {
      return ResponseEntity.status(404).body(Map.of("message", "user not found"));
    }

    return repo.findByUserIdAndYearAndSemester(userId, year, semester)
        .<ResponseEntity<?>>map(gr -> ResponseEntity.ok(Map.of("record", gr)))
        .orElseGet(() -> ResponseEntity.status(404).body(Map.of("message", "no record")));
  }

  /** 최근 2개 학기 한번에 (원하면 사용) */
  @GetMapping("/recent")
  public ResponseEntity<?> getRecentTwo(@RequestParam("userKey") String userKey) {
        final String userId = userInfoService.findUserIdByUserKey(userKey);
        if (userId == null) {
            return ResponseEntity.status(404).body(Map.of("message", "user not found"));
        }

        LocalDate now = LocalDate.now();
        Term[] terms = recentTerms(now);

        Optional<GradeRecord> r1 = repo.findByUserIdAndYearAndSemester(userId, terms[0].year, terms[0].semester);
        Optional<GradeRecord> r2 = repo.findByUserIdAndYearAndSemester(userId, terms[1].year, terms[1].semester);

        return ResponseEntity.ok(Map.of(
            "now", now.toString(),
            "terms", List.of(
                Map.of("year", terms[0].year, "semester", terms[0].semester, "record", r1.orElse(null)),
                Map.of("year", terms[1].year, "semester", terms[1].semester, "record", r2.orElse(null))
            )
        ));
    }

    // ---- helpers ----
    private static Term[] recentTerms(LocalDate now) {
        int y = now.getYear();
        int m = now.getMonthValue();
        if (m <= 2) return new Term[]{ new Term(y - 1, 2), new Term(y - 1, 1) };
        if (m <= 8) return new Term[]{ new Term(y, 1),     new Term(y - 1, 2) };
        return           new Term[]{ new Term(y, 2),     new Term(y, 1) };
    }

    private static final class Term {
        final int year;
        final int semester;
        Term(int year, int semester) { this.year = year; this.semester = semester; }
    }
}
