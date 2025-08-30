import 'package:flutter/material.dart';
import '../screens_shinhanbank/home_screen.dart';
import '../screens_shinhanbank/home_screen_fail.dart';
import '../widgets/custom_dialogs.dart';
import 'signup_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/account_selection_screen.dart';
import '../screens_shinhanbank/account_terms_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const String baseUrl = 'http://211.188.50.244:8080';
  bool _autoLogin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _forceLogoutOnColdStart();
  }

  int _mainAccount = 0; // 0: 만기 아님, 1: 목표 달성, 2: 미달

  Future<void> fetchMaturityFlag(String email) async {
    final uri = Uri.parse('http://<BACKEND_HOST>:8080/deposit/maturity-flag?email=$email');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        _mainAccount = (json['maturity'] ?? 0) as int;
      });
    } else {
      // 통신 오류 시 기본값 유지
      setState(() { _mainAccount = 0; });
    }
  }

  int _maturityFlag = 0; // 0: 만기 아님, 1: 목표 달성, 2: 미달

  Future<void> _fetchMaturityFlagAndMaybePopup(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/deposit/maturity-flag')
          .replace(queryParameters: {'email': email});
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (!mounted) return;

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final flag = (json['maturity'] ?? 0) as int;
        setState(() => _maturityFlag = flag);

        if (flag == 1) {
          await showCustomDialog(
            context: context,
            title: '🎉  목표 달성 성공!',
            content: '성적계좌가 만기되었습니다. 우대 금리가 적용된 최종 금액을 확인해보세요!',
            onConfirm: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
          );
        } else if (flag == 2) {
          await showCustomDialog(
            context: context,
            title: '다시 열심히 해보자~',
            content: '성적계좌가 만기되었습니다. 우대 금리가 적용된 최종 금액을 확인해보세요!',
            onConfirm: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeFailScreen()));
            },
          );
        }
      } else {
        // 실패 시는 조용히 패스 (팝업 없음)
      }
    } catch (_) {
      // 네트워크 오류 등도 조용히 패스
    }
  }

  Future<void> _forceLogoutOnColdStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userKey');
    await prefs.remove('autoLogin');
  }

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
                  GestureDetector(onTap: () {}, child: Text('ID찾기', style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
                  Container(margin: const EdgeInsets.symmetric(horizontal: 16), width: 1, height: 12, color: Colors.grey[400]),
                  GestureDetector(onTap: () {}, child: Text('PW찾기', style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
                  Container(margin: const EdgeInsets.symmetric(horizontal: 16), width: 1, height: 12, color: Colors.grey[400]),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                    child: Text('회원가입', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
    final userId = _emailController.text.trim();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    /*
    //====테스트 코드====//
    // 1. 실제 네트워크 통신 대신 잠시 기다립니다.
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // 2. 로그인 성공 메시지를 보여줍니다.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그인 되었습니다. (테스트 모드)')),
    );

    // 3. 계좌가 '있는' 상황을 가정하고 바로 '시험 보험 개설' 화면(AccountSelectionScreen)으로 이동합니다.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AccountSelectionScreen()),
          (route) => false,
    );

    // 4. 로딩 상태를 해제합니다.
    if (mounted) setState(() => _isLoading = false);
    */

    // =====기존 코드=====//
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final res = await http
          .post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      )
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final userKey = (data['userKey'] ?? '') as String;

        // (방어 코드) 혹시라도 비어있으면 오류 처리
        if (userKey.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 응답에 userKey가 없습니다.')),
          );
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userKey', userKey);     // userKey만 저장
        await prefs.setBool('autoLogin', _autoLogin);

        await _checkProductsAndRoute(); // 이후 흐름
      } else if (res.statusCode == 401) {
        await showDialog(
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

                  // 제목
                  const Text(
                    '오류',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 내용
                  const Text(
                    '아이디가 존재하지 않습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 버튼
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

  Future<void> _checkProductsAndRoute() async {
    final prefs = await SharedPreferences.getInstance();

    final userKey = prefs.getString('userKey') ?? '';

    final email = _emailController.text.trim();

    if (userKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('userKey가 없습니다. 다시 로그인해 주세요.')),
      );
      return;
    }

    try {
      final results = await Future.wait<bool>([
        _hasDemandDeposit(userKey),
        _hasSavingsDeposit(userKey),
      ]);

      final hasDemand = results[0];
      final hasSavings = results[1];

      if (!mounted) return;

      if (!hasDemand) {
        _showAccountCreationDialog();
        return;
      }

      if (hasDemand && hasSavings) {
        // 📌 먼저 만기/목표 달성 팝업을 시도한다.
        await _fetchMaturityFlagAndMaybePopup(email);
        if (!mounted) return;

        // 팝업이 떴다면 onConfirm에서 HomeScreen으로 이동했음 → 여기서 종료
        if (_maturityFlag == 1 || _maturityFlag == 2) return;

        // 팝업이 없었다면 기존 '알림' 다이얼로그 + 홈 이동
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AccountSelectionScreen(),
        );

        if (!mounted) return;
        await prefs.setBool('justLoggedIn', true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
        return;
      }

      // 수시입출금만 있고 예금은 없을 때
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AccountSelectionScreen()),
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

  /// 수시입출금 계좌 존재 여부 확인
  Future<bool> _hasDemandDeposit(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit')
        .replace(queryParameters: {'userKey': userKey});

    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));

    if (res.statusCode != 200) return false;

    final root = jsonDecode(res.body);
    // 백엔드/외부 응답이 REC가 객체일 수도, 리스트일 수도 있어서 모두 처리
    final rec = root['REC'];
    if (rec is List) {
      return rec.isNotEmpty;
    } else if (rec is Map) {
      final list = rec['list'];
      return list is List && list.isNotEmpty;
    }
    return false;
  }

  /// 예금(시험보험 등) 존재 여부 확인
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

    // “시험보험” 특정 상품만 확인하려면 아래 any 조건을 사용
    // return list.any((e) => e is Map && (e['accountName']?.toString() ?? '') == '시험보험');

    // 예금이 하나라도 있으면 true
    return list.isNotEmpty;
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
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

  /* 실제 서버 연동 시 사용할 코드*/
  Future<bool> _checkSavingsAccountFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';

      if (userKey.isEmpty) return false;

      final url = Uri.parse('$baseUrl/accounts/check-savings');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'userKey': userKey});

      final res = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['hasSavingsAccount'] ?? false) as bool;
      }
      return false;
    } catch (_) {
      return false;
    }
  }




  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
