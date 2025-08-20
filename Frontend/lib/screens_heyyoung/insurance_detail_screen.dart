import 'package:flutter/material.dart';
import 'sol_bank_screen.dart';

class InsuranceDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // 메인화면과 동일한 배경색
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '시험 보험',
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
                  // 시험 보험 상품 카드
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
                                Icons.shield_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(width: 12),
                              Text(
                                '시험 보험',
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
                            '시험 응시 중 발생할 수 있는\n다양한 상황에 대비하세요',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '월 4만 8천원',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // 보험 혜택 내용
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
                          '보험 혜택',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildBenefitItem('✓ 시험 당일 응급상황 발생 시 재시험 기회 제공'),
                        _buildBenefitItem('✓ 교통사고로 인한 시험 지연 시 보상'),
                        _buildBenefitItem('✓ 갑작스런 질병으로 인한 시험 응시 불가 시 지원'),
                        _buildBenefitItem('✓ 천재지변으로 인한 시험 취소 시 환불'),
                        _buildBenefitItem('✓ 기술적 문제로 인한 온라인 시험 장애 시 보상'),
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
                          '제1조 (목적)\n본 약관은 시험 보험 서비스 이용에 관한 제반 사항을 규정함을 목적으로 합니다.\n\n제2조 (정의)\n"시험"이라 함은 학교에서 주관하는 모든 형태의 평가를 의미합니다.\n\n제3조 (보상 범위)\n다음 각 호의 경우에 보상을 제공합니다:\n1. 응급의료상황 발생\n2. 교통사고 또는 대중교통 지연\n3. 천재지변\n4. 기타 불가피한 사유\n\n제4조 (보상 제외 사항)\n고의 또는 중과실로 인한 경우는 보상에서 제외됩니다.\n\n제5조 (보험료)\n월 보험료는 48,000원이며, 매월 자동 결제됩니다.\n\n제6조 (계약 해지)\n언제든지 계약 해지가 가능하며, 해지 시 미사용 기간에 대해 일할 계산하여 환불됩니다.\n\n제7조 (보상 신청)\n보상 신청은 사유 발생 후 7일 이내에 신청해야 하며, 관련 증빙서류를 첨부해야 합니다.\n\n제8조 (면책 사항)\n다음의 경우에는 보상하지 않습니다:\n1. 보험 가입 전 발생한 사유\n2. 허위 신고나 기만적 행위\n3. 전쟁, 테러 등 불가항력적 사유\n\n제9조 (분쟁 해결)\n본 보험과 관련된 분쟁은 관할 법원에서 해결합니다.',
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue[600]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '월 4만 8천원',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                            '보험 가입하기',
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