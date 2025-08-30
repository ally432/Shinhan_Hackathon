// lib/screens_shinhanbank/banking/achievement_result_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://211.188.50.244:8080';

class AchievementResultScreen extends StatefulWidget {
  final int principal; // 원금
  final int days;      // 기간 (일수)

  const AchievementResultScreen({
    super.key,
    required this.principal,
    required this.days,
  });

  @override
  State<AchievementResultScreen> createState() => _AchievementResultScreenState();
}

class _AchievementResultScreenState extends State<AchievementResultScreen> {
  bool _loading = true;
  String _error = '';
  final _currency = NumberFormat.currency(locale: 'ko_KR', symbol: '');
  final List<GradeRecordDto?> _records = [null, null];
  late final List<Term> _terms;
  TargetScoreDto? _target;

  @override
  void initState() {
    super.initState();
    _terms = _targetTerms(DateTime.now());
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보(userKey)가 없습니다.');

      TargetScoreDto? srv = await _fetchGoalsFromServer(userKey);
      if (srv != null) {
        _target = srv;
        await _saveGoalsLocal(userKey, srv);
      } else {
        _target = await _loadGoalsLocal(userKey);
      }

      for (int i = 0; i < _terms.length; i++) {
        final t = _terms[i];
        final uri = Uri.parse('$baseUrl/api/grades/record').replace(queryParameters: {
          'userKey': userKey,
          'year': t.year.toString(),
          'semester': t.semester.toString(),
        });
        final res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 7));
        if (res.statusCode == 200) {
          final root = jsonDecode(res.body);
          final r = root['record'] ?? root['REC'] ?? root;
          _records[i] = (r is Map<String, dynamic>) ? GradeRecordDto.fromJson(r) : null;
        } else {
          _records[i] = null;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxBonusRate = _maxAppliedBonusRate();
    final bonusAmount = _calculateBonusAmount(maxBonusRate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('성적 달성 결과')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _loading || _error.isNotEmpty
                ? null
                : () => Navigator.pop(context, bonusAmount),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue[800],
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _loading ? '계산 중...' : '${_currency.format(bonusAmount)}원 이자 반영하기',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _error.isNotEmpty
            ? _errorBox(_error)
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryBonusBar(maxBonusRate),
            const SizedBox(height: 16),
            ListView.separated(
              itemCount: _terms.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                return _gradeCard(term: _terms[i], record: _records[i]);
              },
            ),
          ],
        ),
      ),
    );
  }

  double _maxAppliedBonusRate() {
    double maxB = 0.0;
    for (int i = 0; i < _terms.length; i++) {
      final goal = _goalFor(_terms[i]);
      final gpa = _records[i]?.totalGpa;
      final b = _bonusFor(goal, gpa) ?? 0.0;
      if (b > maxB) maxB = b;
    }
    return maxB;
  }

  int _calculateBonusAmount(double bonusRate) {
    if (bonusRate <= 0) return 0;
    final interest = (widget.principal * (bonusRate / 100) / 365.0) * widget.days;
    return interest.round();
  }

  List<Term> _targetTerms(DateTime now) {
    final y = now.year, m = now.month;
    if (m <= 2) return [Term(y - 1, 2), Term(y - 1, 1)];
    if (m <= 8) return [Term(y, 1), Term(y - 1, 2)];
    return [Term(y, 2), Term(y, 1)];
  }

  Future<TargetScoreDto?> _fetchGoalsFromServer(String userKey) async {
    final uri = Uri.parse('$baseUrl/api/target-score').replace(queryParameters: {'userKey': userKey});
    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 7));
      if (res.statusCode == 200) return TargetScoreDto.fromJson(jsonDecode(res.body));
    } catch (_) {}
    return null;
  }

  Future<TargetScoreDto?> _loadGoalsLocal(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    double? parse(String? s) => (s == null || s.trim().isEmpty) ? null : double.tryParse(s.trim());
    final g1 = parse(prefs.getString('goal:$userKey:sem1'));
    final g2 = parse(prefs.getString('goal:$userKey:sem2'));
    return (g1 == null && g2 == null) ? null : TargetScoreDto(goalSem1: g1, goalSem2: g2);
  }

  Future<void> _saveGoalsLocal(String userKey, TargetScoreDto t) async {
    final prefs = await SharedPreferences.getInstance();
    if (t.goalSem1 != null) await prefs.setString('goal:$userKey:sem1', t.goalSem1!.toStringAsFixed(2));
    if (t.goalSem2 != null) await prefs.setString('goal:$userKey:sem2', t.goalSem2!.toStringAsFixed(2));
  }

  double? _goalFor(Term t) => t.semester == 1 ? _target?.goalSem1 : _target?.goalSem2;
  String _fmtScore(double? v) => v == null ? '-' : v.toStringAsFixed(2);
  double? _bonusFor(double? target, double? gpa) {
    if (target == null || gpa == null) return null;
    final t = double.parse(target.toStringAsFixed(2));
    final g = double.parse(gpa.toStringAsFixed(2));
    bool ge(num x) => g + 1e-9 >= x;
    if ((t - 3.70).abs() < 0.005) return ge(3.70) ? 0.05 : 0.0;
    if ((t - 4.00).abs() < 0.005) return ge(4.00) ? 0.10 : 0.0;
    if ((t - 4.30).abs() < 0.005) return ge(4.30) ? 0.15 : 0.0;
    return 0.0;
  }
  String _fmtBonus(double? b) {
    if (b == null) return '-';
    if (b == 0.0) return '없음';
    return '+ ${b.toStringAsFixed(2)}%p';
  }

  Widget _errorBox(String msg) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.withOpacity(.2)),
    ),
    child: Text(msg, style: const TextStyle(color: Colors.red)),
  );

  Widget _summaryBonusBar(double maxBonusRate) {
    final text = maxBonusRate > 0
        ? '적용 추가 이자율: + ${maxBonusRate.toStringAsFixed(2)}%p (두 학기 중 최대치 1회 적용)'
        : '적용 추가 이자율: 없음';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: maxBonusRate > 0 ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: maxBonusRate > 0 ? Colors.green[200]! : Colors.grey[300]!),
      ),
      child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
    );
  }

  Widget _gradeCard({required Term term, GradeRecordDto? record}) {
    final goal = _goalFor(term);
    final achieved = (record?.totalGpa != null && goal != null) ? (record!.totalGpa! >= goal) : null;
    final bonus = _bonusFor(goal, record?.totalGpa);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${term.year}년 ${term.semester}학기', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 16),
          if (record == null)
            const Text('해당 학기 성적 데이터가 없습니다.', style: TextStyle(color: Colors.black54))
          else ...[
            _row('총 이수학점', record.totalCredits?.toString() ?? '-'),
            _row('GPA (4.5만점)', _fmtScore(record.totalGpa)),
          ],
          const Divider(height: 16, indent: 8, endIndent: 8),
          _row('목표 성적', _fmtScore(goal)),
          if (achieved != null) _row('달성 여부', achieved ? '달성' : '미달성'),
          if (record != null) _row('적용 이자율 (해당 학기)', _fmtBonus(bonus)),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: TextStyle(color: Colors.grey[700])),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class Term {
  final int year;
  final int semester;
  Term(this.year, this.semester);
}

class GradeRecordDto {
  final double? totalGpa;
  final int? totalCredits;
  final String? type;
  GradeRecordDto({this.totalGpa, this.totalCredits, this.type});

  factory GradeRecordDto.fromJson(Map<String, dynamic> j) {
    double? toDouble(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v.toString().replaceAll(',', '.'));
    int? toInt(dynamic v) => (v is int) ? v : int.tryParse(v.toString().replaceAll(RegExp(r'[^\d-]'), ''));
    return GradeRecordDto(
      totalGpa: toDouble(j['totalGpa']),
      totalCredits: toInt(j['totalCredits']),
      type: j['type']?.toString(),
    );
  }
}

class TargetScoreDto {
  final double? goalSem1;
  final double? goalSem2;
  TargetScoreDto({this.goalSem1, this.goalSem2});

  factory TargetScoreDto.fromJson(Map<String, dynamic> j) {
    double? toDouble(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v.toString().replaceAll(',', '.'));
    return TargetScoreDto(
      goalSem1: toDouble(j['goalSem1'] ?? j['goal_sem1']),
      goalSem2: toDouble(j['goalSem2'] ?? j['goal_sem2']),
    );
  }
}