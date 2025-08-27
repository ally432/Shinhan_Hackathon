import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';

enum InterestMode { maturity, early }

class InterestCalcScreen extends StatefulWidget {
  final Account account;
  final InterestMode initialMode; // ✅ 초기 탭 지정

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

  // ===== 만기(서버/폴백) =====
  bool _loadingExpiry = true;
  String? _expiryError;
  int _expiryPrincipal = 0;
  double _expiryRate = 0.0; // %
  String _expiryStart = '-';
  String _expiryEnd = '-';
  int _expiryInterest = 0;
  int _expiryTotal = 0;

  // ===== 중도해지(로컬계산) =====
  int _earlyPrincipal = 0;
  double _earlyRate = 0.0; // %
  int _earlyDays = 0;
  int _earlyInterest = 0;
  int _earlyTotal = 0;

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

  Future<void> _loadAll() async {
    await Future.wait([
      _loadExpiryFromServerOrFallback(),
      _calcEarlyLocally(),
    ]);
    if (mounted) setState(() {});
  }

  // -------------------- 만기 이자: 서버 조회 (실패 시 폴백) --------------------
  Future<void> _loadExpiryFromServerOrFallback() async {
    setState(() {
      _loadingExpiry = true;
      _expiryError = null;
    });

    final principal = widget.account.balance;
    final rate = widget.account.interestRate;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) throw Exception('로그인 정보(userKey)가 없습니다.');

      final cleanAccNo =
      widget.account.accountNumber.replaceAll(RegExp(r'\D'), '');

      final uri = Uri.parse('$baseUrl/deposit/rate').replace(
        queryParameters: {'userKey': userKey, 'accountNo': cleanAccNo},
      );
      final res =
      await http.get(uri, headers: {'Accept': 'application/json'}).timeout(
        const Duration(seconds: 7),
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode} ${res.body}');
      }

      final root = jsonDecode(res.body) as Map<String, dynamic>;
      final rec = (root['REC'] ?? root['rec'] ?? {}) as Map<String, dynamic>;

      final expiryBalance = _toInt(rec['expiryBalance']);
      final expiryInterest = _toInt(rec['expiryInterest']);
      final expiryTotal = _toInt(rec['expiryTotalBalance']);
      final rateStr = rec['interestRate']?.toString();
      final srvRate = rateStr == null ? rate : double.tryParse(rateStr) ?? rate;

      final startYmd = rec['accountCreateDate']?.toString();
      final endYmd = rec['accountExpiryDate']?.toString();

      setState(() {
        _expiryPrincipal = expiryBalance != 0 ? expiryBalance : principal;
        _expiryRate = srvRate;
        _expiryStart = _fmtYmd(startYmd) ?? widget.account.openingDate;
        _expiryEnd = _fmtYmd(endYmd) ?? widget.account.maturityDate;
        _expiryInterest = expiryInterest != 0
            ? expiryInterest
            : _roundInterest(principal, srvRate, 365);
        _expiryTotal =
        expiryTotal != 0 ? expiryTotal : _expiryPrincipal + _expiryInterest;
        _loadingExpiry = false;
      });
    } catch (e) {
      // 폴백(365일 기준)
      setState(() {
        _expiryError = '만기 이자 서버 조회 실패: $e (로컬 계산 적용)';
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

  // -------------------- 중도해지 이자: 로컬 계산 --------------------
  Future<void> _calcEarlyLocally() async {
    final principal = widget.account.balance;
    final rate = widget.account.interestRate;

    // 개설일 ~ 오늘 경과일 (최소 1일, 최대 365일 가정)
    final open = _parseAnyDate(widget.account.openingDate);
    final today = DateTime.now();
    int days = 1;
    if (open != null) {
      days = today.difference(open).inDays;
      if (days < 1) days = 1;
      if (days > 365) days = 365;
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

  // -------------------- Helpers --------------------
  int _toInt(dynamic v) {
    if (v == null) return 0;
    final s = v.toString().replaceAll(RegExp(r'[^\d-]'), '');
    return int.tryParse(s) ?? 0;
  }

  /// round( (principal * (rate/100)) / 365 * days )
  int _roundInterest(int principal, double ratePct, int days) {
    final interest =
    ((principal * (ratePct / 100)) / 365.0 * days.toDouble());
    return interest.round();
  }

  /// '2025.08.17' | '2025-08-17' | '20250817' -> DateTime?
  DateTime? _parseAnyDate(String? v) {
    if (v == null || v.isEmpty || v == '-') return null;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    final y = int.tryParse(digits.substring(0, 4));
    final m = int.tryParse(digits.substring(4, 6));
    final d = int.tryParse(digits.substring(6, 8));
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  String? _fmtYmd(String? yyyymmdd) {
    if (yyyymmdd == null) return null;
    final digits = yyyymmdd.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    return '${digits.substring(0, 4)}.${digits.substring(4, 6)}.${digits.substring(6, 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('이자 조회'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: '만기 이자'),
            Tab(text: '중도해지 이자'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ===== 만기 이자 탭 =====
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCard(
              title: '만기 이자',
              body: _loadingExpiry
                  ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_expiryError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: SingleChildScrollView(
                          child: Text(
                            _expiryError!,
                            style: const TextStyle(
                                color: Colors.orange, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  _row('원금', '${_currency.format(_expiryPrincipal)}원'),
                  _row('기간', '$_expiryStart ~ $_expiryEnd'),
                  _row('금리', '연 ${_expiryRate.toStringAsFixed(2)}%'),
                  const Divider(height: 20),
                  _row('이자', '+ ${_currency.format(_expiryInterest)}원',
                      big: true),
                  _row('만기 예상액',
                      '${_currency.format(_expiryTotal)}원',
                      big: true, bold: true),
                ],
              ),
            ),
          ),

          // ===== 중도해지 이자 탭 =====
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
                  const SizedBox(height: 6),
                  const Text(
                    '계산식: round( (원금 × (금리/100)) ÷ 365 × 일수 )',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const Divider(height: 20),
                  _row('중도해지 이자', '+ ${_currency.format(_earlyInterest)}원',
                      big: true),
                  _row('중도해지 예상액',
                      '${_currency.format(_earlyTotal)}원',
                      big: true, bold: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget body}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          body,
        ],
      ),
    );
  }

  Widget _row(String k, String v, {bool big = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            v,
            style: TextStyle(
              fontSize: big ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
