import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';
const String kSem1GoalKey = 'goal_sem1';
const String kSem2GoalKey = 'goal_sem2';

class AchievementResultScreen extends StatefulWidget {
  const AchievementResultScreen({super.key});

  @override
  State<AchievementResultScreen> createState() => _AchievementResultScreenState();
}

// --- 상태 추가 ---
TargetScoreDto? _target; // 목표 성적(1,2학기)

// --- 목표성적 DTO ---
class TargetScoreDto {
  final double? goalSem1;
  final double? goalSem2;
  TargetScoreDto({this.goalSem1, this.goalSem2});

  factory TargetScoreDto.fromJson(Map<String, dynamic> j) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().replaceAll(',', '.');
      return double.tryParse(s);
    }
    // goalSem1 / goal_sem1 둘 다 대응
    return TargetScoreDto(
      goalSem1: toDouble(j['goalSem1'] ?? j['goal_sem1']),
      goalSem2: toDouble(j['goalSem2'] ?? j['goal_sem2']),
    );
  }
}

class _AchievementResultScreenState extends State<AchievementResultScreen> {
  bool _loading = true;
  String _error = '';
  final List<GradeRecordDto?> _records = [null, null]; // [최근1, 최근2]
  late final List<Term> _terms;

  @override
  void initState() {
    super.initState();
    _terms = _targetTerms(DateTime.now());
    _load();
  }

  // ✅ 달력 규칙: 1~2월 -> (Y-1,2),(Y-1,1) / 3~8월 -> (Y,1),(Y-1,2) / 9~12월 -> (Y,2),(Y,1)
  List<Term> _targetTerms(DateTime now) {
    final y = now.year;
    final m = now.month;
    if (m <= 2) return [Term(y - 1, 2), Term(y - 1, 1)];
    if (m <= 8) return [Term(y, 1), Term(y - 1, 2)];
    return [Term(y, 2), Term(y, 1)];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보(userKey)가 없습니다.');

      // 🔹 목표성적 조회
      double? _parseGoal(String? s) =>
          (s == null || s.trim().isEmpty) ? null : double.tryParse(s.trim());

      final g1 = _parseGoal(prefs.getString(kSem1GoalKey));
      final g2 = _parseGoal(prefs.getString(kSem2GoalKey));

      // 화면에서 기존 TargetScoreDto 타입 그대로 쓰고 있으므로 맞춰서 세팅
      _target = TargetScoreDto(goalSem1: g1, goalSem2: g2);

      // 두 학기를 각각 조회
      for (int i = 0; i < _terms.length; i++) {
        final t = _terms[i];
        final uri = Uri.parse('$baseUrl/api/grades/record').replace(queryParameters: {
          'userKey': userKey,
          'year': t.year.toString(),
          'semester': t.semester.toString(),
        });

        final res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(
          const Duration(seconds: 7),
        );

        if (res.statusCode == 200) {
          dynamic root;
          try { root = jsonDecode(res.body); } catch (_) { root = res.body; }

          // 서버 응답이 {record:{...}} 혹은 바로 {...} 인 경우 모두 대응
          Map<String, dynamic>? map;
          if (root is Map<String, dynamic>) {
            final r = root['record'] ?? root['REC'] ?? root;
            if (r is Map<String, dynamic>) map = r;
          }
          _records[i] = map == null ? null : GradeRecordDto.fromJson(map);
        } else if (res.statusCode == 404) {
          _records[i] = null; // 해당 학기 데이터 없음
        } else {
          throw Exception('HTTP ${res.statusCode} ${res.body}');
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
    return Scaffold(
      appBar: AppBar(title: const Text('성적 달성 결과')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: _error.isNotEmpty
            ? _errorBox(_error)
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryBonusBar(),           // ✅ 요약 배너
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _terms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final t = _terms[i];
                  final r = _records[i];
                  return _gradeCard(term: t, record: r);
                },
              ),
            ),
          ],
        ),
      ),
    );
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

  double? _goalFor(Term t) {
    if (_target == null) return null;
    return t.semester == 1 ? _target!.goalSem1 : _target!.goalSem2;
  }

  String _fmtScore(double? v) => v == null ? '-' : v.toStringAsFixed(2);

// 목표: 3.70 → GPA ≥ 3.70 이면 +0.05
//      4.00 → GPA ≥ 4.00 이면 +0.10
//      4.30 → GPA ≥ 4.30 이면 +0.15
// 그 외 목표치는 보너스 없음
  double? _bonusFor(double? target, double? gpa) {
    if (target == null || gpa == null) return null;

    final t = double.parse(target.toStringAsFixed(2));
    final g = double.parse(gpa.toStringAsFixed(2));
    bool ge(num x) => g + 1e-9 >= x; // g >= x

    if ((t - 3.70).abs() < 0.005) return ge(3.70) ? 0.05 : 0.0;
    if ((t - 4.00).abs() < 0.005) return ge(4.00) ? 0.10 : 0.0;
    if ((t - 4.30).abs() < 0.005) return ge(4.30) ? 0.15 : 0.0;
    return 0.0;
  }


  String _fmtBonus(double? b) {
    if (b == null) return '-';         // 목표 자체가 없음
    if (b == 0.0) return '없음';        // 초과/미달(또는 규칙 없음)
    return '+ ${b.toStringAsFixed(2)}%'; // p = 퍼센트포인트
  }

  double _maxAppliedBonus() {
    double maxB = 0.0;
    for (int i = 0; i < _terms.length; i++) {
      final goal = _goalFor(_terms[i]);
      final gpa = _records[i]?.totalGpa;
      final b = _bonusFor(goal, gpa) ?? 0.0;
      if (b > maxB) maxB = b;
    }
    return maxB;
  }

  Widget _summaryBonusBar() {
    final maxB = _maxAppliedBonus();
    final text = maxB > 0
        ? '적용 추가 이자율: + ${maxB.toStringAsFixed(2)}p (두 학기 중 최대치 1회 적용)'
        : '적용 추가 이자율: 없음';
    final bg = maxB > 0 ? Colors.green[50] : Colors.grey[100];
    final bd = maxB > 0 ? Colors.green[200]! : Colors.grey[300]!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bd),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _gradeCard({required Term term, GradeRecordDto? record}) {
    final goal = _goalFor(term);
    final achieved = (record?.totalGpa != null && goal != null)
        ? (record!.totalGpa! >= goal) : null;

    final bonus = _bonusFor(goal, record?.totalGpa); // 해당 학기 보너스

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0,2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${term.year}년 ${term.semester}학기',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          if (record == null)
            const Text('해당 학기 성적 데이터가 없습니다.', style: TextStyle(color: Colors.black54))
          else ...[
            _row('총 이수학점', record.totalCredits?.toString() ?? '-'),
            _row('GPA(4.5)', _fmtScore(record.totalGpa)),
          ],

          const SizedBox(height: 4),
          _row('목표 성적', _fmtScore(goal)),
          if (achieved != null) _row('달성 여부', achieved ? '달성' : '미달성'),
          if (record != null) _row('추가 이자율(해당 학기)', _fmtBonus(bonus)),

          const SizedBox(height: 6),
          const Text(
            '※ 최종 적용은 두 학기 중 최대치 1회',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }


  Widget _row(String k, String v) {
    return Padding(
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
}

// ------------ helpers & model ------------
class Term {
  final int year;
  final int semester; // 1 or 2
  Term(this.year, this.semester);
}

class GradeRecordDto {
  final int year;
  final int semester;
  final int? totalCredits;
  final double? totalGpa;
  final String? type;

  GradeRecordDto({
    required this.year,
    required this.semester,
    this.totalCredits,
    this.totalGpa,
    this.type,
  });

  factory GradeRecordDto.fromJson(Map<String, dynamic> j) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      final s = v.toString().replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(s);
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().replaceAll(',', '.');
      return double.tryParse(s);
    }

    return GradeRecordDto(
      year: toInt(j['year']) ?? 0,
      semester: toInt(j['semester']) ?? 0,
      totalCredits: toInt(j['totalCredits']),
      totalGpa: toDouble(j['totalGpa']),
      type: j['type']?.toString(),
    );
  }
}
