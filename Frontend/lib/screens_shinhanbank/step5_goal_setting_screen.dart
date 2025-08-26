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
  static const String kSem1GoalKey = 'goal_sem1';
  static const String kSem2GoalKey = 'goal_sem2';

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    if (_semester1Goal != null) await prefs.setString(kSem1GoalKey, _semester1Goal!);
    if (_semester2Goal != null) await prefs.setString(kSem2GoalKey, _semester2Goal!);
  }

  final List<String> gradeOptions = ['4.5', '4.3', '4.0', '3.7', '3.5'];

  void _validateInput() {
    final bool isInputValid = _semester1Goal != null && _semester2Goal != null;
    if (isInputValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isInputValid;
      });
    }
  }

  Widget _buildGradeTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('성적에 따른 차등 우대금리 (연 단위)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTableRow('4.3 ~ 4.5', '+0.15%'),
          const Divider(),
          _buildTableRow('4.0 ~ 4.29', '+0.1%'),
          const Divider(),
          _buildTableRow('3.7 ~ 3.99', '+0.05%'),
        ],
      ),
    );
  }

  Widget _buildTableRow(String grade, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(grade), Text(rate, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))],
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
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          items: gradeOptions.map((String grade) {
            return DropdownMenuItem<String>(value: grade, child: Text(grade));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '목표 설정',
      onNext: _isButtonEnabled
          ? () async {
        await _saveGoals();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Step6AccountVerifyScreen()),
        );
      }
          : null,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('달성하고 싶은 학기별 목표 학점을 설정해주세요.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildGradeTable(),
          const SizedBox(height: 24),
          _buildDropdown('1학기 목표 학점', _semester1Goal, (newValue) {
            setState(() => _semester1Goal = newValue);
            _validateInput();
          }),
          const SizedBox(height: 24),
          _buildDropdown('2학기 목표 학점', _semester2Goal, (newValue) {
            setState(() => _semester2Goal = newValue);
            _validateInput();
          }),
        ],
      ),
    );
  }
}