package com.example.demo.user;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Configuration
@Profile("seed")
@RequiredArgsConstructor
public class DepositContractSeeder {

 private final DepositContractMinRepository repo;

 private static final LocalDate OPENED = LocalDate.of(2025, 8, 28);
 private static final LocalDate MATURITY = LocalDate.of(2025, 8, 30);

 // 이메일 + 금액(만원)
 private static final List<String[]> RAW = List.of(
     new String[]{"skyblue927@gmail.com", "200만원", "1"},
     new String[]{"green.stone21@gmail.com", "500만원", "1"},
     new String[]{"windrunner83@naver.com", "1000만원", "1"},
     new String[]{"cocoa_latte7@naver.com", "200만원", "1"},
     new String[]{"mintnova90@naver.com", "150만원", "1"},

     new String[]{"brightmoon02@daum.net", "100만원", "2"},
     new String[]{"silverline88@daum.net", "1000만원", "1"},
     new String[]{"nightowl710@hanmail.net", "500만원", "1"},
     new String[]{"softwave33@hanmail.net", "300만원", "2"},
     new String[]{"pixel.note14@outlook.com", "8000만원", "1"},
     new String[]{"coralleaf99@outlook.com", "150만원", "1"},
     new String[]{"duskcloud17@hotmail.com", "50만원", "2"},
     new String[]{"oceantrail58@yahoo.com", "200만원", "2"},
     new String[]{"maplepath73@nate.com", "200만원", "1"},
     new String[]{"cloudbook12@icloud.com", "5000만원", "2"},
     new String[]{"surf61@ssafy.com", "500만원", "1"},
     new String[]{"pineorbit07@ssafy.com", "2000만원", "2"},
     new String[]{"velvet.stream29@ssafy.com", "200만원", "2"},
     new String[]{"Shin@ssafy.com", "500만원", "1"}
 );

 @Configuration
 static class RunnerConfig {
     @Profile("seed")
     @org.springframework.context.annotation.Bean
     CommandLineRunner seedRunner(DepositContractSeeder seeder) {
         return args -> seeder.seed();
     }
 }

 @Transactional
 public void seed() {
     int inserted = 0, skipped = 0;

     for (String[] row : RAW) {
         String email = row[0];
         long principal = parseManwon(row[1]);
         int mant = Integer.parseInt(row[2]);

         boolean exists = repo.existsByEmailAndOpenedDateAndMaturityDate(email, OPENED, MATURITY);
         if (exists) { skipped++; continue; }

         DepositContractMin e = new DepositContractMin();
         e.setEmail(email);
         e.setPrincipalKrw(principal);
         e.setMaturity(mant);
         e.setOpenedDate(OPENED);
         e.setMaturityDate(MATURITY);
         repo.save(e);
         inserted++;
     }

     System.out.printf("[SEED] deposit_contract_min inserted=%d, skipped=%d%n", inserted, skipped);
 }

 private long parseManwon(String txt) {
     // "200만원" → 200 * 10,000
     String digits = txt.replaceAll("[^0-9]", "");
     long man = Long.parseLong(digits);
     return man * 10_000L;
 }
}
