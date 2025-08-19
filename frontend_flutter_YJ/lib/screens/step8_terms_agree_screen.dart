import 'package:flutter/material.dart';
import 'package:frontend_flutter_yj/screens/registration_complete_screen.dart';
import 'package:frontend_flutter_yj/widgets/step_layout.dart';

class Step8TermsAgreeScreen extends StatefulWidget {
  const Step8TermsAgreeScreen({super.key});

  @override
  State<Step8TermsAgreeScreen> createState() => _Step8TermsAgreeScreenState();
}

class _Step8TermsAgreeScreenState extends State<Step8TermsAgreeScreen> {
  // 체크박스 상태 변수
  bool _allAgreed = false;
  bool _agreement1 = false; // 필수 1
  bool _agreement2 = false; // 필수 2

  // 버튼 활성화 상태 변수
  bool _isButtonEnabled = false;

  // 각 약관의 펼침/접힘 상태 변수
  bool _isAgreement1Expanded = false;
  bool _isAgreement2Expanded = false;

  // 버튼 활성화 여부를 검증하는 함수
  void _validateInput() {
    // 필수 약관이 모두 동의되었는지 확인
    final bool isInputValid = _agreement1 && _agreement2;
    if (isInputValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isInputValid;
      });
    }
    // 전체 동의 체크박스 상태도 실제 값에 맞춰 업데이트
    setState(() {
      _allAgreed = _agreement1 && _agreement2;
    });
  }

  // 약관 항목 UI를 만드는 함수
  Widget _buildAgreementItem({
    required String title,
    required bool isChecked,
    required ValueChanged<bool?> onChecked,
    required bool isExpanded,
    required VoidCallback onExpand,
    required String content,
  }) {
    return Column(
      children: [
        CheckboxListTile(
          value: isChecked,
          onChanged: onChecked,
          title: Text(title, style: const TextStyle(fontSize: 14)),
          secondary: InkWell(
            onTap: onExpand,
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.grey,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '약관 동의',
      nextButtonText: '완료',
      onNext: _isButtonEnabled
          ? () {
        // '가입 완료' 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const RegistrationCompleteScreen()),
        );
      }
          : null, // 버튼 비활성화
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
                _buildAgreementItem(
                  title: '(필수) 개인정보 처리방침',
                  isChecked: _agreement1,
                  onChecked: (value) {
                    setState(() => _agreement1 = value!);
                    _validateInput();
                  },
                  isExpanded: _isAgreement1Expanded,
                  onExpand: () =>
                      setState(() => _isAgreement1Expanded = !_isAgreement1Expanded),
                  content: '개인정보 처리방침 상세 내용입니다. ...',
                ),
                _buildAgreementItem(
                  title: '(필수) 서비스 이용약관',
                  isChecked: _agreement2,
                  onChecked: (value) {
                    setState(() => _agreement2 = value!);
                    _validateInput();
                  },
                  isExpanded: _isAgreement2Expanded,
                  onExpand: () =>
                      setState(() => _isAgreement2Expanded = !_isAgreement2Expanded),
                  content: '서비스 이용약관 상세 내용입니다. ...',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}