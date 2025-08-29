package com.example.demo.user;

import com.example.demo.user.TargetScore;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TargetScoreRepository extends JpaRepository<TargetScore, Long> {
    Optional<TargetScore> findByUserKey(String userKey);
}
