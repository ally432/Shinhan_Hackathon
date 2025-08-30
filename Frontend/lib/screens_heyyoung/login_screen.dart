import 'package:flutter/material.dart';
import '../screens_shinhanbank/home_screen.dart';
import '../screens_shinhanbank/home_screen_fail.dart';
import '../widgets/custom_dialogs.dart'; // showCustomDialog 사용 중이면 유지
import 'signup_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/account_selection_screen.dart';
import '../screens_shinhanbank/account_terms_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // (미사용)
  static const String baseUrl = 'http://211.188.50.244:8080';
  bool _autoLogin = false;
  bool _isLoading = false;

  /// 0: 만기 아님, 1: 목표 달성, 2: 목표 미달
  int _maturityFlag = 0;

  @override
  void initState() {
    super.initState();
    _forceLogoutOnColdStart();
  }

  Future<void> _forceLogoutOnColdStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userKey');
    await prefs.remove('autoLogin');
  }

  // =========================
  // UI
  // =========================
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
              // 헤더
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Text('신한',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500)),
                    Text('SOL',
                        style: TextStyle(
                            fontSize: 48,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.bold)),
                    Text('Bank',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 이메일
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
                    prefixIcon:
                    Icon(Icons.person_outline, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 패스워드(미사용)
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 자동로그인
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
                            color:
                            _autoLogin ? Colors.blue[600] : Colors.white,
                            border: Border.all(
                                color: _autoLogin
                                    ? Colors.blue[600]!
                                    : Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: _autoLogin
                              ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('자동로그인'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _isLoading ? '로그인 중...' : '로그인',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // 하단 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {},
                      child: Text('ID찾기',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600]))),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: 1,
                      height: 12,
                      color: Colors.grey[400]),
                  GestureDetector(
                      onTap: () {},
                      child: Text('PW찾기',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600]))),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: 1,
                      height: 12,
                      color: Colors.grey[400]),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignupScreen())),
                    child: Text('회원가입',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey[600])),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // 로그인 처리
  // =========================
  Future<void> _handleLogin() async {
    final userId = _emailController.text.trim();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final res = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      )
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final userKey = (data['userKey'] ?? '') as String;

        if (userKey.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 응답에 userKey가 없습니다.')),
          );
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userKey', userKey);
        await prefs.setBool('autoLogin', _autoLogin);

        await _checkProductsAndRoute(userKey); // 이후 흐름
      } else if (res.statusCode == 401) {
        await _showErrorDialog('오류', '아이디가 존재하지 않습니다.');
      } else if (res.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('요청 형식이 올바르지 않습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${res.statusCode}')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================
  // 제품/계좌 상태 → 라우팅
  // =========================
  Future<void> _checkProductsAndRoute(String userKey) async {
    try {
      // 1. 먼저 예/적금 계좌 존재 여부를 확인합니다.
      final hasSavings = await _hasSavingsDeposit(userKey);

      if (!hasSavings) {
        // 예/적금 계좌가 있다면, 만기 상태를 확인합니다.
        final flag = await _fetchMaturityFlag(userKey);

        if (!mounted) return;

        if (flag == 1) {
          // 목표 달성 → 성공 홈
          await _showPopup(
            '🎉 목표 달성 성공!',
            '성적계좌가 만기되었습니다. 우대 금리가 적용된 최종 금액을 확인해보세요!',
            const HomeScreen(),
          );
          return;
        } else if (flag == 2) {
          // 목표 미달 → 실패 홈
          await _showPopup(
            '다시 도전해봐요',
            '만기일에 목표 조건을 충족하지 못했습니다. 다음 목표를 새로 설정해보세요!',
            const HomeFailScreen(),
          );
          return;
        }
      }

      // 2. 만기 팝업이 필요 없으면, 수시입출금 계좌 존재 여부를 확인합니다.
      final hasDemand = await _hasDemandDeposit(userKey);

      if (!hasDemand) {
        await _showAccountCreationDialog();
        return;
      }

      // 3. 입출금 계좌가 있고 만기 팝업이 필요 없는 경우
      // (예/적금 계좌가 없거나, 만기가 되지 않은 경우)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => hasSavings ? const HomeScreen() : const AccountSelectionScreen()),
            (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계좌 확인 중 오류: $e')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AccountSelectionScreen()),
            (route) => false,
      );
    }
  }


  // =========================
  // 만기 플래그 조회 (UI 없음)
  // =========================
  Future<int> _fetchMaturityFlag(String userKey) async {
    try {
      // 백엔드가 userKey를 받도록 변경한 엔드포인트 기준
      final uri = Uri.parse('$baseUrl/deposit/maturity-flag')
          .replace(queryParameters: {'userKey': userKey});
      final res = await http.get(uri).timeout(const Duration(seconds: 7));

      if (res.statusCode != 200) return 0;

      final obj = jsonDecode(res.body) as Map<String, dynamic>;
      final flag = (obj['maturity'] ?? 0) as int; // 0/1/2
      return flag;
    } catch (_) {
      return 0;
    }
  }

  // 만기 상태 팝업 처리
  Future<void> _fetchMaturityFlagAndMaybePopup(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/deposit/maturity-flag')
          .replace(queryParameters: {'email': email});
      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final flag = (json['maturity'] ?? 0) as int;

        setState(() {
          _maturityFlag = flag;  // 상태 업데이트
        });

        // Debugging log
        print("Maturity flag received: $flag");

        if (flag == 1) {
          // 목표 달성 팝업
          await _showPopup(
            '🎉 목표 달성 성공!',
            '성적계좌가 만기되었습니다. 우대 금리가 적용된 최종 금액을 확인해보세요!',
            const HomeScreen(),
          );
        } else if (flag == 2) {
          // 목표 미달 팝업
          await _showPopup(
            '다시 열심히 해보자~',
            '성적계좌가 만기되었습니다. 우대 금리가 적용된 최종 금액을 확인해보세요!',
            const HomeFailScreen(),
          );
        } else {
          // 만기 아님
          print("No maturity flag set, proceeding with normal flow.");
        }
      }
    } catch (e) {
      print("Error fetching maturity flag: $e");
    }
  }

  // =========================
  // 팝업(확인 → 다음 화면 이동)
  // =========================
  Future<void> _showPopup(String title, String content, Widget nextScreen) async {
    // 프로젝트에 custom_dialogs가 없다면 showDialog로 대체하세요.
    await showCustomDialog(
      context: context,
      title: title,
      content: content,
      onConfirm: () {
        Navigator.pop(context); // close dialog
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
              (route) => false,
        );
      },
    );
  }

  // =========================
  // 수시입출금 계좌 존재 여부
  // =========================
  Future<bool> _hasDemandDeposit(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit')
        .replace(queryParameters: {'userKey': userKey});

    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));

    if (res.statusCode != 200) return false;

    final root = jsonDecode(res.body);
    final rec = root['REC'];
    if (rec is List) {
      return rec.isNotEmpty;
    } else if (rec is Map) {
      final list = rec['list'];
      return list is List && list.isNotEmpty;
    }
    return false;
  }

  // =========================
  // 예금(시험계좌 등) 존재 여부
  // =========================
  Future<bool> _hasSavingsDeposit(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findSavingsDeposit')
        .replace(queryParameters: {'userKey': userKey});

    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));

    if (res.statusCode != 200) return false;

    final root = jsonDecode(res.body);
    final recObj = (root['REC'] as Map?) ?? const {};
    final list = (recObj['list'] as List?) ?? const [];

    return list.isNotEmpty;
  }

  // =========================
  // 수시입출금 계좌 개설 다이얼로그 (Future 반환!)
  // =========================
  Future<void> _showAccountCreationDialog() {
    return showDialog<void>(
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
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 계좌 개설 약관 화면으로 이동
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

  Future<void> _showErrorDialog(String title, String content) {
    return showDialog<void>(  // 오류 다이얼로그 추가
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.red.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 에러 아이콘
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 12),
              Text(content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.black54, height: 1.5)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Center(
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
