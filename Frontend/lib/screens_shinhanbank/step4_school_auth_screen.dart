import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/step5_goal_setting_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';

class Step4SchoolAuthScreen extends StatefulWidget {
  const Step4SchoolAuthScreen({super.key});

  @override
  State<Step4SchoolAuthScreen> createState() => _Step4SchoolAuthScreenState();
}

class _Step4SchoolAuthScreenState extends State<Step4SchoolAuthScreen> {
  final _schoolController = TextEditingController();
  final _majorController = TextEditingController();
  final _studentIdController = TextEditingController();
  bool _isConsentChecked = false;
  bool _isButtonEnabled = false;
  bool _isConsentDetailsVisible = false; // 약관 상세 내용 표시 여부 상태

  @override
  void initState() {
    super.initState();
    _schoolController.addListener(_validateInput);
    _majorController.addListener(_validateInput);
    _studentIdController.addListener(_validateInput);
  }

  void _validateInput() {
    final bool isInputValid = _schoolController.text.isNotEmpty &&
        _majorController.text.isNotEmpty &&
        _studentIdController.text.isNotEmpty &&
        _isConsentChecked;
    if (isInputValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isInputValid;
      });
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _majorController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '학교 인증',
      onNext: _isButtonEnabled
          ? () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => const Step5GoalSettingScreen()))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('재학중인 학교 정보를 입력해주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          // ... 학교명, 학번, 전공 TextField 부분은 이전과 동일 ...
          const Text('학교명', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _schoolController),
          const SizedBox(height: 24),
          const Text('학번', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _studentIdController, keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          const Text('전공', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _majorController),
          const SizedBox(height: 32),
          // 성적 정보 제공 동의 UI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _isConsentChecked,
                  onChanged: (value) {
                    setState(() { _isConsentChecked = value!; });
                    _validateInput();
                  },
                  title: const Text('(필수) 성적 정보 제공 동의', style: TextStyle(fontSize: 14)),
                  secondary: InkWell(
                    onTap: () {
                      // '보기' 버튼을 누르면 상태 변경
                      setState(() {
                        _isConsentDetailsVisible = !_isConsentDetailsVisible;
                      });
                    },
                    child: Text(
                      _isConsentDetailsVisible ? "접기" : "보기", // 상태에 따라 텍스트 변경
                      style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                // _isConsentDetailsVisible가 true일 때만 상세 내용을 보여줌
                if (_isConsentDetailsVisible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      '제1조(수집항목) ... 수집된 성적 정보는 금융 서비스 제공 목적으로만 사용되며, 제3자에게 제공되지 않습니다. ... (상세 약관 내용)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}