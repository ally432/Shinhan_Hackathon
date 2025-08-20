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
        @UniqueConstraint(name = "uk_account_user", columnNames = {"userKey", "accountNo"})
    },
    indexes = {
        @Index(name = "idx_bank_code", columnList = "bankCode")
    }
)
public class CheckingAccount {

    @Id
    @Column(length = 16, nullable = false)
    private String accountNo;  // PK 계좌 번호

    @Column(length = 60, nullable = false)
    private String userKey;    // UserInfo와 매핑되는 사용자 키

    @ManyToOne
    @JoinColumn(
        name = "userKey",
        referencedColumnName = "userKey",
        insertable = false,
        updatable = false
    )
    private UserInfo userInfo;

    @Column(length = 3, nullable = false)
    private String bankCode;   // 은행 코드

    @Column(nullable = false)
    private Long balance;      // 잔액

    @Column(length = 6, nullable = false)
    private String currency;   // 통화 코드 (예: KRW, USD, EUR)

    @Column(length = 16, nullable = false)
    private String currencyName;  // 통화 이름 (예: 원화, 달러, 유로)
}
