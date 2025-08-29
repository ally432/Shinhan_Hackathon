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

	// 기존 9명 + 신규 19명 = 28명
	private static final List<String> USER_IDS = List.of(
			// 기존
			"123456@ssafy.com", "asdadsd111111@asdsdsad.com", "asdadsd12121@asdsdsad.com", "asdadsd5466@asdsdsad.com",
			"dfjsioejfemfkl@ssafy.com", "sdjfkslaj@ssafy.com", "ssafy12345687@ssafy.com",
			"ssafy51521451451458476697@ssafy.com", "ssafy75484566586@ssafy.com",

			// 신규 19명
			"skyblue927@gmail.com", "green.stone21@gmail.com", "windrunner83@naver.com", "cocoa_latte7@naver.com",
			"mintnova90@naver.com", "brightmoon02@daum.net", "silverline88@daum.net", "nightowl710@hanmail.net",
			"softwave33@hanmail.net", "pixel.note14@outlook.com", "coralleaf99@outlook.com", "duskcloud17@hotmail.com",
			"oceantrail58@yahoo.com", "maplepath73@nate.com", "cloudbook12@icloud.com", "surf61@ssafy.com",
			"pineorbit07@ssafy.com", "velvet.stream29@ssafy.com", "Shin@ssafy.com",

			"swiftpeak64@icloud.com", "lemonriver27@ssafy.com", "stonebridge46@ssafy.com", "orchidwave82@gmail.com",
			"bluehorizon24@naver.com");

	// 이번에 생성할 학기
	private static final int[][] TERMS = new int[][] { { 2025, 1 }, // 목표의 1학기
			{ 2024, 2 } // 목표의 2학기
	};

	// 🔒 사용자/학기별 고정 GPA 테이블 (키: "yyyy-s")
	// 배분: 6명(둘다 달성) / 6명(하나만) / 7명(둘다 미달)
	private static final Map<String, Map<String, Double>> FIXED_GPA = Map.ofEntries(
			// ====== 기존 9명 유지 ======
			entry("123456@ssafy.com", Map.of("2025-1", 3.92, "2024-2", 3.78)),
			entry("asdadsd111111@asdsdsad.com", Map.of("2025-1", 4.50, "2024-2", 3.45)),
			entry("asdadsd12121@asdsdsad.com", Map.of("2025-1", 3.05, "2024-2", 4.29)),
			entry("asdadsd5466@asdsdsad.com", Map.of("2025-1", 3.78, "2024-2", 4.19)),
			entry("dfjsioejfemfkl@ssafy.com", Map.of("2025-1", 3.88, "2024-2", 3.34)),
			entry("sdjfkslaj@ssafy.com", Map.of("2025-1", 4.21, "2024-2", 3.09)),
			entry("ssafy12345687@ssafy.com", Map.of("2025-1", 3.73, "2024-2", 3.56)),
			entry("ssafy51521451451458476697@ssafy.com", Map.of("2025-1", 3.49, "2024-2", 3.14)),
			entry("ssafy75484566586@ssafy.com", Map.of("2025-1", 3.84, "2024-2", 3.26)),

			// ====== 신규 19명 ======
			// --- [둘 다 달성] 6명 ---
			// 목표(4.0,4.3) → (4.02,4.30)
			entry("skyblue927@gmail.com", Map.of("2025-1", 4.02, "2024-2", 4.30)),
			// 목표(4.3,4.0) → (4.30,4.05)
			entry("windrunner83@naver.com", Map.of("2025-1", 4.30, "2024-2", 4.05)),
			// 목표(4.3,4.3) → (4.30,4.30)
			entry("silverline88@daum.net", Map.of("2025-1", 4.30, "2024-2", 4.30)),
			// 목표(4.3,4.0) → (4.31,4.02)
			entry("pixel.note14@outlook.com", Map.of("2025-1", 4.31, "2024-2", 4.02)),
			// 목표(4.0,4.3) → (4.00,4.30)
			entry("surf61@ssafy.com", Map.of("2025-1", 4.00, "2024-2", 4.30)),
			// 목표(4.3,4.3) → (4.35,4.34)
			entry("Shin@ssafy.com", Map.of("2025-1", 4.35, "2024-2", 4.34)),

			// --- [하나만 달성] 6명 ---
			// 목표(3.7,4.0) → (3.70,3.98) // 1학기만 달성
			entry("green.stone21@gmail.com", Map.of("2025-1", 3.70, "2024-2", 3.98)),
			// 목표(4.0,4.0) → (4.00,3.98) // 1학기만 달성
			entry("cocoa_latte7@naver.com", Map.of("2025-1", 4.00, "2024-2", 3.98)),
			// 목표(4.3,3.7) → (4.28,3.70) // 2학기만 달성(프론프엔드 동일 데이터)
			entry("mintnova90@naver.com", Map.of("2025-1", 4.10, "2024-2", 3.70)),
			// 목표(4.0,4.3) → (4.00,4.28) // 1학기만 달성(프론트엔드 동일 데이터)
			entry("nightowl710@hanmail.net", Map.of("2025-1", 4.10, "2024-2", 4.28)),
			// 목표(4.0,3.7) → (3.98,3.70) // 2학기만 달성
			entry("coralleaf99@outlook.com", Map.of("2025-1", 3.98, "2024-2", 3.70)),
			// 목표(3.7,4.3) → (3.70,4.28) // 1학기만 달성
			entry("maplepath73@nate.com", Map.of("2025-1", 3.70, "2024-2", 4.28)),

			// --- [둘 다 미달] 7명 ---
			// 목표(3.7,4.0) → (3.69,3.98)
			entry("brightmoon02@daum.net", Map.of("2025-1", 3.69, "2024-2", 3.98)),
			// 목표(3.7,3.7) → (3.69,3.69)
			entry("softwave33@hanmail.net", Map.of("2025-1", 3.69, "2024-2", 3.69)),
			// 목표(4.3,3.7) → (4.28,3.69)
			entry("duskcloud17@hotmail.com", Map.of("2025-1", 4.28, "2024-2", 3.69)),
			// 목표(4.0,4.0) → (3.98,3.98)
			entry("oceantrail58@yahoo.com", Map.of("2025-1", 3.98, "2024-2", 3.98)),
			// 목표(3.7,4.3) → (3.69,4.28) // 2학기도 미달(4.28 < 4.30)
			entry("cloudbook12@icloud.com", Map.of("2025-1", 3.69, "2024-2", 4.28)),
			// 목표(3.7,3.7) → (3.60,3.60)
			entry("pineorbit07@ssafy.com", Map.of("2025-1", 3.60, "2024-2", 3.60)),
			// 목표(4.0,3.7) → (3.98,3.69)
			entry("velvet.stream29@ssafy.com", Map.of("2025-1", 3.98, "2024-2", 3.69)),

			// ... 기존 FIXED_GPA Map.ofEntries( ... ) 안에 아래 5개 entry 추가

			// 목표(4.0, 4.3) → 둘 다 달성 (4.01, 4.30)
			entry("swiftpeak64@icloud.com", Map.of("2025-1", 4.01, "2024-2", 4.30)),
			// 목표(4.3, 4.3) → 둘 다 달성 (4.30, 4.32)
			entry("lemonriver27@ssafy.com", Map.of("2025-1", 4.30, "2024-2", 4.32)),
			// 목표(3.7, 4.3) → 둘 다 미달 (3.69, 4.28)
			entry("stonebridge46@ssafy.com", Map.of("2025-1", 3.69, "2024-2", 4.28)),
			// 목표(3.7, 4.0) → 1학기만 달성 (3.70, 3.98)
			entry("orchidwave82@gmail.com", Map.of("2025-1", 3.70, "2024-2", 3.98)),
			// 목표(4.0, 4.3) → 2학기만 달성 (3.98, 4.30)
			entry("bluehorizon24@naver.com", Map.of("2025-1", 3.98, "2024-2", 4.30))

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
				int sem = term[1];

				if (gradeRepo.findByUserIdAndYearAndSemester(userId, year, sem).isPresent()) {
					continue;
				}

				GradeRecord gr = new GradeRecord();
				gr.setUserId(trunc(userId, 40));
				gr.setYear(year);
				gr.setSemester(sem);
				gr.setTotalCredits(sem == 1 ? 18 : 15); // 간단 고정
				gr.setTotalGpa(gpaFor(userId, year, sem)); // 위 FIXED_GPA 적용 (없으면 3.33)
				gr.setType("전공");

				gradeRepo.save(gr);
			}
		}
	}

	private static double gpaFor(String userId, int year, int sem) {
		String key = year + "-" + sem; // "2025-1" 등
		return FIXED_GPA.getOrDefault(userId, Map.of()).getOrDefault(key, 3.33);
	}

	private static String trunc(String s, int max) {
		if (s == null)
			return null;
		return s.length() > max ? s.substring(0, max) : s;
	}
}
