import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/step7_auth_confirm_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';

class Step6AccountVerifyScreen extends StatefulWidget {
  const Step6AccountVerifyScreen({super.key});

  @override
  State<Step6AccountVerifyScreen> createState() => _Step6AccountVerifyScreenState();
}

class _Step6AccountVerifyScreenState extends State<Step6AccountVerifyScreen> {
  final _accountController = TextEditingController();
  bool _isAccountVerified = false;
  bool _isLoading = false;
  bool _isVerifyButtonEnabled = false; // '확인' 버튼 활성화 상태

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_validateAccountInput);
  }

  // 계좌번호 입력 감지
  void _validateAccountInput() {
    // 숫자만 12자리일 때 '확인' 버튼 활성화
    final bool isInputValid = _accountController.text.length == 12 && int.tryParse(_accountController.text) != null;
    if (isInputValid != _isVerifyButtonEnabled) {
      setState(() {
        _isVerifyButtonEnabled = isInputValid;
      });
    }
  }

  // '확인' 버튼 눌렀을 때
  void _verifyAccount() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _isAccountVerified = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 계좌가 확인되었습니다.')),
      );
    });
  }

  void _showVideoCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('영상 통화 인증'),
        content: const Text('상담사 연결을 통해 비대면 인증을 시작합니다.\n(실제 영상 통화는 연결되지 않습니다.)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('연결')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '계좌 확인',
      nextButtonText: '다음',
      onNext: _isAccountVerified
          ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Step7AuthConfirmScreen()))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('본인 명의의 계좌를 인증해주세요.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          const Text('계좌번호', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _accountController,
                  enabled: !_isAccountVerified,
                  decoration: InputDecoration(
                    hintText: "'-' 없이 숫자 12자리 입력",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 12, // 12자리 제한
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  // '확인' 버튼 활성화 로직 수정
                  onPressed: _isLoading || _isAccountVerified || !_isVerifyButtonEnabled ? null : _verifyAccount,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('확인'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(child: Text('또는', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: _showVideoCallDialog,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('계좌가 없으신가요? (영상 통화 인증)'),
            ),
          )
        ],
      ),
    );
  }
}