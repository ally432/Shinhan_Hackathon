import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/step5_goal_setting_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isConsentDetailsVisible = false;

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

  Future<void> _saveAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userSchool', _schoolController.text);
    await prefs.setString('userMajor', _majorController.text);
    await prefs.setString('userStudentId', _studentIdController.text);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Step5GoalSettingScreen()),
      );
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
      onNext: _saveAndNavigate,
      isNextEnabled: _isButtonEnabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('재학 중인 학교 정보를 입력해 주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),

          const Text('학교명', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _schoolController,
            decoration: InputDecoration(
                hintText: 'OOO 대학교',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                fillColor: Colors.white,
                filled: true
            ),
          ),
          const SizedBox(height: 24),

          const Text('학번', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _studentIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: '12345678',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                fillColor: Colors.white,
                filled: true
            ),
          ),
          const SizedBox(height: 24),

          const Text('전공', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _majorController,
            decoration: InputDecoration(
                hintText: 'XXX 전공',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                fillColor: Colors.white,
                filled: true
            ),
          ),
          const SizedBox(height: 32),


          InkWell( // 리스트 전체를 탭 가능하도록 InkWell로 감쌈
            onTap: () {
              setState(() {
                _isConsentChecked = !_isConsentChecked;
                // _isConsentDetailsVisible = !_isConsentDetailsVisible;
              });
              _validateInput();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isConsentChecked ? Colors.blue[600]! : Colors.grey[300]!,
                  width: _isConsentChecked ? 1.5 : 1,
                ),
                boxShadow: [
                  if (_isConsentChecked)
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _isConsentChecked ? Colors.blue[600] : Colors.white,
                      borderRadius: BorderRadius.circular(8), // 네모난 모서리 둥글게
                      border: Border.all(
                        color: _isConsentChecked ? Colors.blue[600]! : Colors.grey[400]!,
                        width: 1.5,
                      ),
                    ),
                    child: _isConsentChecked
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '(필수) 성적 정보 제공 동의',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ),
                  Icon(
                    _isConsentDetailsVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_isConsentDetailsVisible)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Text(
                '제1조 (수집항목) \n  수집되는 정보는 학사 성적 등 학업 성취와 관련된 항목이다. \n제2조 (수집·이용 목적) \n  수집된 성적 정보는 금융 서비스 제공, 장학 혜택 심사, 맞춤형 서비스 안내 등 본 서비스의 운영 목적에 한하여 이용된다. \n제3조 (보관 및 관리) \n  성적 정보는 관련 법령에서 정한 기간 동안 안전하게 보관되며, 보안 관리 체계에 따라 보호된다.\n제4조 (제3자 제공) \n  동의 없이 제3자에게 제공되지 않으며, 법령상 의무가 있는 경우를 제외하고 외부로 유출되지 않는다. \n제5조 (동의 거부 권리) \n  귀하는 성적 정보 제공에 대한 동의를 거부할 권리가 있다. 다만, 동의를 거부할 경우 일부 서비스 이용이 제한될 수 있다.',

                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }
}