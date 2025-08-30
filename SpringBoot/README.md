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
* ✅ 유저 DB 씨드 데이터 **자동 생성기능 추가**
* ✅ 예금 상품 등록
* ✅ 계좌가입정보 DB 추가 생성
* ✅ 수시입출금 상품 등록
* ✅ 수시입출금 계좌 생성 테스트 완료
* ✅ 수시입출금 입금 테스트 완료
* ✅ 예금 계좌 생성 테스트 완료
* ✅ DB 개선
* ✅ 성적 DB 수정(grade\_record, subject\_grade)
* ✅ 성적 씨드 데이터 생성
* ✅ 앱 로그아웃 적용
* ✅ 서버 연동 로그인(userKey 저장) 수정
* ✅ 수시입출금 계좌 개설 앱 연동
* ✅ 수시입출금 계좌 목록 조회 API 연동
* ✅ 조회 결과로 계좌 유무 판단
* ✅ 시험보험 가입 화면에서 계좌번호 및 잔액 동적 표시 구현
* ✅ DB업데이트
* ✅ 수시입출금 자동 입금 구현
* ✅ 본인 명의 계좌 계좌 조회(단건)를 통한 구현 및 연동
* ✅ 테스트를 위한 임시 예금 상품 등록
* ✅ 예금 계좌 생성 기능 앱과 연동
* ✅ 예금/성적 스키마 및 시더 업데이트
* ✅ 예금·입출금 계좌 목록/상세 조회 및 만기 이자율 조회,
* ✅ 예금 해지 API와 앱 연동
* ✅ 앱 내 중도 해지 이자 계산
* ✅ 예금 상품 존재 시 홈 이동 로직 구현
* ✅ 예금 상품 추가 등록
* ✅ 코드 오류 수정
* ✅ 테스트 용 계정 생성 및 수시 입출금·예금 계좌 생성
* ✅ 목표 성적 DB 생성 및 자동 저장 기능 구축
* ✅ 목표 성정 및 성적 비교 수정
* ✅ 사용자 데이터 추가
* ✅ 목표 성적 DB 데이터 앱에 잘 가져와지지 않는 문제 해결 

---

## 4) 스키마 (ERD 요약)

```
USER_INFO (user_id PK, user_key)
   ├─ 1:N ── CHECKING_ACCOUNT  (user_key FK → user_info.user_key)
   ├─ 1:N ── GRADE_RECORD      (user_id FK → user_info.user_id)
   └─ 1:1 ── TARGET_SCORE      (user_key UQ(FK) → user_info.user_key)
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

### 5.2 checking\_account

| 컬럼명            | 타입          | PK | 설명                              |
| -------------- | ----------- | -- | ------------------------------- |
| account\_no    | VARCHAR(16) | ✅  | 계좌 번호                           |
| user\_key      | VARCHAR(60) |    | 사용자 키 (`user_info.user_key` 참조) |
| bank\_code     | VARCHAR(3)  |    | 은행 코드                           |
| balance        | BIGINT      |    | 잔액                              |
| currency       | VARCHAR(6)  |    | 통화 코드 (예: KRW, USD, EUR)        |
| currency\_name | VARCHAR(16) |    | 통화 이름 (예: 원화, 달러, 유로)           |


### 5.3 grade\_record

| 컬럼명            | 타입          | PK | 설명                    |
| -------------- | ----------- | -- | --------------------- |
| id             | BIGINT      | ✅  | PK, 자동 증가(ID ENTITY)  |
| user\_id       | VARCHAR(40) |    | 사용자 식별자               |
| total\_credits | INT         |    | 총 이수학점                |
| total\_gpa     | DOUBLE      |    | 평균평점(GPA, 예: 0.0–4.5) |
| year           | INT         |    | 연도(예: 2024, 2025)     |
| semester       | INT         |    | 학기(1, 2)              |
| type           | VARCHAR(10) |    | 구분(예: ‘전공’)           |

### 5.4 target\_score

| 컬럼명         | 타입           | PK | 설명                   |
| ----------- | ------------ | -- | -------------------- |
| id          | BIGINT       | ✅  | PK, 자동 증가(ID)        |
| user\_key   | VARCHAR(60)  | UQ | 사용자 키(외부 API 발급)     |
| goal\_sem1  | DECIMAL(3,2) |    | 1학기 목표 GPA (예: 4.30) |
| goal\_sem2  | DECIMAL(3,2) |    | 2학기 목표 GPA (예: 4.00) |
| created\_at | DATETIME     |    | 생성일시                 |
| updated\_at | DATETIME     |    | 수정일시                 |

### 5.5 deposit_contract_min

| 컬럼명            | 타입           | PK | 설명                                   |
| -------------- | ------------ | -- | ------------------------------------ |
| id             | BIGINT       | ✅  | 계약 고유 식별자                            |
| email          | VARCHAR(120) |    | 사용자 이메일                              |
| principal\_krw | BIGINT       |    | 예금 원금 (원화)                           |
| maturity       | INT          |    | 만기 상태 (0: 만기 아님, 1: 목표 달성, 2: 목표 미달) |
| opened\_date   | DATE         |    | 계좌 개설일                               |
| maturity\_date | DATE         |    | 만기일                                  |
| created\_at    | DATETIME     |    | 생성일시                                 |
| updated\_at    | DATETIME     |    | 수정일시                                 |


---

## 6) API 연동

API KEY 관리 - API KEY 발급

계정관리 - 계정 생성

수시입출금 - 수시입출금 상품등록, 계좌 생성, 계좌 목록 조회, 계좌 조회(단건), 계좌 입금, 계좌거래내역조회

예금 -예금상품등록, 예금상품조회, 예금계좌생성, 예금계좌목록 조회, 예금납입상세조회, 예금만기이자조회, 예금계좌해지

---

## 7) 실행 전 준비

1. MySQL에서 `test` 스키마 생성
2. `application.properties` DB 연결 정보 수정
3. Spring Boot 실행

---
