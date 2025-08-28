import 'package:flutter/material.dart';
import 'sol_bank_screen.dart';

class InsuranceDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'The 성적 UP',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 스크롤 가능한 내용 영역
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 80), // 하단 버튼을 위한 패딩
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 시험 보험
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E3A8A),
                          Color(0xFF3B82F6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'The 성적 UP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            '성적 Up! 금리 Up!\n두 마리 토끼를 잡으세요!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // 상품 혜택 내용
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '상품 혜택',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildBenefitItem('✓ 목표 성적 기반 자기주도 학습 습관'),
                        _buildBenefitItem('✓ 달성 시 최대 연 0.15% 추가 금리'),
                        _buildBenefitItem('✓ 미달 시 포인트 및 쿠폰 위로 보상'),
                        _buildBenefitItem('✓ 다음 학기에 이어가는 도전'),
                        _buildBenefitItem('✓ 대학생 맞춤 학업 및 금융 경험'),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // 약관 및 상세 내용
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '약관 및 상세 내용',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '제1조 (목적)\n본 약관은 신한은행이 제공하는 「The 성적 UP」 상품의 가입, 운영 및 해지와 관련하여 필요한 사항을 규정함을 목적으로 한다.\n\n제2조 (정의)\n① “가입자”라 함은 본 상품에 가입한 개인을 말한다.\n② “목표 성적”이라 함은 가입자가 사전에 설정한 학기별 성적 기준을 말한다.\n③ “우대금리”라 함은 목표 성적 달성 시 기본금리에 추가로 제공되는 금리를 말한다.\n④ “위로 보상”이라 함은 목표 성적 미달 시 제공되는 신한 포인트, 기프티콘, 땡겨요 쿠폰 등을 말한다.\n⑤ 기타 용어의 정의는 관련 법령 및 은행 일반 약관에서 정한 바에 따른다.\n\n제3조 (가입 대상)\n본 상품은 국내 대학(전문대학 포함)에 재학 중인 만 19세 이상 만 29세 이하 개인만 가입할 수 있다.\n\n제4조 (가입 및 예치)\n① 가입자는 은행이 지정한 자유 적립식 정기예금 계좌를 개설해야 한다.\n② 예치금은 최소 50만원 이상으로 하며, 이후 추가 납입은 불가능하다.\n③ 예치 기간은 기본 12개월로 하며, 성적 확인은 해당 기간 동안의 성적 정보를 사용한다.\n\n제5조 (목표 성적 설정 및 검증)\n① 가입자는 상품을 학기 초에 가입하여 목표 성적을 설정하여야 한다.\n② 성적 검증은 제휴 대학 포털에 기재된 성적을 통해 이루어진다.\n③ 성적 확인은 상품 만기 후 은행이 지정한 일정에 따라 자동으로 진행된다.\n\n제6조 (우대 금리)\n① 목표 성적 달성 시, 기본금리에 추가로 아래와 같이 우대금리를 제공한다.\n4.3 ~ 4.5 : 연 0.15%p\n4.0 ~ 4.29 : 연 0.10%p\n3.7 ~ 3.99 : 연 0.05%p\n② 목표 성적 미달 시 우대금리는 적용되지 않는다.\n③ 동일 학년도 1·2학기 중 더 높은 성적을 기준으로 적용한다.\n\n제7조 (위로 보상)\n① 가입자가 목표 성적에 미달한 경우, 예치금의 2% 범위 내에서 위로 보상을 제공한다.\n② 위로 보상은 신한 포인트, 땡겨요 쿠폰, 기프티콘 중 가입자가 선택할 수 있다.\n③ 위로 보상은 1회 최대 2만원 한도로 지급된다.\n\n제8조 (중도해지 및 해지 시 처리)\n① 가입자가 예금을 중도 해지하는 경우, 은행의 일반 정기예금 중도해지 이율을 적용한다.\n② 성적 검증 완료 이전에 해지하는 경우, 우대금리 및 위로 보상은 지급되지 않는다.\n③ 만기 시 은행은 목표 성적 달성 여부에 따른 금리를 반영하여 원리금을 지급한다.\n\n제9조 (기타 사항)\n① 본 약관에 명시되지 아니한 사항은 은행의 일반 정기예금 약관 및 관련 법령에 따른다.\n② 은행은 불가피한 사유 발생 시 상품 내용을 변경할 수 있으며, 이 경우 사전에 가입자에게 통지한다.\n③ 본 약관은 2025년 8월 11일부터 시행한다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 고정 신청 버튼
          Container(
            color: Color(0xFFF5F5F5),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SolBankScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1E3A8A),
                              Color(0xFF3B82F6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '상품 가입하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
}