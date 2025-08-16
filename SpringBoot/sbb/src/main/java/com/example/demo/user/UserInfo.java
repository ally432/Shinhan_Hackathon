package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
public class UserInfo {

    @Id
    @Column(length = 40, nullable = false)
    private String userId;  // Primary Key

    @Column(length = 10, nullable = false)
    private String username;

    @Column(length = 40, nullable = false)
    private String institutionCode;

    @Column(length = 60, nullable = false)
    private String userKey;

    @Column(nullable = false)
    private LocalDateTime created;

    @Column(nullable = false)
    private LocalDateTime modified;
}
