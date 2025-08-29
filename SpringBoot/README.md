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

### 5.2 checking\_account

| 컬럼명            | 타입          | PK | 설명                    |
| -------------- | ----------- | -- | --------------------- |
| account\_no    | VARCHAR(16) | ✅  | 계좌 번호 (PK)            |
| user\_key      | VARCHAR(60) |    | UserInfo.user\_key 참조 |
| bank\_code     | VARCHAR(3)  |    | 은행 코드                 |
| balance        | BIGINT      |    | 잔액                    |
| currency       | VARCHAR(6)  |    | 통화 코드 (예: KRW, USD)   |
| currency\_name | VARCHAR(16) |    | 통화 이름 (예: 원화, 달러)     |

* **Unique**: (user\_key, account\_no)
* **Index**: bank\_code

### 5.3 deposit\_info

| 컬럼명                     | 타입          | PK | 설명                    |
| ----------------------- | ----------- | -- | --------------------- |
| account\_no             | VARCHAR(16) | ✅  | 계좌 번호 (PK)            |
| user\_key               | VARCHAR(60) |    | UserInfo.user\_key 참조 |
| bank\_code              | VARCHAR(3)  |    | 은행 코드                 |
| bank\_name              | VARCHAR(20) |    | 은행 이름                 |
| account\_name           | VARCHAR(20) |    | 계좌 이름                 |
| withdrawal\_bank\_code  | VARCHAR(3)  |    | 출금 은행 코드              |
| withdrawal\_account\_no | VARCHAR(16) |    | 출금 계좌 번호              |
| subscription\_period    | VARCHAR(20) |    | 가입 기간 (예: 12M, 1Y)    |
| deposit\_balance        | BIGINT      |    | 예치 잔액                 |
| interest\_rate          | DOUBLE      |    | 금리                    |
| account\_create\_date   | VARCHAR(8)  |    | 계좌 개설일 (YYYYMMDD)     |
| account\_expiry\_date   | VARCHAR(8)  |    | 계좌 만기일 (YYYYMMDD)     |
| goal\_score             | VARCHAR(3)  |    | 목표 점수                 |

* **Unique**: (user\_key, account\_no)
* **Index**: bank\_code, withdrawal\_bank\_code

### 5.4 grade\_record

| 컬럼명            | 타입          | PK | 설명                      |
| -------------- | ----------- | -- | ----------------------- |
| id             | BIGINT      | ✅  | 고유 식별자 (자동 증가)          |
| user\_id       | VARCHAR(40) |    | 사용자 식별자 (user\_info 참조) |
| total\_credits | INT         |    | 총 이수 학점                 |
| total\_gpa     | DOUBLE      |    | 총 평점 평균                 |
| year           | INT         |    | 년도                      |
| semester       | INT         |    | 학기 (1: 1학기, 2: 2학기)     |
| type           | VARCHAR(10) |    | 구분 (전공/교양 등)            |

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

* ✅ 사용자 데이터 추가
* ✅ 목표 성적 DB 데이터 앱에 잘 가져와지지 않는 문제 해결 

---
