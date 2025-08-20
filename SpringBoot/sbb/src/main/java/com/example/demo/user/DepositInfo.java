package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(
    name = "DepositInfo",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_account_user", columnNames = {"userKey", "accountNo"})
    },
    indexes = {
        @Index(name = "idx_bank_code", columnList = "bankCode"),
        @Index(name = "idx_withdrawal_bank_code", columnList = "withdrawalBankCode")
    }
)
public class DepositInfo {

    @Id
    @Column(length = 16, nullable = false)
    private String accountNo;   // PK: 계좌 번호

    @Column(length = 60, nullable = false)
    private String userKey;     // UserInfo와 매핑되는 사용자 키

    @ManyToOne
    @JoinColumn(
        name = "userKey",
        referencedColumnName = "userKey",
        insertable = false,
        updatable = false
    )
    private UserInfo userInfo;

    @Column(length = 3, nullable = false)
    private String bankCode;

    @Column(length = 20, nullable = false)
    private String bankName;

    @Column(length = 20, nullable = false)
    private String accountName;

    @Column(length = 3, nullable = false)
    private String withdrawalBankCode;

    @Column(length = 16, nullable = false)
    private String withdrawalAccountNo;

    @Column(length = 20, nullable = false)
    private String subscriptionPeriod;

    @Column(nullable = false)
    private Long depositBalance;

    @Column(nullable = false)
    private Double interestRate;

    // 계좌 개설/만기일 (YYYYMMDD 형태, 길이=8)
    @Column(length = 8, nullable = false)
    private String accountCreateDate;

    @Column(length = 8, nullable = false)
    private String accountExpiryDate;
    
    @Column(length = 3, nullable = false)
    private String goalScore;
}
