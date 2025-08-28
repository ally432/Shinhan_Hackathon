import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/transfer_funds_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';
const String kSem1GoalKey = 'goal_sem1';
const String kSem2GoalKey = 'goal_sem2';

class AccountTerminationScreen extends StatefulWidget {
  final Account account;
  const AccountTerminationScreen({super.key, required this.account});

  @override
  State<AccountTerminationScreen> createState() => _AccountTerminationScreenState();
}

class _AccountTerminationScreenState extends State<AccountTerminationScreen> {
  final NumberFormat _currency = NumberFormat.currency(locale: 'ko_KR', symbol: '');

  bool _loading = true;
  String? _error;

  double? _goalSem1;
  double? _goalSem2;


  int _principal = 0;
  int _interest = 0;
  double _rate = 0.0;
  int _periodDays = 365;
  int _finalAmount = 0;

  // 🔹 달성 이자율 관련
  bool _loadingBonus = true;
  String? _bonusError;
  double _bonusRate = 0.0; // 퍼센트포인트(예: 0.05, 0.10, 0.15)

  TargetScoreDto? _target;                     // 목표 성적
  final List<GradeRecordDto?> _records = [null, null]; // 최근 2학기 성적

  @override
  void initState() {
    super.initState();
    _loadRate();          // 기존 이자 로딩
    _loadAchievement();   // ✅ 추가: 달성 이자율 로딩
  }

  Future<void> _loadLocalGoals() async {
    final prefs = await SharedPreferences.getInstance();
    double? parse(String? s) => (s == null || s.trim().isEmpty) ? null : double.tryParse(s.trim());
    _goalSem1 = parse(prefs.getString(kSem1GoalKey));
    _goalSem2 = parse(prefs.getString(kSem2GoalKey));
  }


  Future<void> _loadRate() async {
    setState(() { _loading = true; _error = null; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) {
        throw Exception('로그인 정보(userKey)가 없습니다.');
      }

      // 하이픈 없는 계좌번호
      final cleanAccNo = widget.account.accountNumber.replaceAll(RegExp(r'\D'), '');

      // 백엔드: /deposit/rate -> inquireDepositExpiryInterest 호출
      final uri = Uri.parse('$baseUrl/deposit/rate')
          .replace(queryParameters: {'userKey': userKey, 'accountNo': cleanAccNo});
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode != 200) {
        throw Exception('이자 조회 실패: ${res.statusCode} ${res.body}');
      }

      final root = jsonDecode(res.body) as Map<String, dynamic>;
      final rec = (root['REC'] ?? root['rec'] ?? {}) as Map<String, dynamic>;

      // 서버 필드
      final expiryBalance      = _toInt(rec['expiryBalance']);       // ✅ 만기 원금
      final expiryInterest     = _toInt(rec['expiryInterest']);      // 만기 이자
      final expiryTotalBalance = _toInt(rec['expiryTotalBalance']);  // 만기 총액(원금+이자)
      final rate               = _toDouble(rec['interestRate']);     // 금리(%)

      // 가입 기간 계산
      final created = _parseYmd(rec['accountCreateDate']?.toString());
      final expiry  = _parseYmd(rec['accountExpiryDate']?.toString());
      int periodDays = 365;
      if (created != null && expiry != null) {
        periodDays = expiry.difference(created).inDays.abs();
        if (periodDays == 0) periodDays = 1;
      }

      // 방어 계산
      final principal = (expiryBalance != 0) ? expiryBalance : widget.account.balance;
      final interest = (expiryInterest != 0)
          ? expiryInterest
          : (expiryTotalBalance != 0 && principal != 0)
          ? (expiryTotalBalance - principal)
          : ((principal * rate / 100) * (periodDays / 365)).round();
      final finalAmount = (expiryTotalBalance != 0)
          ? expiryTotalBalance
          : principal + interest;

      if (!mounted) return;
      setState(() {
        _principal   = principal;   // ✅ UI에서 사용
        _interest    = interest;
        _rate        = rate;
        _periodDays  = periodDays;
        _finalAmount = finalAmount;
        _loading     = false;
      });
    } catch (e) {
      // 실패: 기존 로컬 계산 폴백
      final principal = widget.account.balance;
      final fallbackInterest = (principal * widget.account.interestRate / 100).round();
      if (!mounted) return;
      setState(() {
        _error        = '이자 조회 실패(임시 계산 적용): $e';
        _principal    = principal;                 // ✅ 폴백
        _interest     = fallbackInterest;
        _rate         = widget.account.interestRate;
        _periodDays   = 365;
        _finalAmount  = principal + _interest;
        _loading      = false;
      });
    }
  }


  Future<void> _loadAchievement() async {
    setState(() { _loadingBonus = true; _bonusError = null; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보(userKey)가 없습니다.');

      // ✅ 1) 목표 성적: 로컬에서만 읽음
      await _loadLocalGoals();

      // ✅ 2) 최근 2학기 성적은 그대로 서버에서 가져옴(성적은 DB)
      final terms = _recentTerms(DateTime.now());
      for (int i = 0; i < terms.length; i++) {
        final t = terms[i];
        final uri = Uri.parse('$baseUrl/api/grades/record').replace(queryParameters: {
          'userKey': userKey,
          'year': t.year.toString(),
          'semester': t.semester.toString(),
        });
        final res = await http.get(uri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 7));
        if (res.statusCode == 200) {
          final root = jsonDecode(res.body);
          Map<String, dynamic>? map;
          if (root is Map<String, dynamic>) {
            final r = root['record'] ?? root['REC'] ?? root;
            if (r is Map<String, dynamic>) map = r;
          }
          _records[i] = map == null ? null : GradeRecordDto.fromJson(map);
        } else {
          _records[i] = null; // 404 등은 성적 없음으로 처리
        }
      }

      // ✅ 3) 규칙 적용: 각 학기 보너스 산출 → 최대치 1회 적용
      double maxBonus = 0.0;
      for (int i = 0; i < terms.length; i++) {
        final t = terms[i];
        final goal = _goalFor(t);            // 로컬 목표
        final gpa  = _records[i]?.totalGpa;  // 성적
        final b = _bonusFor(goal, gpa) ?? 0.0;
        if (b > maxBonus) maxBonus = b;
      }

      if (!mounted) return;
      setState(() {
        _bonusRate = maxBonus;
        _loadingBonus = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bonusError = '달성 이자율 조회 실패: $e';
        _loadingBonus = false;
        _bonusRate = 0.0;
      });
    }
  }



  // === 헬퍼들(중복 선언 금지!) ===
  int _toInt(dynamic v) {
    if (v == null) return 0;
    final s = v.toString().replaceAll(RegExp(r'[^\d-]'), '');
    return int.tryParse(s) ?? 0;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    final s = v.toString().replaceAll('%', '').trim();
    return double.tryParse(s) ?? 0.0;
  }

  DateTime? _parseYmd(String? ymd) {
    if (ymd == null || ymd.length != 8) return null;
    return DateTime.tryParse('${ymd.substring(0,4)}-${ymd.substring(4,6)}-${ymd.substring(6,8)}');
  }

  @override
  Widget build(BuildContext context) {
    final periodLabel = _formatPeriod(_periodDays);

    return StepLayout(
      title: '계좌 해지',
      nextButtonText: '해지',
      onNext: _loading
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferFundsScreen(
              amount: _finalAmount,
              bonusAmount: _calcBonusInterest(),
              account: widget.account,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '계좌를 해지하면 더 이상 복구할 수 없어요. 정말 해지하시겠어요?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _loading
                ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
                : Column(
              children: [
                // ✅ 서버 만기원금(expiryBalance) 우선 노출
                _buildInfoRow('최초 입금 금액', '${_currency.format(_principal)}원'),
                _buildInfoRow('가입 기간 / 적용 금리', '$periodLabel / 연 ${_rate.toStringAsFixed(2)}%'),
                _buildInfoRow('이자', '+ ${_currency.format(_interest)}원', isHighlight: true),
                const Divider(height: 24),
                _buildInfoRow(
                  '달성 이자율',
                  _loadingBonus
                      ? '조회 중…'
                      : (_bonusRate > 0 ? '+ ${_bonusRate.toStringAsFixed(2)}%' : '없음'),
                ),

                // ✅ 추가: 달성으로 붙는 추가 이자 금액
                _buildInfoRow(
                  '추가 이자(달성)',
                  (_loading || _loadingBonus)
                      ? '계산 중…'
                      : (_bonusRate > 0
                      ? '+ ${_currency.format(_calcBonusInterest())}원'
                      : '없음'),
                  isHighlight: _bonusRate > 0,
                ),

                // 기존 최종액(서버 기준)
                _buildInfoRow('예상 최종액', '${_currency.format(_finalAmount)}원', isFinal: true),

                // ✅ 추가(선택): 보너스 반영 시 최종액
                _buildInfoRow(
                  '보너스 반영 최종액',
                  (_loading || _loadingBonus)
                      ? '계산 중…'
                      : '${_currency.format(_calcFinalWithBonus())}원',
                  isFinal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double? _goalFor(Term t) {
    return t.semester == 1 ? _goalSem1 : _goalSem2;
  }

// 목표: 3.70 → ≥3.70 이면 +0.05
//      4.00 → ≥4.00 이면 +0.10
//      4.30 → ≥4.30 이면 +0.15
// 그 외 점수는 보너스 없음
  double? _bonusFor(double? target, double? gpa) {
    if (target == null || gpa == null) return null;
    // 반올림 노이즈 최소화
    final t = double.parse(target.toStringAsFixed(2));
    final g = double.parse(gpa.toStringAsFixed(2));

    bool ge(num x) => g + 1e-9 >= x; // g >= x

    if ((t - 3.70).abs() < 0.005) return ge(3.70) ? 0.05 : 0.0;
    if ((t - 4.00).abs() < 0.005) return ge(4.00) ? 0.10 : 0.0;
    if ((t - 4.30).abs() < 0.005) return ge(4.30) ? 0.15 : 0.0;
    return 0.0;
  }

  int _calcBonusInterest() {
    if (_bonusRate <= 0 || _principal <= 0 || _periodDays <= 0) return 0;
    final extra = (_principal * (_bonusRate / 100.0)) * (_periodDays / 365.0);
    return extra.round();
  }

  int _calcFinalWithBonus() {
    return _finalAmount + _calcBonusInterest();
  }

  // ---------- UI helpers ----------
  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, bool isFinal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: isFinal ? 20 : 16,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }


  String _formatPeriod(int days) {
    if (days <= 0) return '-';
    if (days == 365) return '1년';
    if (days % 30 == 0) return '${days ~/ 30}개월';
    return '${days}일';
  }


}

// ── 최근 2학기 규칙: 1~2월:(Y-1,2)(Y-1,1) / 3~8월:(Y,1)(Y-1,2) / 9~12월:(Y,2)(Y,1)
List<Term> _recentTerms(DateTime now) {
  final y = now.year, m = now.month;
  if (m <= 2) return [Term(y - 1, 2), Term(y - 1, 1)];
  if (m <= 8) return [Term(y, 1), Term(y - 1, 2)];
  return [Term(y, 2), Term(y, 1)];
}

// ── 모델들
class Term {
  final int year;
  final int semester; // 1 or 2
  Term(this.year, this.semester);
}

class GradeRecordDto {
  final double? totalGpa;
  final int? totalCredits;
  final String? type;
  GradeRecordDto({this.totalGpa, this.totalCredits, this.type});

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
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().replaceAll(',', '.');
      return double.tryParse(s);
    }
    return TargetScoreDto(
      goalSem1: toDouble(j['goalSem1'] ?? j['goal_sem1']),
      goalSem2: toDouble(j['goalSem2'] ?? j['goal_sem2']),
    );
  }
}
