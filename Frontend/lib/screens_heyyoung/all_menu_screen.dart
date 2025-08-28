import 'package:flutter/material.dart';
import 'grade_screen.dart';

class AllMenuScreen extends StatefulWidget {
  @override
  _AllMenuScreenState createState() => _AllMenuScreenState();
}

class _AllMenuScreenState extends State<AllMenuScreen> {
  String selectedCategory = '내 학적';

  final List<String> categories = ['내 학적', '내 수업', '내 성적', '내 등록금'];

  final Map<String, List<Map<String, dynamic>>> menuItems = {
    '내 학적': [
      {'icon': Icons.person, 'title': '나의 정보 변경'},
      {'icon': Icons.person_outline, 'title': '지도교수조회'},
      {'icon': Icons.psychology, 'title': '복학신청/휴소'},
    ],
    '내 수업': [
      {'icon': Icons.calendar_today, 'title': '강의평가'},
      {'icon': Icons.assignment, 'title': '강의시간표/강의계획안 조회'},
      {'icon': Icons.monetization_on, 'title': '수강신청 내역조회'},
    ],
    '내 성적': [
      {'icon': Icons.grade, 'title': '개인성적조회'},
      {'icon': Icons.school, 'title': '개인이수학점조회'},
      {'icon': Icons.analytics, 'title': '급학기성적조회'},
      {'icon': Icons.groups, 'title': '석차조회'},
    ],
    '내 등록금': [
      {'icon': Icons.account_balance_wallet, 'title': '등록금납부내역 확인'},
      {'icon': Icons.receipt, 'title': '등록금 고지서'},
      {'icon': Icons.assignment_returned, 'title': '분납고지내역'},
      {'icon': Icons.today, 'title': '0원 등록신청'},
      {'icon': Icons.sms, 'title': '등록금납부확인 SMS신청'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 사용자 정보 및 포인트/쿠폰 카드
          Container(
            margin: EdgeInsets.all(16),
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
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.blue[700],
                        ),
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
                                '김싸피',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '1412345, 소프트웨어학부',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              'P',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '2,010',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.card_giftcard,
                              color: Colors.green[700],
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '3',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // 카테고리 탭
          Container(
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black87 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16),

          // 선택된 카테고리의 메뉴 아이템들
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCategory,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        itemCount: menuItems[selectedCategory]?.length ?? 0,
                        separatorBuilder: (context, index) => Divider(
                          height: 24,
                          color: Colors.grey[200],
                        ),
                        itemBuilder: (context, index) {
                          final item = menuItems[selectedCategory]![index];
                          return _buildMenuItem(item['icon'], item['title']);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 100), // 하단 네비게이션을 위한 공간
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return InkWell(
      onTap: () {
        if (title == '개인성적조회') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GradeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title 선택됨'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 16),
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
            Icons.chevron_right,
            color: Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    );
  }
}