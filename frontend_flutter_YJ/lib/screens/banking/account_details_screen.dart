import 'package:flutter/material.dart';
import 'package:frontend_flutter_yj/models/account_model.dart';
import 'package:frontend_flutter_yj/models/transaction_model.dart';
import 'package:frontend_flutter_yj/screens/banking/account_management_screen.dart';
import 'package:intl/intl.dart';

// --- Mock Data (가짜 데이터) ---
final List<Transaction> transactions = [
  Transaction(date: '2025.08.17', time: '09:03:53', description: '네이버페이충전', amount: 20000, balanceAfter: 251094, type: TransactionType.withdrawal),
  Transaction(date: '2025.08.17', time: '08:00:17', description: '네이버페이충전', amount: 20000, balanceAfter: 271094, type: TransactionType.withdrawal),
  Transaction(date: '2025.08.16', time: '14:30:00', description: '이자', amount: 94, balanceAfter: 291094, type: TransactionType.deposit),
];
// --- Mock Data 끝 ---


class AccountDetailsScreen extends StatelessWidget {
  final Account account;
  const AccountDetailsScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('거래내역조회'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.home_outlined))],
      ),
      body: Column(
        children: [
          // 상단 계좌 정보
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${account.bankName} ${account.accountName}', style: const TextStyle(fontSize: 18)),
                Text(account.accountNumber, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('${currencyFormat.format(account.balance)}원', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('이체'))),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton(onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AccountManagementScreen(account: account)));
                    }, child: const Text('계좌관리'))),
                  ],
                )
              ],
            ),
          ),
          const Divider(thickness: 8),
          // 거래내역 목록
          Expanded(
            child: ListView.separated(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
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
                        style: TextStyle(color: isWithdrawal ? Colors.blue : Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Text('잔액 ${currencyFormat.format(tx.balanceAfter)}원', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
}
