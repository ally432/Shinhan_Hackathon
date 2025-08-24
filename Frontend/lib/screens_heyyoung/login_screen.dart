import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/account_selection_screen.dart';
import '../screens_shinhanbank/account_terms_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Text('신한', style: TextStyle(fontSize: 18, color: Colors.blue[600], fontWeight: FontWeight.w500)),
                    Text('SOL', style: TextStyle(fontSize: 48, color: Colors.blue[600], fontWeight: FontWeight.bold)),
                    Text('Bank', style: TextStyle(fontSize: 24, color: Colors.blue[600], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _autoLogin = !_autoLogin),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _autoLogin ? Colors.blue[600] : Colors.white,
                            border: Border.all(color: _autoLogin ? Colors.blue[600]! : Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: _autoLogin ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('자동로그인'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('로그인', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(onTap: () {}, child: Text('ID찾기', style: TextStyle(fontSize: 14, color: Colors.grey[600], decoration: TextDecoration.underline))),
                  Container(margin: const EdgeInsets.symmetric(horizontal: 16), width: 1, height: 12, color: Colors.grey[400]),
                  GestureDetector(onTap: () {}, child: Text('PW찾기', style: TextStyle(fontSize: 14, color: Colors.grey[600], decoration: TextDecoration.underline))),
                  Container(margin: const EdgeInsets.symmetric(horizontal: 16), width: 1, height: 12, color: Colors.grey[400]),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                    child: Text('회원가입', style: TextStyle(fontSize: 14, color: Colors.grey[600], decoration: TextDecoration.underline)),
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

    // 로그인 처리 (딜레이 추가)
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 로그인 성공 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그인 되었습니다.')),
    );

    // 사용자 정보 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', _emailController.text.trim());

    // 수시입출금 계좌 확인
    await _checkSavingsAccount();
  }

  Future<void> _checkSavingsAccount() async {
    // 테스트를 위해 수시입출금 계좌가 없다고 가정
    // 실제로는 서버에서 계좌 정보를 확인해야 함
    await Future.delayed(const Duration(milliseconds: 300));

    bool hasSavingsAccount = false; // 테스트용: 항상 false로 설정

    if (!mounted) return;

    if (hasSavingsAccount) {
      // 계좌가 있으면 바로 계좌 선택 화면으로
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AccountSelectionScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      // 계좌가 없으면 계좌 개설 안내 다이얼로그 표시
      _showAccountCreationDialog();
    }
  }

  void _showAccountCreationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: Colors.blue[600], size: 48),
              const SizedBox(height: 16),
              const Text(
                '수시입출금 계좌 개설',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            '송금 서비스를 이용하시려면\n수시입출금 계좌가 필요합니다.\n\n지금 개설하시겠습니까?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 취소 시 다시 로그인 화면으로
              },
              child: Text('취소', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 계좌 개설을 위해 약관 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountTermsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('개설하기', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /* 실제 서버 연동 시 사용할 코드
  Future<bool> _checkSavingsAccountFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final url = Uri.parse('$baseUrl/accounts/check-savings');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'userId': userId});

      final res = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['hasSavingsAccount'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  */

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}