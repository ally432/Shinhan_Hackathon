package com.example.demo.user;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DepositInfoRepository extends JpaRepository<DepositInfo, String> {
 Optional<DepositInfo> findByUserKeyAndAccountNo(String userKey, String accountNo);
}
