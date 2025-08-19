package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Entity
public class GradeRecord {

    @Id
    @Column(length = 40, nullable = false)
    private String userId;  // Primary Key, UserInfo의 PK와 동일

    @OneToOne
    @JoinColumn(name = "userId", referencedColumnName = "userId", insertable = false, updatable = false)
    private UserInfo userInfo;

    // 전체 성적
    private Integer totalCredits;
    private Double totalGpa;

    // 년도
    private Integer year;

    // 학기
    private Integer semester;

    @Column(length = 10)
    private String type;

    // 과목 정보
    @OneToMany(mappedBy = "gradeRecord", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SubjectGrade> subjects;
}

