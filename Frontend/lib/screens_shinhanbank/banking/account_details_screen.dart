import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/models/transaction_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/account_management_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Account account;
  const AccountDetailsScreen({super.key, required this.account});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  static const String baseUrl = 'http://10.0.2.2:8080';

  bool _loading = true;
  String? _error;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<String> fetchDetailJson({
    required String baseUrl,
    required String userKey,
    required String accountNo, // 화면에 보이는 계좌번호
    required bool isDemandDeposit, // <- 반드시 넘겨주기
  }) async {
    final path = isDemandDeposit
        ? '/deposit/detailsAccount'  // 입출금
        : '/deposit/detailsDeposit'; // 예금

    final uri = Uri.parse('$baseUrl$path')
        .replace(queryParameters: {'userKey': userKey, 'accountNo': accountNo});

    final res = await http.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode != 200) {
      throw Exception('상세 조회 실패: ${res.statusCode} ${res.body}');
    }
    return res.body;
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
      _transactions = [];
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) {
        throw Exception('로그인 정보(userKey)가 없습니다.');
      }

      // 👉 숫자만 남기고 길이로 판별: 16자리 = 수시입출금, 그 외 = 예금
      final digits = widget.account.accountNumber.replaceAll(RegExp(r'\D'), '');
      final isDemand = digits.length == 16;

      final path = isDemand
          ? '/deposit/detailsAccount'   // 수시입출금 거래내역
          : '/deposit/detailsDeposit';  // 예금 지급내역

      final uri = Uri.parse('$baseUrl$path')
          .replace(queryParameters: {'userKey': userKey, 'accountNo': digits});

      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200 || res.body.isEmpty) {
        throw Exception('상세 조회 실패: ${res.statusCode} ${res.body}');
      }

      final parsed = _parseTransactionsFromApi(res.body);

      if (!mounted) return;
      setState(() {
        _transactions = parsed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '조회 실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('거래내역조회'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.home_outlined)),
        ],
      ),
      body: Column(
        children: [
          // 상단 계좌 정보
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.account.bankName} ${widget.account.accountName}', style: const TextStyle(fontSize: 18)),
                Text(widget.account.accountNumber, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${currencyFormat.format(widget.account.balance)}원',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('이체'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AccountManagementScreen(account: widget.account)),
                          );
                        },
                        child: const Text('계좌관리'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(thickness: 8),

          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_transactions.isEmpty)
              const Expanded(
                child: Center(child: Text('거래내역이 없습니다.')),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    final isWithdrawal = tx.type == TransactionType.withdrawal;
                    return ListTile(
                      title: Text(tx.description),
                      subtitle: Text('${tx.date} ${tx.time}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isWithdrawal ? '출금' : '입금'} ${currencyFormat.format(tx.amount)}원',
                            style: TextStyle(
                              color: isWithdrawal ? Colors.red : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '잔액 ${currencyFormat.format(tx.balanceAfter)}원',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                ),
              ),
        ],
      ),
    );
  }

  // ========= 응답 공용 파서 =========
  List<Transaction> _parseTransactionsFromApi(String body) {
    final root = jsonDecode(body) as Map<String, dynamic>;
    final header = (root['Header'] ?? {}) as Map<String, dynamic>;
    final apiName = (header['apiName'] ?? '').toString();

    if (apiName == 'inquireTransactionHistoryList') {
      // 수시입출금 거래내역
      final rec = (root['REC'] ?? {}) as Map<String, dynamic>;
      final list = (rec['list'] as List?) ?? const [];
      return list.map<Transaction>((raw) {
        final m = (raw as Map).cast<String, dynamic>();
        final date = _fmtDate((m['transactionDate'] ?? '').toString());
        final time = _fmtTime((m['transactionTime'] ?? '').toString());
        final typeCode = (m['transactionType'] ?? '').toString(); // '1': 입금, '2': 출금
        final amount = _toInt(m['transactionBalance']);
        final after = _toInt(m['transactionAfterBalance']);
        final desc = (m['transactionSummary'] ?? m['transactionTypeName'] ?? '').toString();

        final txType = typeCode == '2' ? TransactionType.withdrawal : TransactionType.deposit;

        return Transaction(
          date: date,
          time: time,
          description: desc.isEmpty ? (txType == TransactionType.deposit ? '입금' : '출금') : desc,
          amount: amount,
          balanceAfter: after,
          type: txType,
        );
      }).toList();
    } else if (apiName == 'inquireDepositPayment') {
      // 예금 지급 단건
      final rec = (root['REC'] ?? {}) as Map<String, dynamic>;
      final date = _fmtDate((rec['paymentDate'] ?? '').toString());
      final time = _fmtTime((rec['paymentTime'] ?? '').toString());
      final amount = _toInt(rec['paymentBalance']);

      return [
        Transaction(
          date: date,
          time: time,
          description: '예금 지급',
          amount: amount,
          balanceAfter: amount, // 잔액 정보가 없으니 표시용으로 동일 값 사용
          type: TransactionType.deposit,
        ),
      ];
    }

    return [];
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    final s = v.toString().replaceAll(RegExp(r'[^\d-]'), '');
    return int.tryParse(s) ?? 0;
  }

  String _fmtDate(String yyyymmdd) {
    if (yyyymmdd.length != 8) return yyyymmdd;
    return '${yyyymmdd.substring(0, 4)}.${yyyymmdd.substring(4, 6)}.${yyyymmdd.substring(6, 8)}';
  }

  String _fmtTime(String hhmmss) {
    if (hhmmss.length != 6) return hhmmss;
    return '${hhmmss.substring(0, 2)}:${hhmmss.substring(2, 4)}:${hhmmss.substring(4, 6)}';
  }
}
