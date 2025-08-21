package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

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

    private Integer totalCredits;
    private Double totalGpa;

    private Integer year;
    private Integer semester;

    @Column(length = 10)
    private String type;

    @OneToMany(mappedBy = "gradeRecord", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SubjectGrade> subjects;
}