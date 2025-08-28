import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/account_termination_screen.dart';
import 'package:Frontend/screens_shinhanbank/banking/interest_calc_screen.dart';

class AccountManagementScreen extends StatelessWidget {
  final Account account;
  const AccountManagementScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('계좌관리'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.home_outlined))],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, size: 40, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(account.accountName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(account.accountNumber, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('기본정보'),
                  _buildInfoRow('계좌상품', account.productName),
                  _buildInfoRow('계좌개설일', account.openingDate),
                  _buildInfoRow('만기일', account.maturityDate), // 만기
                  _buildInfoRow('기본금리', '연 ${account.interestRate}%'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('시험 보험 관리'),
                  _buildManagementMenu(context, '예금 만기 이자 조회'),
                  _buildManagementMenu(context, '중도 해지 이자 조회'),
                  _buildManagementMenu(context, '계좌 해지'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildManagementMenu(BuildContext context, String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        if (title == '계좌 해지') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountTerminationScreen(account: account),
            ),
          );
        } else if (title == '예금 만기 이자 조회') {
          // ✅ 만기 이자 조회 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InterestCalcScreen(
                account: account,
                initialMode: InterestMode.maturity,
              ),
            ),
          );
        } else if (title == '중도 해지 이자 조회') {
          // ✅ 중도 해지 이자 조회 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InterestCalcScreen(
                account: account,
                initialMode: InterestMode.early,
              ),
            ),
          );
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }

}