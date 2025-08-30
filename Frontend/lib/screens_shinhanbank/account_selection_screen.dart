import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/step2_id_photo_screen.dart';
// import 'package:Frontend/screens_shinhanbank/home_screen_fail.dart';
// import 'package:Frontend/screens_shinhanbank/banking/interest_calc_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Frontend/widgets/step_layout.dart'; // StepLayout import

String _maskAccount(String a) {
  if (a.isEmpty) return '';
  return a;
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
  int _accountBalance = 0;
  bool _loading = true;
  String? _error;

  static const String baseUrl = 'http://211.188.50.244:8080';
  final NumberFormat _won = NumberFormat('#,##0', 'ko_KR');

  @override
  void initState() {
    super.initState();
    _loadAccountFromServer();
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

          await prefs.setBool('hasSavingsAccount', true);
          await prefs.setString('accountNumber', accountNo);

          setState(() {
            _loading = false;
            _hasSavingsAccount = true;
            _accountNumber = accountNo;
            _accountBalance = balance;
            _selectedAccount = accountNo;
          });
        } else {
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

  void _handleNext() {
    if (_selectedAccount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('출금할 계좌를 선택해주세요.')),
      );
      return;
    }
    _saveSelectedAccount();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Step2IdPhotoScreen(),
        // builder: (context) => const HomeFailScreen(),

      ),
    );
  }

  Future<void> _saveSelectedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccount', _selectedAccount);
  }


  @override
  Widget build(BuildContext context) {
    // 버튼의 상태와 텍스트를 결정하는 로직
    final isButtonEnabled = _hasSavingsAccount && _selectedAccount.isNotEmpty && _error == null;
    final buttonText = _hasSavingsAccount && _error == null ? '다음' : '계좌 개설 필요';

    return StepLayout(
      title: 'The 성적 UP 상품 가입',
      centerTitle: true,
      onNext: _handleNext,
      isNextEnabled: isButtonEnabled,
      nextButtonText: buttonText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          const Text(
            '어떤 계좌에서 출금할까요?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          // 계좌 선택 섹션
          const Text(
            '계좌 목록',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          // ✅ 화면 상태에 따라 다른 UI를 보여주는 로직은 그대로 유지
          // 로딩 중일 때
          if (_loading)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!), strokeWidth: 3)),
                  ),
                  const SizedBox(height: 24),
                  const Text('계좌 정보를 확인하고 있습니다...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text('잠시만 기다려 주세요', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            )
          // 에러가 있을 때
          else if (_error != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red[200]!)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 48),
                    const SizedBox(height: 16),
                    const Text('계좌 정보를 불러올 수 없습니다', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() { _loading = true; _error = null; });
                        _loadAccountFromServer();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('다시 시도', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          // 로딩 완료 - 수시입출금 계좌가 있을 때
          else if (_hasSavingsAccount)
              Column(
                children: [
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
                          color: _selectedAccount == _accountNumber ? Colors.blue[600]! : Colors.grey[300]!,
                          width: _selectedAccount == _accountNumber ? 2 : 1,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.account_balance_wallet, color: Colors.blue[600], size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('신한 SOL 수시입출금', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(_maskAccount(_accountNumber), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                Text('잔액: ${_won.format(_accountBalance)}원', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedAccount == _accountNumber ? Colors.blue[600] : Colors.white,
                              border: Border.all(color: _selectedAccount == _accountNumber ? Colors.blue[600]! : Colors.grey[400]!, width: 2),
                            ),
                            child: _selectedAccount == _accountNumber ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green[200]!)),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              '수시입출금 계좌가 존재하여 송금 서비스를 \n이용하실 수 있습니다.',
                              style: TextStyle(fontSize: 14, color: Colors.green[800]),
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),
                ],
              )
            // 로딩 완료 - 계좌가 없을 때
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange[200]!)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[600], size: 48),
                      const SizedBox(height: 16),
                      const Text('사용 가능한 계좌가 없습니다', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('송금 서비스를 이용하시려면\n수시입출금 계좌가 필요합니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}