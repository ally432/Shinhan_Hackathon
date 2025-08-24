package com.example.demo.user;

import org.springframework.data.jpa.repository.JpaRepository;

public interface SubjectGradeRepository extends JpaRepository<SubjectGrade, Long> {
    long countByGradeRecordId(Long gradeRecordId);
}
