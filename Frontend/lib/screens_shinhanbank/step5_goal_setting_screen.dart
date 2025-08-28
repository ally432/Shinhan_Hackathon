import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/step6_account_verify_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Step5GoalSettingScreen extends StatefulWidget {
  const Step5GoalSettingScreen({super.key});

  @override
  State<Step5GoalSettingScreen> createState() => _Step5GoalSettingScreenState();
}

class _Step5GoalSettingScreenState extends State<Step5GoalSettingScreen> {
  String? _semester1Goal;
  String? _semester2Goal;
  bool _isButtonEnabled = false;

  // ✅ 로컬 저장 키
  static const String kSem1GoalKey = 'goal_sem1';
  static const String kSem2GoalKey = 'goal_sem2';

  final List<String> gradeOptions = ['4.3', '4.0', '3.7'];

  @override
  void initState() {
    super.initState();
    _loadExistingGoals(); // ✅ 저장된 값 미리 불러오기
  }

  Future<void> _loadExistingGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _semester1Goal = prefs.getString(kSem1GoalKey);
      _semester2Goal = prefs.getString(kSem2GoalKey);
      _isButtonEnabled = _semester1Goal != null && _semester2Goal != null;
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    if (_semester1Goal != null) await prefs.setString(kSem1GoalKey, _semester1Goal!);
    if (_semester2Goal != null) await prefs.setString(kSem2GoalKey, _semester2Goal!);
  }

  void _validateInput() {
    final isInputValid = _semester1Goal != null && _semester2Goal != null;
    if (isInputValid != _isButtonEnabled) {
      setState(() => _isButtonEnabled = isInputValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '목표 설정',
      onNext: _isButtonEnabled
          ? () async {
        try {
          await _saveGoals(); // ✅ 로컬(SharedPreferences)에만 저장
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Step6AccountVerifyScreen()),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('목표 저장 실패: $e')),
          );
        }
      }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('달성하고 싶은 학기별 목표 학점을 설정해주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildGradeTable(),
          const SizedBox(height: 24),
          _buildDropdown('1학기 목표 학점', _semester1Goal, (v) {
            setState(() => _semester1Goal = v);
            _validateInput();
          }),
          const SizedBox(height: 24),
          _buildDropdown('2학기 목표 학점', _semester2Goal, (v) {
            setState(() => _semester2Goal = v);
            _validateInput();
          }),
        ],
      ),
    );
  }

  Widget _buildGradeTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('성적에 따른 차등 우대금리 (연 단위)', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _RateRow('4.3 ~ 4.5', '+0.15%'),
          Divider(),
          _RateRow('4.0 ~ 4.29', '+0.1%'),
          Divider(),
          _RateRow('3.7 ~ 3.99', '+0.05%'),
        ],
      ),
    );
  }

  Widget _buildDropdown(String title, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: const Text('선택'),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: gradeOptions
              .map((g) => DropdownMenuItem<String>(value: g, child: Text(g)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RateRow extends StatelessWidget {
  final String grade;
  final String rate;
  const _RateRow(this.grade, this.rate);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(grade),
          Text(rate, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
