# Backend 진행 문서

## 1) 환경 / 툴 버전

* **STS**: 4.31.0
* **JDK**: 24
* **Lombok**: 1.18.38
* **MySQL**: 8.0.43
* **빌드 도구**: Gradle (Spring Boot 3.5.x)

---

## 2) 설치 상태

* ✅ 스프링부트 설치 완료
* ✅ MySQL 설치 완료
* ✅ 스프링부트–MySQL 연동 완료 (JPA/Hibernate, HikariCP)

---

## 3) DB 설계 & API 설계

### 개요

* ✅ **API KEY 발급 완료**
* ✅ **계정 생성 API 연동** 및 응답 수신
* ✅ **DB 설계**: `user_info`, `grade_record`, `subject_grade`
* ✅ **계정 DB 저장 플로우 완료** (외부 API → DTO 매핑 → UserInfo 저장)
![alt text](image.png)

---

## 4) 스키마(ERD 요약)

```
UserInfo (user_id PK)
   1 ── 1  GradeRecord (user_id PK, FK->user_info.user_id)
                 1 ── *  SubjectGrade (id PK, FK->grade_record.user_id)
```

---

## 5) 테이블 명세

### 5.1 user\_info

| 컬럼명               |       타입 | 길이 |  PK |  NN | Unique | 설명                     |
| ----------------- | -------: | -: | :-: | :-: | :----: | ---------------------- |
| user\_id          |  VARCHAR | 40 |  ✅  |  ✅  |        | 외부 시스템의 사용자 식별자(이메일 등) |
| username          |  VARCHAR | 10 |     |  ✅  |        | 사용자 표시명                |
| institution\_code |  VARCHAR | 40 |     |  ✅  |        | 기관 코드                  |
| user\_key         |  VARCHAR | 60 |     |  ✅  |        | 외부 API에서 발급된 userKey   |
| created           | DATETIME |    |     |  ✅  |        | 생성일시 (API 응답 기반)       |
| modified          | DATETIME |    |     |  ✅  |        | 수정일시 (API 응답 기반)       |

> JPA: `@Entity UserInfo` (PK: `userId`)

---

### 5.2 grade\_record

| 컬럼명            |      타입 | 길이 |  PK |  NN | 설명                    |
| -------------- | ------: | -: | :-: | :-: | --------------------- |
| user\_id       | VARCHAR | 40 |  ✅  |  ✅  | UserInfo와 1:1 매핑 (FK) |
| total\_credits |     INT |    |     |     | 취득학점                  |
| total\_gpa     |  DOUBLE |    |     |     | 취득평점                  |
| year           |     INT |    |     |     | 연도 (예: 2025)          |
| semester       |     INT |    |     |     | 학기 (1 or 2)           |
| type           | VARCHAR | 10 |     |     | 성적 유형                 |

> JPA: `@Entity GradeRecord`
> 관계: `@OneToOne UserInfo` (동일 `userId`), `@OneToMany List<SubjectGrade> subjects`

---

### 5.3 subject\_grade

| 컬럼명                     |      타입 | 길이 |  PK |  NN | 설명                        |
| ----------------------- | ------: | -: | :-: | :-: | ------------------------- |
| id                      |  BIGINT |    |  ✅  |  ✅  | 과목 성적 PK                  |
| subject\_name           | VARCHAR | 50 |     |  ✅  | 과목명                       |
| credit                  |  DOUBLE |    |     |     | 학점                        |
| grade                   | VARCHAR | 10 |     |     | 등급                        |
| score                   |  DOUBLE |    |     |     | 평점                        |
| grade\_record\_user\_id | VARCHAR | 40 |     |  ✅  | `grade_record.user_id` 참조 |

> JPA: `@Entity SubjectGrade`
> 관계: `@ManyToOne GradeRecord` (`@JoinColumn(name="grade_record_userId")`)

---

## 6) API 연동

### 사용 API

* **앱 API KEY 발급**
* **사용자 계정 생성**

---

## 7) 애플리케이션 플로우

1. 사용자가 `/user/signup` 화면에서 **이메일** 입력 후 제출
2. 서버는 `POST /user/signup` 처리 후 → `redirect:/signup/success?email=...`
3. `GET /signup/success`

   * 외부 API `/member` 호출 (apiKey + email)
   * 응답 DTO 매핑 → `UserInfo` 엔티티로 저장
   * 저장 결과를 화면(텍스트)로 간단 출력

---
