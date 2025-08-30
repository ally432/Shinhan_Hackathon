import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/home_screen.dart' as success;
import 'package:Frontend/screens_shinhanbank/home_screen_fail.dart' as fail;
import 'package:Frontend/widgets/step_layout.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://211.188.50.244:8080';

class TransferFundsScreen extends StatefulWidget {
  final int amount;            // 기본 해지금(원금+정상이자)
  final int bonusAmount;       // ✅ 추가 이자(달성)
  final Account account;       // 해지 대상 계좌

  const TransferFundsScreen({
    super.key,
    required this.amount,
    this.bonusAmount = 0,      // ✅ 기본 0
    required this.account,
  });

  @override
  State<TransferFundsScreen> createState() => _TransferFundsScreenState();
}

class _TransferFundsScreenState extends State<TransferFundsScreen> {
  final _accountController = TextEditingController();
  String? _selectedBank;
  bool _isButtonEnabled = false;
  bool _submitting = false;

  final _currency = NumberFormat.currency(locale: 'ko_KR', symbol: '');

  int get _totalPayout => widget.amount + widget.bonusAmount;

  void _validateInput() {
    setState(() {
      _isButtonEnabled =
          _accountController.text.isNotEmpty && _selectedBank != null;
    });
  }

  Future<void> _showPasswordAndSubmit() async {
    String pin = '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 입력'),
        content: TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          onChanged: (v) => pin = v,
          decoration: const InputDecoration(hintText: '4자리 숫자'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인')),
        ],
      ),
    );

    if (ok != true) return;

    // 실제 핀 검증 로직은 생략
    await _submitCloseDepositAndBonus();
  }

  Future<void> _submitCloseDepositAndBonus() async {
    if (_submitting) return;                // 재진입 방지
    setState(() => _submitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보(userKey)가 없습니다.');

      // 1) 예금 해지
      final tdAccountNo = widget.account.accountNumber.replaceAll(RegExp(r'\D'), '');
      final closeUri = Uri.parse('$baseUrl/deposit/closeDeposit');
      final closeRes = await http.post(
        closeUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userKey': userKey, 'accountNo': tdAccountNo}),
      ).timeout(const Duration(seconds: 7));

      if (closeRes.statusCode != 200) {
        throw Exception('해지 실패: HTTP ${closeRes.statusCode}: ${closeRes.body}');
      }
      bool closeOk = true;
      try {
        final root = jsonDecode(closeRes.body);
        final header = (root['Header'] ?? root['header'] ?? {}) as Map?;
        final code = header?['responseCode']?.toString() ?? '';
        closeOk = code == 'H0000' || code.isEmpty;
      } catch (_) {}
      if (!closeOk) throw Exception('해지 실패(코드 확인 필요): ${closeRes.body}');

      // 2) 보너스 입금 —❗️단 1회만 호출
      bool bonusOk = true;
      if (widget.bonusAmount > 0) {
        bonusOk = await _depositBonusToDemand(userKey, widget.bonusAmount);
      }
      if (!mounted) return;

      // 3) 안내 메시지
      final baseStr  = _currency.format(widget.amount);
      final bonusStr = _currency.format(widget.bonusAmount);
      final totalStr = _currency.format(_totalPayout);
      final msg = '✅ 해지 완료: ${baseStr}원 입금 처리되었습니다.';

      Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const success.HomeScreen()),
                (route) => false,);

      // Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (_) => const fail.HomeFailScreen()),
      //           (route) => false,
      //     );

      // // 4) 내비게이션 (성공/실패 분기)
      // if (bonusOk) {
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (_) => const success.HomeScreen()),
      //         (route) => false,
      //   );
      // } else {
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (_) => const fail.HomeScreen()),
      //         (route) => false,
      //   );
      // }

      // (선택) 목적지 화면에서 스낵바 띄우고 싶으면 파라미터로 메시지 넘겨서 거기서 표시하세요.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('처리 실패: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// 추가 이자를 입력한 수시입출금 계좌로 입금 (성공/실패 반환)
  Future<bool> _depositBonusToDemand(String userKey, int bonusAmount) async {
    final destBank = _selectedBank;
    final destAcc  = _accountController.text.replaceAll(RegExp(r'\D'), '');

    if (destBank == null || destAcc.isEmpty) {
      throw Exception('입금 계좌 정보를 확인하세요.');
    }

    final uri = Uri.parse('$baseUrl/demand/deposit');

    final res = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userKey': userKey,
        'bankName': destBank,
        'accountNo': destAcc,
        'amount': bonusAmount,
        'memo': '학기 목표 달성 보너스 이자'
      }),
    )
        .timeout(const Duration(seconds: 7));

    if (res.statusCode != 200) return false;

    try {
      final root = jsonDecode(res.body);
      if (root is Map && root['success'] == true) return true;
    } catch (_) {/* ignore */}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '입금 계좌 입력',
      nextButtonText: _submitting ? '처리중...' : '입금',
      onNext: (_isButtonEnabled && !_submitting) ? _showPasswordAndSubmit : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   // 요약 안내
          //   '해지 금액 ${_currency.format(widget.amount)}원'
          //       '${widget.bonusAmount > 0 ? ' + 추가 이자 ${_currency.format(widget.bonusAmount)}원' : ''}\n'
          //       '총 입금액: ${_currency.format(_totalPayout)}원',
          //   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   '해지 대상: ${widget.account.accountName} (${widget.account.accountNumber})',
          //   style: TextStyle(color: Colors.grey[700]),
          // ),
          // const SizedBox(height: 24),

          // 목적지(수시입출금) 정보
          DropdownButtonFormField<String>(
            hint: const Text('은행 선택'),
            value: _selectedBank,
            onChanged: (value) {
              setState(() => _selectedBank = value);
              _validateInput();
            },
            items: ['신한은행', '국민은행', '우리은행', '하나은행']
                .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                .toList(),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    fillColor: Colors.white,
                    filled: true
                ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountController,
            onChanged: (_) => _validateInput(),
            decoration: InputDecoration(
                hintText: "'-' 없이 수시입출금 계좌번호 입력",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                fillColor: Colors.white,
                filled: true
            ),
            keyboardType: TextInputType.number,
          ),

          if (_submitting) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
