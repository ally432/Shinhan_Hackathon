package com.example.demo.user;

import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface DepositContractMinRepository extends JpaRepository<DepositContractMin, Long> {
	boolean existsByEmailAndOpenedDateAndMaturityDate(String email, LocalDate openedDate, LocalDate maturityDate);

	Optional<DepositContractMin> findByEmailAndMaturityDate(String email, LocalDate maturityDate);

// ⬇️ auto 쪽에 있던 메서드도 여기로 합칩니다
	boolean existsByMaturityDate(LocalDate maturityDate);

	List<DepositContractMin> findByMaturityDate(LocalDate maturityDate);
}
