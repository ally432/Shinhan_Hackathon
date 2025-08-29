import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsScreen extends StatefulWidget {
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _allAgreed = false;
  bool _term1Agreed = false;
  bool _term2Agreed = false;
  bool _term3Agreed = false;

  int _selectedTab = 0;

  void _updateAllAgreed() {
    setState(() {
      _allAgreed = _term1Agreed && _term2Agreed && _term3Agreed;
    });
  }

  void _toggleAll(bool value) {
    setState(() {
      _allAgreed = value;
      _term1Agreed = value;
      _term2Agreed = value;
      _term3Agreed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'The 성적 UP!',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 상품 정보 섹션
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // 신한은행 로고 섹션
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(0xFF0046FF),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '\$',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '신한은행',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // 상품명
                        Text(
                          'The 성적 UP!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 24),

                        // 금리 정보 카드
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF7BB3F0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4A90E2).withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '기본금리',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '연 2.05%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.stars,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '최고금리',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '연 2.2%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // 상품 특징
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFeatureTag('대학생전용'),
                            SizedBox(width: 8),
                            _buildFeatureTag('성적우대'),
                            SizedBox(width: 8),
                            _buildFeatureTag('경제관념'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),

                  // 상품 상세 정보
                  // 탭 버튼들
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 탭 버튼
                        Container(
                          padding: EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(child: _buildTabButton('상품안내', 0)),
                              Expanded(child: _buildTabButton('금리안내', 1)),
                              Expanded(child: _buildTabButton('유의사항', 2)),
                            ],
                          ),
                        ),
                        // 탭 내용
                        Container(
                          padding: EdgeInsets.all(20),
                          child: _buildTabContent(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // 약관 동의 섹션
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 전체 동의
                        GestureDetector(
                          onTap: () => _toggleAll(!_allAgreed),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _allAgreed ? Color(0xFF4A90E2).withOpacity(0.1) : Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _allAgreed ? Color(0xFF4A90E2) : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _allAgreed ? Color(0xFF4A90E2) : Colors.white,
                                    border: Border.all(
                                      color: _allAgreed ? Color(0xFF4A90E2) : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: _allAgreed
                                      ? Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  '약관 전체동의',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // 개별 약관들
                        _buildTermItem(
                          '(필수) 개인정보 처리방침',
                          _term1Agreed,
                              (value) {
                            setState(() {
                              _term1Agreed = value;
                              _updateAllAgreed();
                            });
                          },
                        ),
                        SizedBox(height: 12),

                        _buildTermItem(
                          '(필수) 신한은행 서비스 이용약관',
                          _term2Agreed,
                              (value) {
                            setState(() {
                              _term2Agreed = value;
                              _updateAllAgreed();
                            });
                          },
                        ),
                        SizedBox(height: 12),

                        _buildTermItem(
                          '(선택) 마케팅 정보 수신 동의',
                          _term3Agreed,
                              (value) {
                            setState(() {
                              _term3Agreed = value;
                              _updateAllAgreed();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 하단 신청하기 버튼
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _term1Agreed && _term2Agreed ? _handleApply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_term1Agreed && _term2Agreed)
                        ? Color(0xFF4A90E2)
                        : Colors.grey[400],
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: (_term1Agreed && _term2Agreed) ? 4 : 0,
                  ),
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
    );
  }

  Widget _buildFeatureTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF4A90E2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF4A90E2).withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF4A90E2),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Color(0xFF4A90E2),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermItem(String title, bool isChecked, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isChecked ? Color(0xFF4A90E2) : Colors.white,
              border: Border.all(
                color: isChecked ? Color(0xFF4A90E2) : Colors.grey[400]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isChecked
                ? Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Future<void> _handleApply() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      if (!mounted) return;
      _showLoginDialog(context);
    } else {
      _showLoginDialog(context);
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  // width: 64,
                  // height: 64,
                  // decoration: BoxDecoration(
                  //   color: Color(0xFFFFFFFF).withOpacity(0.1),
                  //   shape: BoxShape.circle,
                  // ),
                  child: Icon(
                    Icons.monetization_on_outlined,
                    color: Color(0xFF4A90E2),
                    size: 50,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '로그인 안내',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '상품 가입을 위해 로그인이 필요합니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4A90E2),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '로그인하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String title, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _selectedTab == index ? Color(0xFF4A90E2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _selectedTab == index ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // 상품안내
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.school, '가입대상', '대학생 (만 19세~29세)'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.savings, '가입한도', '최소 50만원, 최대 1억원'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.schedule, '가입기간', '1년'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.percent, '우대조건', '성적 향상시 최대 0.15% 우대'),
          ],
        );
      case 1: // 금리안내
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('목표 달성별 우대금리', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildRateRow('4.3~4.5', '0.15%'),
            _buildRateRow('4.0~4.29', '0.1%'),
            _buildRateRow('3.7~3.99', '0.05%'),
            _buildRateRow('3.69 이하', '미지급'),
          ],
        );
      case 2: // 유의사항
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 최초 예치금 50만원 이상, 추가 납입 불가'),
            SizedBox(height: 8),
            Text('• 목표 성적 달성 시 우대금리, 미달 시 위로 보상 제공'),
            SizedBox(height: 8),
            Text('• 중도해지 시 우대금리 및 보상 미적용'),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildRateRow(String period, String rate) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(period, style: TextStyle(fontSize: 14)),
          Text(rate, style: TextStyle(fontSize: 14, color: Color(0xFF4A90E2), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}