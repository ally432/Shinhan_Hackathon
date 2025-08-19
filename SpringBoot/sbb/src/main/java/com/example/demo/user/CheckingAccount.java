package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(
    name = "CheckingAccount",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_checking_account_no", columnNames = {"accountNo"})
    },
    indexes = {
        @Index(name = "idx_bank_code", columnList = "bankCode")
    }
)
public class CheckingAccount {

    @Id
    @Column(length = 40, nullable = false)
    private String userId;  // PK (UserInfo와 동일 키)

    @OneToOne
    @JoinColumn(
        name = "userId",
        referencedColumnName = "userId",
        insertable = false,
        updatable = false
    )
    private UserInfo userInfo;

    @Column(length = 3, nullable = false)
    private String bankCode;   // 은행 코드

    @Column(length = 16, nullable = false)
    private String accountNo;  // 계좌 번호

    @Column(length = 6, nullable = false)
    private String currency;   // 통화 코드 (예: KRW, USD, EUR 등)

    @Column(length = 16, nullable = false)
    private String currencyName;  // 통화 이름 (예: 원화, 달러, 유로)
}
