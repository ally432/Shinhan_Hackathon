import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/step4_school_auth_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String _maskAccount(String a) {
  if (a.isEmpty) return '';
  if (a.length <= 4) return a;
  final last4 = a.substring(a.length - 4);
  return '**** **** **** $last4'; // 필요 시 규격에 맞게 변경
}


class AccountSelectionScreen extends StatefulWidget {
  const AccountSelectionScreen({super.key});

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  bool _hasSavingsAccount = false;
  String _accountNumber = '';
  String _selectedAccount = '';
  int _accountBalance = 0;               // 잔액 상태
  bool _loading = true;                  // ← 로딩 표시 원하면 사용
  String? _error;

  static const String baseUrl = 'http://10.0.2.2:8080'; // 서버 주소
  final NumberFormat _won = NumberFormat('#,##0', 'ko_KR'); // 통화 포맷

  @override
  void initState() {
    super.initState();
    _loadAccountFromServer(); // 서버에서 바로 읽기
  }


  Future<void> _checkAccountStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSavings = prefs.getBool('hasSavingsAccount') ?? false;
    final accountNum = prefs.getString('accountNumber') ?? '';

    setState(() {
      _hasSavingsAccount = hasSavings;
      _accountNumber = accountNum;
      if (hasSavings) {
        _selectedAccount = accountNum; // 기본으로 수시입출금 계좌 선택
      }
    });
  }

  Future<void> _loadAccountFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = prefs.getString('userKey') ?? '';

    if (userKey.isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasSavingsAccount = false;
        _accountNumber = '';
        _accountBalance = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    try {
      final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit')
          .replace(queryParameters: {'userKey': userKey});
      final res = await http.get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final rec = (data['REC'] as List?) ?? const [];

        if (rec.isNotEmpty) {
          final first = rec.first as Map<String, dynamic>;
          final accountNo = (first['accountNo'] ?? '').toString();
          final balanceStr = (first['accountBalance'] ?? '0').toString();
          final balance = int.tryParse(balanceStr) ?? 0;

          // 상태/캐시 반영
          await prefs.setBool('hasSavingsAccount', true);
          await prefs.setString('accountNumber', accountNo);

          setState(() {
            _loading = false;
            _hasSavingsAccount = true;
            _accountNumber = accountNo;
            _accountBalance = balance;
            _selectedAccount = accountNo; // 기본 선택
          });
        } else {
          // 계좌 없음
          await prefs.setBool('hasSavingsAccount', false);
          await prefs.remove('accountNumber');

          setState(() {
            _loading = false;
            _hasSavingsAccount = false;
            _accountNumber = '';
            _accountBalance = 0;
            _selectedAccount = '';
          });
        }
      } else {
        setState(() {
          _loading = false;
          _error = '계좌 조회 실패: ${res.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '네트워크 오류: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('송금 가입'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 진행 상태 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '정보입력',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Text(
                  '3/4',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 제목
            const Text(
              '어떤 계좌에서 출금할까요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // 계좌 선택 섹션
            const Text(
              '출금계좌',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // 수시입출금 계좌가 있을 때만 표시
            if (_hasSavingsAccount) ...[
              // 수시입출금 계좌 선택 토글
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAccount = _selectedAccount == _accountNumber ? '' : _accountNumber;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedAccount == _accountNumber
                          ? Colors.blue[600]!
                          : Colors.grey[300]!,
                      width: _selectedAccount == _accountNumber ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 계좌 아이콘
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 계좌 정보
                      // 계좌 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '신한 SOL 수시입출금',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              // 서버에서 가져온 계좌번호
                              _maskAccount(_accountNumber),                 // ← 변경
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '잔액: ${_won.format(_accountBalance)}원',    // ← 변경
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 선택 표시
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedAccount == _accountNumber
                              ? Colors.blue[600]
                              : Colors.white,
                          border: Border.all(
                            color: _selectedAccount == _accountNumber
                                ? Colors.blue[600]!
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _selectedAccount == _accountNumber
                            ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 추가 안내 메시지
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '수시입출금 계좌 개설이 완료되어 송금 서비스를 이용하실 수 있습니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 계좌가 없을 때 표시할 내용
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning_amber,
                        color: Colors.orange[600], size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      '사용 가능한 계좌가 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '송금 서비스를 이용하시려면\n수시입출금 계좌가 필요합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // 다음 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasSavingsAccount && _selectedAccount.isNotEmpty
                    ? _handleNext
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  _hasSavingsAccount ? '다음' : '계좌 개설 필요',
                  style: TextStyle(
                    color: _hasSavingsAccount && _selectedAccount.isNotEmpty
                        ? Colors.white
                        : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (_selectedAccount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('출금할 계좌를 선택해주세요.')),
      );
      return;
    }

    // 선택한 계좌 정보를 SharedPreferences에 저장
    _saveSelectedAccount();

    // step4_school_auth_screen으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Step4SchoolAuthScreen(),
      ),
    );
  }

  Future<void> _saveSelectedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccount', _selectedAccount);
  }
}