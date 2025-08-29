package com.example.demo.targetscore;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter @Setter
public class TargetScoreUpsertReq {
    private String userKey;       // 필수
    private BigDecimal goalSem1;  // null 허용 (미설정)
    private BigDecimal goalSem2;  // null 허용
}
