package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
 name = "deposit_contract_min",
 indexes = {
     @Index(name = "idx_maturity", columnList = "maturity_date"),
     @Index(name = "idx_email", columnList = "email")
 }
)
@Getter @Setter
public class DepositContractMin {

 @Id
 @GeneratedValue(strategy = GenerationType.IDENTITY)
 private Long id;

 @Column(length = 120, nullable = false)
 private String email;

 @Column(name = "principal_krw", nullable = false)
 private Long principalKrw;
 
 @Column(name = "maturity", nullable = false)
 private int maturity;

 @Column(name = "opened_date", nullable = false)
 private LocalDate openedDate;

 @Column(name = "maturity_date", nullable = false)
 private LocalDate maturityDate;

 @Column(name = "created_at", nullable = false)
 private LocalDateTime createdAt;

 @Column(name = "updated_at", nullable = false)
 private LocalDateTime updatedAt;


 @PrePersist
 void onCreate() {
     var now = LocalDateTime.now();
     if (createdAt == null) createdAt = now;
     if (updatedAt == null) updatedAt = now;
 }

 @PreUpdate
 void onUpdate() {
     updatedAt = LocalDateTime.now();
 }
}
