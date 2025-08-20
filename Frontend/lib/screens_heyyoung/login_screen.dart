import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/step1_id_selection_screen.dart';


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
    // build 함수 내용은 변경 없습니다.
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
    /*
    // ######## API 연동 없이 테스트하기 위한 수정 ########

    // 1. 잠시 딜레이를 주어 실제 통신하는 것처럼 보이게 합니다.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 2. 로그인 성공 메시지를 바로 보여줍니다.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그인 되었습니다. (테스트)')),
    );

    // 3. 바로 다음 화면으로 이동합니다.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Step1IdSelectionScreen()),
          (Route<dynamic> route) => false,
    );
    */

    // ######## 4. 기존 네트워크 통신 코드 ########
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

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Step1IdSelectionScreen()),
              (Route<dynamic> route) => false,
        );

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