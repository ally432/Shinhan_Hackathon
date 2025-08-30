import 'package:flutter/material.dart';
import 'insurance_detail_screen.dart';
import 'benefits_screen.dart';
import 'all_menu_screen.dart';
import 'grade_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 출석한 날짜 저장
  static Set<DateTime> attendedDates = {};

  // 현재 표시할 달
  DateTime currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: _currentIndex == 0
          ? _buildMainContent()
          : _currentIndex == 1
          ? BenefitsScreen()
          : AllMenuScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '학사',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.calendar_today),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),

                  ),
                ),
              ],
            ),
            label: '혜택',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '전체메뉴',
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 헤더
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // SSAFY 로고와 텍스트
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'SSAFY 캠퍼스',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // 알림 아이콘
                  Icon(
                    Icons.notifications_outlined,
                    size: 28,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // 모바일 학생증 카드
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                      Text(
                        '모바일 학생증',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          // 프로필 이미지
                          Container(
                            width: 60,
                            height: 60,
                            child: Center(
                              child: Image.asset(
                                'assets/icons/moli.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(width: 25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '소프트웨어학부, 졸업생',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '김몰리 (1412345)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      // QR, NFC 버튼
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'QR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.nfc,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'NFC',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // 시험 보험 배너
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => _navigateToInsurance(context),
                child: Container(
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'The 성적 UP!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '좋은 성적 받고 돈 받으러 가기',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          // color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/icons/the_grade_up.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // MY메뉴 섹션
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MY메뉴',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  // MY메뉴 아이콘들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMyMenuItem(Icons.grade, '개인성적\n조회', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GradeScreen()),
                        );
                      }),
                      _buildMyMenuItem(Icons.search, '금학기성적\n조회', () {}),
                      _buildMyMenuItem(Icons.credit_card, '다기능카드\n등록', () {}),
                      _buildMyMenuItem(Icons.school, '다기능카드\n등록실적', () {}),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // 캘린더 섹션
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '캘린더',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                currentMonth = DateTime(
                                  currentMonth.year,
                                  currentMonth.month - 1,
                                );
                              });
                            },
                            icon: Icon(Icons.chevron_left),
                          ),
                          Text(
                            '${currentMonth.year}.${currentMonth.month.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                currentMonth = DateTime(
                                  currentMonth.year,
                                  currentMonth.month + 1,
                                );
                              });
                            },
                            icon: Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
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
                    child: Column(
                      children: [
                        // 요일 헤더
                        Row(
                          children: ['일', '월', '화', '수', '목', '금', '토']
                              .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: day == '일' ? Colors.red : Colors.black87,
                                ),
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                        SizedBox(height: 8),
                        // 캘린더 그리드
                        _buildCalendar(),
                      ],
                    ),
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

  Widget _buildMyMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.black87,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCalendar() {
  //   final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
  //   final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
  //   final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));
  //
  //   List<Widget> weeks = [];
  //
  //   for (int week = 0; week < 6; week++) {
  //     List<Widget> days = [];
  //
  //     for (int day = 0; day < 7; day++) {
  //       final date = startDate.add(Duration(days: week * 7 + day));
  //       final isCurrentMonth = date.month == currentMonth.month;
  //       final isToday = _isSameDay(date, DateTime.now());
  //       final isAttended = attendedDates.any((attendedDate) => _isSameDay(attendedDate, date));
  //
  //       days.add(
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: isCurrentMonth && isToday ? () {
  //               setState(() {
  //                 if (isAttended) {
  //                   attendedDates.removeWhere((attendedDate) => _isSameDay(attendedDate, date));
  //                 } else {
  //                   attendedDates.add(date);
  //                 }
  //               });
  //             } : null,
  //             child: Container(
  //               height: 45,
  //               margin: EdgeInsets.all(2),
  //               decoration: BoxDecoration(
  //                 color: isToday ? Colors.blue[100] : Colors.transparent,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Stack(
  //                 children: [
  //                   Center(
  //                     child: Text(
  //                       date.day.toString(),
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: isCurrentMonth
  //                             ? (isToday ? Colors.blue[700] : Colors.black87)
  //                             : Colors.grey[300],
  //                         fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
  //                       ),
  //                     ),
  //                   ),
  //                   if (isAttended && isCurrentMonth)
  //                     Positioned(
  //                       bottom: 4,
  //                       right: 4,
  //                       child: Container(
  //                         width: 16,
  //                         height: 16,
  //                         decoration: BoxDecoration(
  //                           color: Colors.amber[600],
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: Icon(
  //                           Icons.monetization_on,
  //                           size: 12,
  //                           color: Colors.white,
  //                         ),
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //
  //     weeks.add(Row(children: days));
  //
  //     // 마지막 주가 다음 달이라면 끝
  //     if (week == 4 && startDate.add(Duration(days: (week + 1) * 7)).month != currentMonth.month) {
  //       break;
  //     }
  //   }
  Widget _buildCalendar() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    List<Widget> weeks = [];

    for (int week = 0; week < 6; week++) {
      List<Widget> days = [];

      for (int day = 0; day < 7; day++) {
        final date = startDate.add(Duration(days: week * 7 + day));
        final isCurrentMonth = date.month == currentMonth.month;
        final isToday = _isSameDay(date, DateTime.now());
        final isAttended = attendedDates.any((attendedDate) => _isSameDay(attendedDate, date));

        days.add(
          Expanded(
            child: GestureDetector(
              onTap: isCurrentMonth && isToday ? () {
                _showAttendanceDialog(date, isAttended);
              } : null,
              child: Container(
                height: 45,
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isToday ? Colors.blue[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isCurrentMonth
                              ? (isToday ? Colors.blue[700] : Colors.black87)
                              : Colors.grey[300],
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isAttended && isCurrentMonth)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.amber[600],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.monetization_on,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      weeks.add(Row(children: days));

      // 마지막 주가 다음 달이라면 끝
      if (week == 4 && startDate.add(Duration(days: (week + 1) * 7)).month != currentMonth.month) {
        break;
      }
    }

    return Column(children: weeks);
  }

  void _showAttendanceDialog(DateTime date, bool isAttended) {
    // 이미 출석한 경우 다이얼로그 표시하지 않음
    if (isAttended) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[50]!,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_available,
                    size: 30,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 16),

                // 제목
                Text(
                  '출석 체크',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),

                // 내용
                Text(
                  '${date.month}월 ${date.day}일',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '출석하시겠습니까?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            attendedDates.add(date);
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          '확인',
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


  bool _isSameDay(DateTime a, DateTime b) { // 오늘 날짜만 출석 가능
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _navigateToInsurance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsuranceDetailScreen(),
      ),
    );
  }
}