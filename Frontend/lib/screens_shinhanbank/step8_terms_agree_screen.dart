import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/registration_complete_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';

class Step8TermsAgreeScreen extends StatefulWidget {
  const Step8TermsAgreeScreen({super.key});

  @override
  State<Step8TermsAgreeScreen> createState() => _Step8TermsAgreeScreenState();
}

class _Step8TermsAgreeScreenState extends State<Step8TermsAgreeScreen> {
  bool _allAgreed = false;
  final Map<String, bool> _agreements = {
    '예금거래기본약관': false,
    '거치식예금약관': false,
    '쏠편한 정기예금 특약': false,
    '비과세종합저축 특약': false,
    '불법/탈법 차명거래 금지 설명 확인서': false,
  };
  bool _isButtonEnabled = false;

  // ######## 추가된 부분: 각 약관의 펼침 상태를 저장하는 변수 ########
  final Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    // ######## 추가된 부분: 약관 목록을 기반으로 펼침 상태 변수 초기화 ########
    _agreements.keys.forEach((key) {
      _isExpanded[key] = false;
    });
    _validateInput();
  }

  void _validateInput() {
    final isAllChecked = _agreements.values.every((item) => item == true);
    if (isAllChecked != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isAllChecked;
      });
    }
    if(isAllChecked != _allAgreed) {
      setState(() {
        _allAgreed = isAllChecked;
      });
    }
  }

  void _toggleAllAgreed(bool? value) {
    setState(() {
      _allAgreed = value ?? false;
      _agreements.updateAll((key, _) => _allAgreed);
      _validateInput();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '약관 동의',
      nextButtonText: '완료',
      onNext: _isButtonEnabled
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegistrationCompleteScreen()),
        );
      }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('예금 가입을 위해 약관에 동의해주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildOverallAgreement(),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _agreements.keys.map((title) {
                // 수정된 _buildAgreementTile 함수를 호출합니다.
                return _buildAgreementTile(title);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallAgreement() {
    return InkWell(
      onTap: () => _toggleAllAgreed(!_allAgreed),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _allAgreed ? Icons.check_circle : Icons.check_circle_outline,
              color: _allAgreed ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('전체 동의', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ######## 수정된 부분: 상세 내용을 포함하도록 구조 변경 ########
  Widget _buildAgreementTile(String title) {
    return Column(
      children: [
        CheckboxListTile(
          value: _agreements[title],
          onChanged: (bool? value) {
            setState(() {
              _agreements[title] = value ?? false;
            });
            _validateInput();
          },
          title: Text('[필수] $title', style: const TextStyle(fontSize: 14)),
          // 오른쪽 아이콘을 누를 수 있도록 InkWell로 감싸줍니다.
          secondary: InkWell(
            onTap: () {
              // 아이콘을 누르면 펼침/접힘 상태를 변경합니다.
              setState(() {
                _isExpanded[title] = !(_isExpanded[title] ?? false);
              });
            },
            child: Icon(
              // 펼침 상태에 따라 아이콘 모양을 변경합니다.
              _isExpanded[title] == true
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.grey,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.only(left: 4.0, right: 16.0),
        ),
        // isExpanded가 true일 때만 상세 내용을 보여줍니다.
        if (_isExpanded[title] == true)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            color: Colors.white,
            child: Text(
              '이것은 "$title"에 대한 상세 약관 내용입니다. 사용자는 이 약관에 동의함으로써 발생하는 모든 법적 효력을 인지하였으며...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }
}