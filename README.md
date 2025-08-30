# 2025 신한은행 해커톤


# 시험 보험: 성적 기반 금융 위로 서비스
> **팀명**: 지구가멸망해도밀크티한잔은괜찮잖아  
> **팀장**: 김지윤  
> **팀원**: 김건희, 장유진  
> **기간**: 2025.08.15 ~ 2025.08.31 (해커톤 개발)

---

## 📌 프로젝트 개요
대학생이 스스로 **목표 성적을 설정**하고 **예치금**을 걸어 자신과의 약속을 지키도록 돕는 금융 기반 서비스입니다.  
목표를 달성하면 **우대금리**로 보상하고, 미달 시 **포인트·기프티콘** 등으로 위로를 제공합니다.  
시험이라는 스트레스 요소를 **금융 서비스 + 정서적 보상**으로 긍정적 경험으로 전환합니다.

---

## 🎯 핵심 기능
1. **목표 성적 설정 및 예치**  
   - 학기별 목표 성적(예: 4.0 이상) 설정  
   - 예치금(최소 50만 원) 설정, 신한은행 자유 적립 예금에 예치

2. **시험 결과 검증**  
   - 성적 데이터 불러오기 및 성적 자동 조회·비교

3. **성공 시 보상 / 실패 시 위로**  
   - 목표 달성: 우대금리 적용  
   - 목표 미달: 예치금 일부 환급(2%), 기프티콘·신한 포인트·땡겨요 쿠폰 중 선택

---

## 💡 서비스 차별점
- 대학생 전용 금융 상품으로, **학점**이라는 명확한 지표로 목표 달성 여부 판단
- 금융 서비스가 학업 성취 동기를 부여하는 구조
- 실패 시에도 재도전을 유도하는 보상 설계
- 학업 성취와 금융 경험을 동시에 제공

---

## 🛠 기술 스택
- **프론트엔드**: Flutter (Dart)  
- **백엔드**: Spring Boot (Java)  
- **데이터베이스**: MySQL  
- **API**: 사용자 로그인 API (2.2), 예금 API (2.5)

---

## 👥 역할 분담
| 이름 | 역할 | 주요 업무 |
|------|------|-----------|
| 김지윤 | 프론트엔드(UI/UX, 성적 조회) | 목표 설정 화면, 성적 불러오기, 예금 상품 등록, 성적 데이터 시각화 |
| 김건희 | 백엔드 | 목표 달성 판별, 금리 계산 로직, DB 관리, API 구축 |
| 장유진 | 프론트엔드(계좌/예치금) | 계좌 생성, 예치금 설정, 우대금리 결과 및 보상 안내 화면 구현 |

---

# 프로젝트명

## 개발 환경

### 1. 프론트엔드(Android Studio, Flutter, Emulator)
- **Android Studio 설치**
  
- **Flutter 설치**

- **에뮬레이터 설치 (Samsung S25)**
  - `Android Studio`에서 AVD Manager를 열고, Samsung S25 모델을 선택하여 에뮬레이터를 설정하고 실행합니다.

### 2. 백엔드(Spring Boot, MySQL)
#### 2.1. **Spring Boot 설치**
1. **JDK 설치**  
   Spring Boot는 Java 기반이므로 Java Development Kit (JDK)가 필요합니다.

2. **Spring Boot 설치**  

3. **애플리케이션 설정**
   - `application.properties` 파일 또는 `application.yml` 파일에서 데이터베이스 연결 정보를 설정합니다:
     ```properties
     spring.datasource.url=jdbc:mysql://localhost:3306/your_database_name
     spring.datasource.username=your_database_username
     spring.datasource.password=your_database_password
     spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
     spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
     ```

#### 2.2. **MySQL 설치**
1. **MySQL 설치** 

### 3. 백엔드(Spring Boot 실행)
#### 3.1. **실행**

2. **실행**
   - `sbb-0.0.1-SNAPSHOT.jar` 파일은 `build/libs` 디렉터리에 생성됩니다.
   - 해당 JAR 파일을 실행하여 백엔드 서버를 시작합니다:
     ```bash
     java -jar build/libs/sbb-0.0.1-SNAPSHOT.jar
     ```

3. **서버 확인**
   - 또는 `211.188.50.244:8080`에서 실행 가능합니다.

### 4. 프로젝트 실행 방법
1. **백엔드(Spring Boot) 서버 실행 또는 211.188.50.244:8080 이용**
2. **프론트엔드(Android Studio 또는 Flutter)에서 백엔드 서버와 연결 후 실행**
