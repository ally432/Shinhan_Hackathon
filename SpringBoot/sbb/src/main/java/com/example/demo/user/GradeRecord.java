package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(
 name = "grade_record",
 uniqueConstraints = {
     @UniqueConstraint(name = "uk_grade_user_term", columnNames = {"userId", "year", "semester"})
 }
)
@Getter @Setter
public class GradeRecord {

 @Id
 @GeneratedValue(strategy = GenerationType.IDENTITY)
 private Long id;

 @Column(length = 40, nullable = false)
 private String userId;

 private Integer totalCredits;   // 총 이수학점(임의값)
 private Double totalGpa;        // GPA (0.0 ~ 4.5 랜덤)

 private Integer year;           // 2024, 2025
 private Integer semester;       // 1, 2

 @Column(length = 10)
 private String type;            // 예: "전공"
 
 // 🔥 SubjectGrade 제거에 따라 @OneToMany subjects 필드 삭제
}
