package com.example.demo.user;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GradeRecordRepository extends JpaRepository<GradeRecord, Long> {
  Optional<GradeRecord> findByUserIdAndYearAndSemester(String userId, Integer year, Integer semester);
}
