import 'package:flutter/material.dart';
import 'package:frontend_flutter_yj/screens/home_screen_fail.dart';
import 'package:frontend_flutter_yj/widgets/step_layout.dart';
import 'package:intl/intl.dart';

class TransferFundsScreen extends StatefulWidget {
  final int amount;
  const TransferFundsScreen({super.key, required this.amount});

  @override
  State<TransferFundsScreen> createState() => _TransferFundsScreenState();
}

class _TransferFundsScreenState extends State<TransferFundsScreen> {
  final _accountController = TextEditingController();
  String? _selectedBank;
  bool _isButtonEnabled = false;

  void _validateInput() {
    setState(() {
      _isButtonEnabled = _accountController.text.isNotEmpty && _selectedBank != null;
    });
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 입력'),
        content: const TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '4자리 숫자'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ 해지 금액이 입금되었습니다.')),
            );
          }, child: const Text('확인')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '입금 계좌 입력',
      nextButtonText: '입금',
      onNext: _isButtonEnabled ? _showPasswordDialog : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('해지 금액 ${NumberFormat.currency(locale: 'ko_KR', symbol: '').format(widget.amount)}원을 입금할 계좌를 입력해주세요.',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            hint: const Text('은행 선택'),
            value: _selectedBank,
            onChanged: (value) {
              setState(() => _selectedBank = value);
              _validateInput();
            },
            items: ['신한은행', '국민은행', '우리은행', '하나은행'].map((bank) {
              return DropdownMenuItem(value: bank, child: Text(bank));
            }).toList(),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _accountController,
            onChanged: (value) => _validateInput(),
            decoration: const InputDecoration(
              hintText: "'-' 없이 계좌번호 입력",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}