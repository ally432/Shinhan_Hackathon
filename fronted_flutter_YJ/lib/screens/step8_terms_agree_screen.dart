import 'package:flutter/material.dart';
import 'package:frontend_flutter_yj/widgets/step_layout.dart';

class Step8TermsAgreeScreen extends StatefulWidget {
  const Step8TermsAgreeScreen({super.key});

  @override
  State<Step8TermsAgreeScreen> createState() => _Step8TermsAgreeScreenState();
}

class _Step8TermsAgreeScreenState extends State<Step8TermsAgreeScreen> {
  bool _allAgreed = false;
  bool _agreement1 = false; // 필수 1
  bool _agreement2 = false; // 필수 2
  bool _isButtonEnabled = false;

  void _validateInput() {
    // 필수 약관이 모두 동의되었는지 확인
    final bool isInputValid = _agreement1 && _agreement2;
    if (isInputValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isInputValid;
      });
    }
    // 전체 동의 체크박스 상태도 업데이트
    setState(() {
      _allAgreed = _agreement1 && _agreement2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '약관 동의',
      nextButtonText: '완료',
      onNext: _isButtonEnabled
          ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('시험 보험 가입이 완료되었습니다!')),
        );
        // popUntil을 사용해 스택의 맨 처음 화면(Step1) 이전까지 모든 화면을 제거
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('서비스 이용을 위해 약관에 동의해주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _allAgreed,
                  onChanged: (value) {
                    setState(() {
                      _allAgreed = value!;
                      _agreement1 = value;
                      _agreement2 = value;
                    });
                    _validateInput();
                  },
                  title: const Text('약관 전체동의',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  value: _agreement1,
                  onChanged: (value) {
                    setState(() => _agreement1 = value!);
                    _validateInput();
                  },
                  title: const Text('(필수) 개인정보 처리방침',
                      style: TextStyle(fontSize: 14)),
                  secondary: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ),
                CheckboxListTile(
                  value: _agreement2,
                  onChanged: (value) {
                    setState(() => _agreement2 = value!);
                    _validateInput();
                  },
                  title: const Text('(필수) 서비스 이용약관',
                      style: TextStyle(fontSize: 14)),
                  secondary: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}