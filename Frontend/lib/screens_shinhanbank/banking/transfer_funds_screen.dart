import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/home_screen_fail.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';

class TransferFundsScreen extends StatefulWidget {
  final int amount;
  final Account account; // ✅ 해지 대상 계좌

  const TransferFundsScreen({
    super.key,
    required this.amount,
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

    // 실제로는 PIN 확인 로직이 필요하지만, 여기서는 생략하고 바로 해지 호출
    await _submitCloseDeposit();
  }

  Future<void> _submitCloseDeposit() async {
    setState(() => _submitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보(userKey)가 없습니다.');

      // 해지할 "예금" 계좌번호 (하이픈 제거)
      final accountNo = widget.account.accountNumber.replaceAll(RegExp(r'\D'), '');

      final uri = Uri.parse('$baseUrl/deposit/closeDeposit');
      final res = await http
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userKey': userKey, 'accountNo': accountNo}),
      )
          .timeout(const Duration(seconds: 7));

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      // 성공 판단: Header.responseCode == 'H0000' 기준
      bool success = true;
      try {
        final root = jsonDecode(res.body);
        final header = (root['Header'] ?? root['header'] ?? {}) as Map?;
        final code = header?['responseCode']?.toString() ?? '';
        success = code == 'H0000' || code.isEmpty; // 일부 샘플 대응
      } catch (_) {
        // 바디가 비어있거나 포맷이 달라도 200이면 성공 처리
      }

      if (!mounted) return;

      if (success) {
        // 홈으로 이동
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ 해지 완료: ${NumberFormat.currency(locale: "ko_KR", symbol: "").format(widget.amount)}원이 입금됩니다.',
            ),
          ),
        );
      } else {
        throw Exception('해지 실패(코드 확인 필요): ${res.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('해지 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
          Text(
            '해지 금액 ${NumberFormat.currency(locale: 'ko_KR', symbol: '').format(widget.amount)}원을 입금할 계좌를 입력해주세요.',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '해지 대상: ${widget.account.accountName} (${widget.account.accountNumber})',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 32),
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
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _accountController,
            onChanged: (_) => _validateInput(),
            decoration: const InputDecoration(
              hintText: "'-' 없이 계좌번호 입력",
              border: OutlineInputBorder(),
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
