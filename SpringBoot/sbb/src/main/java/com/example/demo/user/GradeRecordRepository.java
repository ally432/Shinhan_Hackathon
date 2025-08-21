package com.example.demo.user;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface GradeRecordRepository extends JpaRepository<GradeRecord, Long> {
    Optional<GradeRecord> findByUserIdAndYearAndSemester(String userId, Integer year, Integer semester);
}
