import 'package:flutter/material.dart';
import 'package:frontend_flutter_yj/screens/step5_goal_setting_screen.dart';
import 'package:frontend_flutter_yj/widgets/step_layout.dart';

class Step4SchoolAuthScreen extends StatefulWidget {
  const Step4SchoolAuthScreen({super.key});

  @override
  State<Step4SchoolAuthScreen> createState() => _Step4SchoolAuthScreenState();
}

class _Step4SchoolAuthScreenState extends State<Step4SchoolAuthScreen> {
  final _schoolController = TextEditingController();
  final _majorController = TextEditingController();
  final _studentIdController = TextEditingController(); // 학번 컨트롤러 추가
  bool _isConsentChecked = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _schoolController.addListener(_validateInput);
    _majorController.addListener(_validateInput);
    _studentIdController.addListener(_validateInput); // 학번 리스너 추가
  }

  void _validateInput() {
    final bool isInputValid = _schoolController.text.isNotEmpty &&
        _majorController.text.isNotEmpty &&
        _studentIdController.text.isNotEmpty && // 학번 입력 확인
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
    _studentIdController.dispose(); // 학번 컨트롤러 dispose
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
          const Text('학교명', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _schoolController,
            decoration: InputDecoration(
                hintText: '예: 싸피대학교',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 24),
          const Text('학번', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _studentIdController,
            decoration: InputDecoration(
                hintText: '예: 21167340',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none)),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          const Text('전공', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _majorController,
            decoration: InputDecoration(
                hintText: '예: 소프트웨어공학과',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CheckboxListTile(
              value: _isConsentChecked,
              onChanged: (value) {
                setState(() {
                  _isConsentChecked = value!;
                });
                _validateInput();
              },
              title: const Text('(필수) 성적 정보 제공 동의',
                  style: TextStyle(fontSize: 14)),
              secondary: InkWell(
                onTap: () {},
                child: const Text("보기", style: TextStyle(color: Colors.blue, fontSize: 12)),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          )
        ],
      ),
    );
  }
}