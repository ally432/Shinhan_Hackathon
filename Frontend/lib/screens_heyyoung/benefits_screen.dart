import 'package:flutter/material.dart';
import 'insurance_detail_screen.dart';

class BenefitsScreen extends StatefulWidget {
  @override
  _BenefitsScreenState createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: Colors.black, size: 20),
                SizedBox(width: 4),
                Text('2,010', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.confirmation_num_outlined, color: Colors.black, size: 20),
                SizedBox(width: 4),
                Text('3장', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 프로모션 카드들
            Container(
              height: 250,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // 시험 보험
                  _buildPromotionCard(
                    icon: '💰',
                    title: '시험 보험에 가입하고\n성적이 기대되는 캠퍼스 생활을 해봐요!',
                    buttonText: '자세히 보기',
                    backgroundColor: Color(0xFFF0F8FF),
                    onPressed: () => _navigateToInsurance(context),
                  ),
                  // 점심값
                  _buildPromotionCard(
                    icon: '🍱',
                    title: '점심값 걱정했다면?\n지금 50% 돌려받으세요',
                    buttonText: '자세히 보기',
                    backgroundColor: Color(0xFFF0F8FF),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 페이지 인디케이터
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.blue : Colors.grey[300],
                    ),
                  );
                }),
              ),
            ),

            // 메뉴 리스트
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: '🎮',
                    title: '소수점 게임',
                    subtitle: '이번주 상금 도전하기',
                    iconColor: Colors.blue[100]!,
                  ),
                  _buildMenuItem(
                    icon: '🍱',
                    title: '매일 반값점심 참여하고',
                    subtitle: '3천원 받기',
                    iconColor: Colors.orange[100]!,
                    badge: '급상승',
                  ),
                  _buildMenuItem(
                    icon: '📊',
                    title: '시사상식 퀴즈풀고',
                    subtitle: '용돈 받기',
                    iconColor: Colors.purple[100]!,
                  ),
                  _buildMenuItem(
                    icon: '✅',
                    title: '해외앱 방문하고',
                    subtitle: '완료',
                    iconColor: Colors.blue[100]!,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // 1학기 반값점심 총결산
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1학기 반값점심 총결산!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '리포트보고 이번 학기에도 반값점심',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('🍲', style: TextStyle(fontSize: 30)),
                ],
              ),
            ),

            SizedBox(height: 16),

            // 내가 받을 쿠폰 섹션
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내가 받을 쿠폰',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildCouponItem(
                    icon: '🍔',
                    title: '2번 주문하고',
                    subtitle: '맥거와 1만원 쿠폰 받기',
                    backgroundColor: Colors.orange,
                  ),
                  SizedBox(height: 12),
                  _buildCouponItem(
                    icon: '🥗',
                    title: '용돈 계좌 만들고',
                    subtitle: '올리브영 1만원 쿠폰 받기',
                    backgroundColor: Colors.green,
                  ),
                  SizedBox(height: 12),
                  _buildCouponItem(
                    icon: '🎁',
                    title: '조건 없는 선착순 개강선물',
                    subtitle: '배달앱 5천원 할인쿠폰 받기',
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
            ),

            SizedBox(height: 100), // 하단 네비게이션을 위한 공간
          ],
        ),
      ),
    );
  }

  void _navigateToInsurance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsuranceDetailScreen(),
      ),
    );
  }

  Widget _buildPromotionCard({
    required String icon,
    required String title,
    required String buttonText,
    required Color backgroundColor,
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 40),
          ),
          SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40, 
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    String? badge,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: TextStyle(fontSize: 24)),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (badge != null) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponItem({
    required String icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(icon, style: TextStyle(fontSize: 24)),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: backgroundColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}