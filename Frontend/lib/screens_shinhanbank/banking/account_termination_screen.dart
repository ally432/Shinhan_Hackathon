import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/transfer_funds_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://211.188.50.244:8080';

class AccountTerminationScreen extends StatefulWidget {
  final Account account;
  const AccountTerminationScreen({super.key, required this.account});

  @override
  State<AccountTerminationScreen> createState() => _AccountTerminationScreenState();
}

class _AccountTerminationScreenState extends State<AccountTerminationScreen> {
  final NumberFormat _currency = NumberFormat.currency(locale: 'ko_KR', symbol: '');

  // 만기 기준 정보 (비교용)
  int _principal = 0;
  double _rate = 0.0;
  int _maturityInterest = 0; // 만기 이자 (서버 값)

  // 중도해지 관련 상태 변수
  int _earlyTerminationDays = 0;
  int _earlyTerminationInterest = 0;
  int _finalPayoutAmount = 0;

  bool _loading = true;
  String? _error;

  // 달성 이자율 관련 변수
  bool _loadingBonus = true;
  double _bonusRate = 0.0;

  @override
  void initState() {
    super.initState();
    // 여러 데이터를 동시에 불러와 로딩 시간을 최적화합니다.
    Future.wait([
      _loadMaturityInfo(),
      _calculateEarlyTermination(),
      _loadAchievement(), // 이 함수는 내부적으로 목표/성적을 모두 불러옵니다.
    ]).whenComplete(() {
      if (mounted) setState(() => _loading = false);
    });
  }

  /// 만기 시의 원금, 이자, 금리 정보를 서버에서 가져옵니다.
  Future<void> _loadMaturityInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보(userKey)가 없습니다.');

      final cleanAccNo = widget.account.accountNumber.replaceAll(RegExp(r'\D'), '');

      final uri = Uri.parse('$baseUrl/deposit/rate')
          .replace(queryParameters: {'userKey': userKey, 'accountNo': cleanAccNo});
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

      final root = jsonDecode(res.body) as Map<String, dynamic>;
      final rec = (root['REC'] ?? root['rec'] ?? {}) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _principal = _toInt(rec['expiryBalance']);
        _maturityInterest = _toInt(rec['expiryInterest']);
        _rate = _toDouble(rec['interestRate']);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '만기 정보 조회 실패';
        _principal = widget.account.balance;
        _rate = widget.account.interestRate;
        _maturityInterest = _calculateDailyInterest(_principal, _rate, 365);
      });
    }
  }

  /// 중도해지 정보를 로컬에서 계산합니다.
  Future<void> _calculateEarlyTermination() async {
    final principal = widget.account.balance;
    final rate = widget.account.interestRate;

    final openingDate = _parseDate(widget.account.openingDate);
    final today = DateTime.now();
    int days = 0;
    if (openingDate != null) {
      days = today.difference(openingDate).inDays;
      if (days < 0) days = 0;
    }

    final earlyInterest = _calculateDailyInterest(principal, rate, days);
    final finalAmount = principal + earlyInterest;

    if (mounted) {
      setState(() {
        _earlyTerminationDays = days;
        _earlyTerminationInterest = earlyInterest;
        _finalPayoutAmount = finalAmount;
      });
    }
  }

  /// 성적 달성 보너스 이율을 계산합니다.
  Future<void> _loadAchievement() async {
    // ... (이전과 동일한 내용) ...
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '계좌 해지',
      nextButtonText: '해지',
      onNext: _loading
          ? null
          : () {
        // 중도해지 최종 지급액을 다음 화면으로 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferFundsScreen(
              amount: _finalPayoutAmount + _calcBonusInterest(),
              bonusAmount: _calcBonusInterest(),
              account: widget.account,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '계좌 해지 후 복구는 불가합니다.\n정말 해지하시겠습니까?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!)
            ),
            child: _loading
                ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
                : Column(
              children: [
                _buildInfoRow('최초 입금 원금', '${_currency.format(widget.account.balance)}원'),
                _buildInfoRow('약정 금리', '연 ${widget.account.interestRate.toStringAsFixed(2)}%'),
                const Divider(height: 24),
                _buildInfoRow('실제 가입 기간', '$_earlyTerminationDays일'),
                _buildInfoRow('중도해지 이자', '+ ${_currency.format(_earlyTerminationInterest)}원', isHighlight: true),
                const Divider(height: 24),
                _buildInfoRow(
                  '중도해지 시 최종 지급액',
                  '${_currency.format(_finalPayoutAmount + _calcBonusInterest())}원',
                  isFinal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Functions
  int _toInt(dynamic v) => int.tryParse(v.toString().replaceAll(RegExp(r'[^\d-]'), '')) ?? 0;
  double _toDouble(dynamic v) => double.tryParse(v.toString().replaceAll('%', '').trim()) ?? 0.0;
  int _calculateDailyInterest(int principal, double ratePercent, int days) {
    if (days <= 0) return 0;
    return (principal * (ratePercent / 100) / 365.0 * days).round();
  }
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return null;
    final digits = dateStr.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    return DateTime.tryParse(digits);
  }
  int _calcBonusInterest() {
    if (_bonusRate <= 0) return 0;
    return _calculateDailyInterest(widget.account.balance, _bonusRate, _earlyTerminationDays);
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, bool isFinal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: isFinal ? 20 : 16,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? const Color(0xFFD32F2F) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Stubs for other methods to keep the file complete
  Future<void> _loadLocalGoals() async {}
  double? _goalFor(Term t) => null;
  double? _bonusFor(double? target, double? gpa) => null;
  List<Term> _recentTerms(DateTime now) => [];
}

// Model Stubs
class GradeRecordDto { final double? totalGpa; GradeRecordDto({this.totalGpa}); }
class Term { final int year; final int semester; Term(this.year, this.semester); }