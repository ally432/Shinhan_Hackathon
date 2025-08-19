import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const String baseUrl = 'http://10.0.2.2:8080';
  bool _autoLogin = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 60),

              // SOL Bank 로고
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Text(
                      '신한',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'SOL',
                      style: TextStyle(
                        fontSize: 48,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bank',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              SizedBox(height: 30),

              // 이메일 입력 필드
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email을 입력하세요.',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: 8),

              SizedBox(height: 16),

              // 비밀번호 입력 필드
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력하세요.',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 자동 로그인 체크박스
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _autoLogin = !_autoLogin;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _autoLogin ? Colors.blue[600] : Colors.white,
                            border: Border.all(
                              color: _autoLogin ? Colors.blue[600]! : Colors.grey[400]!,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: _autoLogin
                              ? Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '자동로그인',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 로그인 로직
                    _handleLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // 하단 링크들
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // ID 찾기 로직
                    },
                    child: Text(
                      'ID찾기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    width: 1,
                    height: 12,
                    color: Colors.grey[400],
                  ),
                  GestureDetector(
                    onTap: () {
                      // PW 찾기 로직
                    },
                    child: Text(
                      'PW찾기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    width: 1,
                    height: 12,
                    color: Colors.grey[400],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일을 입력해주세요.')),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'userId': _emailController.text.trim()});

    try {
      final res = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 7));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', data['userId'] ?? _emailController.text.trim());
        await prefs.setString('username', data['username'] ?? '');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 되었습니다.')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (res.statusCode == 401) {
        // DB에 userId가 없을 때
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('등록되지 않은 사용자입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}