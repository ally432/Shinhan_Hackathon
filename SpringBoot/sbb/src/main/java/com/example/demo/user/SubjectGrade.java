package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class SubjectGrade {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;
	@Column(length = 50, nullable = false)
	private String subjectName;
	private Double credit;
	@Column(length = 10)
	private String grade;
	private Double score;
	@ManyToOne
	@JoinColumn(name = "grade_record_id", nullable = false)
	private GradeRecord gradeRecord;
}