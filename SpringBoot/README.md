# 📌 Backend README

## 1) 환경 / 툴 버전

* **STS**: 4.31.0
* **JDK**: 24
* **Lombok**: 1.18.38
* **MySQL**: 8.0.43
* **빌드 도구**: Gradle (Spring Boot 3.5.x)

---

## 2) 설치 상태

* ✅ Spring Boot 설치 완료
* ✅ MySQL 설치 완료
* ✅ Spring Boot – MySQL 연동 완료 (JPA/Hibernate, HikariCP)

---

## 3) DB 설계 & API 설계

### 개요

* ✅ API KEY 발급 완료
* ✅ 계정 생성 API 연동 및 응답 수신
* ✅ DB 설계 완료 (`user_info`, `grade_record`, `subject_grade`)
* ✅ 계정 DB 저장 플로우 완료 (외부 API → DTO 매핑 → UserInfo 저장)
* ✅ 계정 생성 API **Flutter ↔ Spring Boot 연동**
* ✅ 로그인 구현 및 **Flutter ↔ Spring Boot 연동**
* ✅ 자동 로그인 기능 (**SharedPreferences**) 적용
* ✅ 유저 DB **자동 생성기능 추가**
* ✅ 예금 상품 등록
* ✅ 계좌가입정보 DB 추가 생성
* ✅ 수시입출금 상품 등록
* ✅ 수시입출금 계좌 생성 테스트 완료

---

## 4) 스키마 (ERD 요약)

```
UserInfo (user_id PK)
   1 ── 1  GradeRecord (user_id PK, FK -> user_info.user_id)
                 1 ── *  SubjectGrade (id PK, FK -> grade_record.user_id)
```

---

## 5) 테이블 명세

### 5.1 user\_info

| 컬럼명               | 타입          | PK | 설명                |
| ----------------- | ----------- | -- | ----------------- |
| user\_id          | VARCHAR(40) | ✅  | 외부 시스템 사용자 식별자    |
| username          | VARCHAR(10) |    | 사용자 표시명           |
| institution\_code | VARCHAR(40) |    | 기관 코드             |
| user\_key         | VARCHAR(60) |    | 외부 API 발급 userKey |
| created           | DATETIME    |    | 생성일시              |
| modified          | DATETIME    |    | 수정일시              |

### 5.2 grade\_record

| 컬럼명            | 타입          | PK | 설명           |
| -------------- | ----------- | -- | ------------ |
| user\_id       | VARCHAR(40) | ✅  | UserInfo FK  |
| total\_credits | INT         |    | 취득학점         |
| total\_gpa     | DOUBLE      |    | 취득평점         |
| year           | INT         |    | 연도 (예: 2025) |
| semester       | INT         |    | 학기 (1 or 2)  |
| type           | VARCHAR(10) |    | 성적 유형        |

### 5.3 subject\_grade

| 컬럼명                     | 타입          | PK | 설명                        |
| ----------------------- | ----------- | -- | ------------------------- |
| id                      | BIGINT      | ✅  | PK                        |
| subject\_name           | VARCHAR(50) |    | 과목명                       |
| credit                  | DOUBLE      |    | 학점                        |
| grade                   | VARCHAR(10) |    | 등급                        |
| score                   | DOUBLE      |    | 평점                        |
| grade\_record\_user\_id | VARCHAR(40) |    | grade\_record.user\_id 참조 |

좋습니다 👍 원하신 형식(`subject_grade` 테이블 설명처럼 Markdown 테이블로 컬럼·타입·PK·설명`)으로  
`CheckingAccount`과`DepositInfo\` 엔티티에 대한 DB 스키마 요약을 정리해드릴게요.

### 5.4 checking\_account

| 컬럼명            | 타입          | PK | 설명                             |
| -------------- | ----------- | -- | ------------------------------ |
| user\_id       | VARCHAR(40) | ✅  | UserInfo.user\_id 참조, PK (1:1) |
| bank\_code     | VARCHAR(3)  |    | 은행 코드                          |
| account\_no    | VARCHAR(16) |    | 계좌 번호, 유니크 제약                  |
| currency       | VARCHAR(6)  |    | 통화 코드 (예: KRW, USD)            |
| currency\_name | VARCHAR(16) |    | 통화 이름 (예: 원화, 달러, 유로)          |

### 5.4 deposit\_info

| 컬럼명                     | 타입          | PK | 설명                             |
| ----------------------- | ----------- | -- | ------------------------------ |
| user\_id                | VARCHAR(40) | ✅  | UserInfo.user\_id 참조, PK (1:1) |
| bank\_code              | VARCHAR(3)  |    | 은행 코드                          |
| bank\_name              | VARCHAR(20) |    | 은행 이름                          |
| account\_no             | VARCHAR(16) |    | 계좌 번호, 유니크 제약                  |
| account\_name           | VARCHAR(20) |    | 계좌 이름                          |
| withdrawal\_bank\_code  | VARCHAR(3)  |    | 출금 은행 코드                       |
| withdrawal\_account\_no | VARCHAR(16) |    | 출금 계좌 번호                       |
| subscription\_period    | VARCHAR(20) |    | 가입 기간 (예: 12M, 1Y)             |
| deposit\_balance        | BIGINT      |    | 예치 잔액                          |
| interest\_rate          | DOUBLE      |    | 금리                             |
| account\_create\_date   | VARCHAR(8)  |    | 계좌 개설일 (YYYYMMDD)              |
| account\_expiry\_date   | VARCHAR(8)  |    | 계좌 만기일 (YYYYMMDD)              |
| goal\_score             | VARCHAR(3)  |    | 목표 점수 (업무 규칙상 사용)              |

---

## 6) API 연동

* **앱 API KEY 발급**
* **사용자 계정 생성**

---

## 7) 실행 전 준비

1. MySQL에서 `test` 스키마 생성
2. `application.properties` DB 연결 정보 수정
3. Spring Boot 실행

---

## 오늘 작업한 내용

* ✅ 수시입출금 상품 등록 완료
* ✅ 수시입출금 계좌 생성 테스트 완료

---
