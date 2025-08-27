import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/transfer_funds_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';

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

  int _principal = 0;       // ✅ 최초 입금 금액(만기 원금) - 서버 우선
  int _interest = 0;        // 만기 이자
  double _rate = 0.0;       // 적용 금리(%)
  int _periodDays = 365;    // 가입 기간(일)
  int _finalAmount = 0;     // 만기 총액(원금+이자)

  @override
  void initState() {
    super.initState();
    _loadRate();
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
                _buildInfoRow('예상 최종액', '${_currency.format(_finalAmount)}원', isFinal: true),
              ],
            ),
          ),
        ],
      ),
    );
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
