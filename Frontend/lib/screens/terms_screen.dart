import 'package:flutter/material.dart';
import 'login_screen.dart';

class TermsScreen extends StatefulWidget {
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _allAgreed = false;
  bool _term1Agreed = false;
  bool _term2Agreed = false;
  bool _term3Agreed = false;

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
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '신한카드 Hey Young 체크',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카드 이미지 섹션
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '신한카드 Hey Young 체크',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        // 서비스 태그들
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildServiceTag('생활 서비스'),
                            SizedBox(width: 8),
                            _buildServiceTag('간편결제 서비스'),
                            SizedBox(width: 8),
                            _buildServiceTag('해외이용 서비스'),
                          ],
                        ),
                        SizedBox(height: 24),

                        // 카드 이미지
                        Container(
                          width: 200,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.credit_card,
                              size: 50,
                              color: Colors.blue[300],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        Text(
                          '연회비 VISA 없음, LOCAL 없음',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '가족카드 불가, 후불교통 가능',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20),

                        // 신청하기 버튼
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '신청하기',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // 약관 동의 섹션
                  Container(
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
                        // 전체 동의
                        GestureDetector(
                          onTap: () => _toggleAll(!_allAgreed),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _allAgreed ? Colors.blue[600] : Colors.white,
                                  border: Border.all(
                                    color: _allAgreed
                                        ? Colors.blue[600]!
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
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

                        SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        SizedBox(height: 16),

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
                        SizedBox(height: 16),

                        _buildTermItem(
                          '(필수) 신한카드 서비스 이용약관',
                          _term2Agreed,
                              (value) {
                            setState(() {
                              _term2Agreed = value;
                              _updateAllAgreed();
                            });
                          },
                        ),
                        SizedBox(height: 16),

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
                ],
              ),
            ),
          ),
          // 하단 신청하기 버튼
          Container(
            color: Color(0xFFF5F5F5),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _term1Agreed && _term2Agreed
                      ? () => _showLoginDialog(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_term1Agreed && _term2Agreed)
                        ? Colors.blue[600]
                        : Colors.grey[400],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '신청하기',
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

  Widget _buildServiceTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[600],
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, bool isChecked, Function(bool) onChanged) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!isChecked),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isChecked ? Colors.blue[600] : Colors.white,
              border: Border.all(
                color: isChecked ? Colors.blue[600]! : Colors.grey[400]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: isChecked
                ? Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
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
          size: 16,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '로그인 안내',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '로그인이 필요한 메뉴입니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // 로그인 페이지로 이동하는 로직
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    '로그인 하시겠어요?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[600],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          '아니요',
                          style: TextStyle(
                            color: Colors.black87,
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
                          backgroundColor: Colors.blue[600],
                          padding: EdgeInsets.symmetric(vertical: 12),
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
}