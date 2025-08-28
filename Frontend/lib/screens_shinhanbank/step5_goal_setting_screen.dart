import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/step6_account_verify_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'goals_service.dart';

class Step5GoalSettingScreen extends StatefulWidget {
  const Step5GoalSettingScreen({super.key});
  @override
  State<Step5GoalSettingScreen> createState() => _Step5GoalSettingScreenState();
}

class _Step5GoalSettingScreenState extends State<Step5GoalSettingScreen> {
  String? _semester1Goal;
  String? _semester2Goal;
  bool _isButtonEnabled = false;
  bool _loading = true;

  final List<String> gradeOptions = ['4.3', '4.0', '3.7'];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = prefs.getString('userKey') ?? '';
    try {
      // 1) 서버에서 우선 로드
      final s = userKey.isEmpty ? null : await GoalsService.fetchFromServer(userKey);
      if (s != null) {
        _semester1Goal = s.goalSem1?.toStringAsFixed(1);
        _semester2Goal = s.goalSem2?.toStringAsFixed(1);
        // 로컬 캐시 동기화
        await GoalsService.saveLocal(userKey, _semester1Goal, _semester2Goal);
      } else {
        // 2) 서버에 없으면 로컬 캐시 폴백
        final l = userKey.isEmpty ? null : await GoalsService.loadLocal(userKey);
        _semester1Goal = l?.goalSem1?.toString();
        _semester2Goal = l?.goalSem2?.toString();
      }
    } finally {
      setState(() {
        _isButtonEnabled = _semester1Goal != null && _semester2Goal != null;
        _loading = false;
      });
    }
  }

  void _validateInput() {
    final ok = _semester1Goal != null && _semester2Goal != null;
    if (ok != _isButtonEnabled) setState(() => _isButtonEnabled = ok);
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '목표 설정',
      onNext: (!_loading && _isButtonEnabled)
          ? () async {
        final prefs = await SharedPreferences.getInstance();
        final userKey = prefs.getString('userKey') ?? '';
        double? p(String? s) => s == null ? null : double.tryParse(s);
        try {
          if (userKey.isNotEmpty) {
            // 서버 저장
            await GoalsService.upsertToServer(
                userKey, p(_semester1Goal), p(_semester2Goal));
            // 로컬 캐시 갱신
            await GoalsService.saveLocal(userKey, _semester1Goal, _semester2Goal);
          }
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Step6AccountVerifyScreen()),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('목표 저장 실패: $e')));
        }
      }
          : null,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

  Widget _buildGradeTable() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _buildDropdown(String title, String? value, ValueChanged<String?> onChanged) => Column(
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
        items: ['4.3', '4.0', '3.7']
            .map((g) => DropdownMenuItem<String>(value: g, child: Text(g)))
            .toList(),
        onChanged: onChanged,
      ),
    ],
  );
}

class _RateRow extends StatelessWidget {
  final String grade;
  final String rate;
  const _RateRow(this.grade, this.rate);
  @override
  Widget build(BuildContext context) => Padding(
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
