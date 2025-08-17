📌 Backend README
1) 환경 / 툴 버전

STS: 4.31.0

JDK: 24

Lombok: 1.18.38

MySQL: 8.0.43

빌드 도구: Gradle (Spring Boot 3.5.x)

2) 설치 상태

✅ Spring Boot 설치 완료

✅ MySQL 설치 완료

✅ Spring Boot – MySQL 연동 완료 (JPA/Hibernate, HikariCP)

3) DB 설계 & API 설계
개요

✅ API KEY 발급 완료

✅ 계정 생성 API 연동 및 응답 수신

✅ DB 설계 완료 (user_info, grade_record, subject_grade)

✅ 계정 DB 저장 플로우 완료 (외부 API → DTO 매핑 → UserInfo 저장)

✅ 계정 생성 API Flutter ↔ Spring Boot 연동

✅ 로그인 구현 및 Flutter ↔ Spring Boot 연동

✅ 자동 로그인 기능 (SharedPreferences) 적용

✅ 유저 DB 자동 생성기능 추가

<img width="917" height="98" alt="ERD" src="https://github.com/user-attachments/assets/4ab2755c-e094-4a66-aaba-56ab20a0af49" />
4) 스키마(ERD 요약)
UserInfo (user_id PK)
   1 ── 1  GradeRecord (user_id PK, FK->user_info.user_id)
                 1 ── *  SubjectGrade (id PK, FK->grade_record.user_id)

5) 테이블 명세
5.1 user_info
컬럼명	타입	PK	설명
user_id	VARCHAR(40)	✅	외부 시스템 사용자 식별자
username	VARCHAR(10)		사용자 표시명
institution_code	VARCHAR(40)		기관 코드
user_key	VARCHAR(60)		외부 API 발급 userKey
created	DATETIME		생성일시
modified	DATETIME		수정일시
5.2 grade_record
컬럼명	타입	PK	설명
user_id	VARCHAR(40)	✅	UserInfo FK
total_credits	INT		취득학점
total_gpa	DOUBLE		취득평점
year	INT		연도 (예: 2025)
semester	INT		학기 (1 or 2)
type	VARCHAR(10)		성적 유형
5.3 subject_grade
컬럼명	타입	PK	설명
id	BIGINT	✅	PK
subject_name	VARCHAR(50)		과목명
credit	DOUBLE		학점
grade	VARCHAR(10)		등급
score	DOUBLE		평점
grade_record_user_id	VARCHAR(40)		grade_record.user_id 참조
6) API 연동

앱 API KEY 발급

사용자 계정 생성

7) 실행 전 준비

MySQL에서 test 스키마 생성

application.yml 또는 application.properties DB 연결 정보 수정

Spring Boot 실행

./gradlew bootRun


오늘 작업한 내용

✅ 계정 생성 API Flutter ↔ Spring Boot 연동

✅ 로그인 구현 및 Flutter ↔ Spring Boot 연동

✅ 자동 로그인 기능 (SharedPreferences) 적용

✅ 유저 DB 자동 생성기능 추가