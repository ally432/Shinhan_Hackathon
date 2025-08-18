package com.example.demo.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(
    name = "AccountInfo",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_account_no", columnNames = {"accountNo"})
    },
    indexes = {
        @Index(name = "idx_bank_code", columnList = "bankCode"),
        @Index(name = "idx_withdrawal_bank_code", columnList = "withdrawalBankCode")
    }
)
public class AccountInfo {

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
    private String bankCode;

    @Column(length = 20, nullable = false)
    private String bankName;

    @Column(length = 16, nullable = false)
    private String accountNo;

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

    // 계좌 개설/만기일 (YYYYMMDD 형태라 length=8)
    @Column(length = 8, nullable = false)
    private String accountCreateDate;

    @Column(length = 8, nullable = false)
    private String accountExpiryDate;
}
