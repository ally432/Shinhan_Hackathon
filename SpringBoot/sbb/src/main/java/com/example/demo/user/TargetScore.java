package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "target_score",
    uniqueConstraints = @UniqueConstraint(name = "uk_target_score_userkey", columnNames = "user_key")
)
@Getter @Setter
public class TargetScore {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_key", length = 60, nullable = false)
    private String userKey;

    @Column(name = "goal_sem1", precision = 4, scale = 2)  // 예: 4.50, 95.00 등
    private BigDecimal goalSem1;

    @Column(name = "goal_sem2", precision = 4, scale = 2)
    private BigDecimal goalSem2;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
