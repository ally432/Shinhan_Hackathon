import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'achievement_result_screen.dart';

const String baseUrl = 'http://211.188.50.244:8080';

enum InterestMode { maturity, early }

class InterestCalcScreen extends StatefulWidget {
  final Account account;
  final InterestMode initialMode;

  const InterestCalcScreen({
    super.key,
    required this.account,
    this.initialMode = InterestMode.maturity,
  });

  @override
  State<InterestCalcScreen> createState() => _InterestCalcScreenState();
}

class _InterestCalcScreenState extends State<InterestCalcScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _currency = NumberFormat.currency(locale: 'ko_KR', symbol: '');

  // 만기 정보
  bool _loadingExpiry = true;
  String? _expiryError;
  int _expiryPrincipal = 0;
  double _expiryRate = 0.0;
  String _expiryStart = '-';
  String _expiryEnd = '-';
  int _expiryInterest = 0;
  int _expiryTotal = 0;
  int _potentialBonusAmount = 0; // '예상' 보너스 이자

  // 중도해지 정보
  int _earlyPrincipal = 0;
  double _earlyRate = 0.0;
  int _earlyDays = 0;
  int _earlyInterest = 0;
  int _earlyTotal = 0;

  bool _checkingAchievement = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialMode == InterestMode.maturity ? 0 : 1,
    );
    _loadAll();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadExpiryFromServerOrFallback(),
      _calcEarlyLocally(),
      _loadPotentialBonus(),
    ]);
  }

  Future<void> _loadPotentialBonus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보가 없습니다.');

      final target = await _fetchGoalsFromServer(userKey);
      if (target == null) return;

      final bonusRate1 = _getBonusRateForGoal(target.goalSem1);
      final bonusRate2 = _getBonusRateForGoal(target.goalSem2);
      final maxBonusRate = (bonusRate1 > bonusRate2) ? bonusRate1 : bonusRate2;

      // 만기 원금을 기준으로 예상 보너스 이자 계산
      final principalForBonus = _expiryPrincipal > 0 ? _expiryPrincipal : widget.account.balance;
      final potentialBonus = _roundInterest(principalForBonus, maxBonusRate, 365);

      if (mounted) {
        setState(() {
          _potentialBonusAmount = potentialBonus;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _potentialBonusAmount = 0);
    }
  }

  double _getBonusRateForGoal(double? goal) {
    if (goal == null) return 0.0;
    if ((goal - 4.30).abs() < 0.005) return 0.15;
    if ((goal - 4.00).abs() < 0.005) return 0.10;
    if ((goal - 3.70).abs() < 0.005) return 0.05;
    return 0.0;
  }

  Future<TargetScoreDto?> _fetchGoalsFromServer(String userKey) async {
    final uri = Uri.parse('$baseUrl/api/target-score').replace(queryParameters: {'userKey': userKey});
    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 7));
      if (res.statusCode == 200) return TargetScoreDto.fromJson(jsonDecode(res.body));
    } catch (_) {}
    return null;
  }

  Future<void> _checkAchievement() async {
    if (_checkingAchievement) return;
    setState(() => _checkingAchievement = true);
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AchievementResultScreen(
            principal: _expiryPrincipal,
            days: 365,
          ),
        ),
      );
      // AchievementResultScreen에서 돌아온 후에는 별도의 상태 업데이트가 필요 없음 (현재 화면은 예상치만 보여주므로)
    } finally {
      if (mounted) setState(() => _checkingAchievement = false);
    }
  }

  Future<void> _loadExpiryFromServerOrFallback() async {
    setState(() { _loadingExpiry = true; _expiryError = null; });
    final principal = widget.account.balance;
    final rate = widget.account.interestRate;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보가 없습니다.');
      final cleanAccNo = widget.account.accountNumber.replaceAll(RegExp(r'\D'), '');
      final uri = Uri.parse('$baseUrl/deposit/rate').replace(
        queryParameters: {'userKey': userKey, 'accountNo': cleanAccNo},
      );
      final res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 7));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final root = jsonDecode(res.body) as Map<String, dynamic>;
      final rec = (root['REC'] ?? root['rec'] ?? {}) as Map<String, dynamic>;
      final expiryBalance = _toInt(rec['expiryBalance']);
      final expiryInterest = _toInt(rec['expiryInterest']);
      final expiryTotal = _toInt(rec['expiryTotalBalance']);
      final srvRate = double.tryParse(rec['interestRate']?.toString() ?? '') ?? rate;
      setState(() {
        _expiryPrincipal = expiryBalance != 0 ? expiryBalance : principal;
        _expiryRate = srvRate;
        _expiryStart = _fmtYmd(rec['accountCreateDate']?.toString()) ?? widget.account.openingDate;
        _expiryEnd = _fmtYmd(rec['accountExpiryDate']?.toString()) ?? widget.account.maturityDate;
        _expiryInterest = expiryInterest != 0 ? expiryInterest : _roundInterest(principal, srvRate, 365);
        _expiryTotal = expiryTotal != 0 ? expiryTotal : _expiryPrincipal + _expiryInterest;
        _loadingExpiry = false;
      });
    } catch (e) {
      setState(() {
        _expiryError = '만기 이자 조회 실패: $e (로컬 계산 적용)';
        _expiryPrincipal = principal;
        _expiryRate = rate;
        _expiryStart = widget.account.openingDate;
        _expiryEnd = widget.account.maturityDate;
        _expiryInterest = _roundInterest(principal, rate, 365);
        _expiryTotal = principal + _expiryInterest;
        _loadingExpiry = false;
      });
    }
  }

  Future<void> _calcEarlyLocally() async {
    final principal = widget.account.balance;
    final rate = widget.account.interestRate;
    final open = _parseAnyDate(widget.account.openingDate);
    final today = DateTime.now().toUtc().add(const Duration(hours: 9));
    int days = 0;
    if (open != null) {
      days = today.difference(open).inDays;
      if (days > 365) days = 365;
      if (days < 0) days = 0;
    }
    final interest = _roundInterest(principal, rate, days);
    setState(() {
      _earlyPrincipal = principal;
      _earlyRate = rate;
      _earlyDays = days;
      _earlyInterest = interest;
      _earlyTotal = principal + interest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('이자 조회'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: '만기 이자'), Tab(text: '중도해지 이자')],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ElevatedButton.icon(
              onPressed: _checkingAchievement ? null : _checkAchievement,
              icon: _checkingAchievement
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Icon(Icons.school_outlined, size: 22),
              label: Text(_checkingAchievement ? '확인 중...' : '실제 성적과 비교하기'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCard(
              title: '만기 이자',
              body: _loadingExpiry
                  ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_expiryError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_expiryError!, style: const TextStyle(color: Colors.orange, fontSize: 12)),
                    ),
                  _row('원금', '${_currency.format(_expiryPrincipal)}원'),
                  _row('기간', '$_expiryStart ~ $_expiryEnd'),
                  _row('금리', '연 ${_expiryRate.toStringAsFixed(2)}%'),
                  const Divider(height: 24),
                  _row('기본 이자', '+ ${_currency.format(_expiryInterest)}원'),
                  _row('추가 이자 (최대 달성 시)', '+ ${_currency.format(_potentialBonusAmount)}원', isHighlight: _potentialBonusAmount > 0),
                  const Divider(height: 24),
                  _row('만기 시 최종 예상액', '${_currency.format(_expiryTotal + _potentialBonusAmount)}원', isFinal: true),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCard(
              title: '중도해지 이자',
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('원금', '${_currency.format(_earlyPrincipal)}원'),
                  _row('경과 일수', '$_earlyDays일'),
                  _row('금리', '연 ${_earlyRate.toStringAsFixed(2)}%'),
                  const Divider(height: 24),
                  _row('중도해지 이자', '+ ${_currency.format(_earlyInterest)}원', isHighlight: true),
                  _row('중도해지 예상액', '${_currency.format(_earlyTotal)}원', isFinal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _toInt(dynamic v) => int.tryParse(v.toString().replaceAll(RegExp(r'[^\d-]'), '')) ?? 0;
  int _roundInterest(int principal, double ratePct, int days) {
    if (days <= 0) return 0;
    return ((principal * (ratePct / 100)) / 365.0 * days).round();
  }
  DateTime? _parseAnyDate(String? v) {
    if (v == null || v.isEmpty || v == '-') return null;
    final d = v.replaceAll(RegExp(r'\D'), '');
    if (d.length != 8) return null;
    return DateTime.tryParse(d);
  }
  String? _fmtYmd(String? ymd) {
    if (ymd == null) return null;
    final d = ymd.replaceAll(RegExp(r'\D'), '');
    if (d.length != 8) return null;
    return '${d.substring(0, 4)}.${d.substring(4, 6)}.${d.substring(6, 8)}';
  }
  Widget _buildCard({required String title, required Widget body}) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(height: 24),
        body,
      ],
    ),
  );
  Widget _row(String k, String v, {bool isHighlight = false, bool isFinal = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          v,
          style: TextStyle(
            fontSize: isFinal ? 18 : 14,
            fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? const Color(0xFFD32F2F) : Colors.black87,
          ),
        ),
      ],
    ),
  );
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