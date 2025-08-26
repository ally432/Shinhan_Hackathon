import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/transfer_funds_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:intl/intl.dart';

class AccountTerminationScreen extends StatelessWidget {
  final Account account;
  const AccountTerminationScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');
    final interest = (account.balance * account.interestRate / 100).round();
    final finalAmount = account.balance + interest;

    return StepLayout(
      title: '계좌 해지',
      nextButtonText: '해지',
      onNext: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TransferFundsScreen(amount: finalAmount)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('계좌를 해지하면 더 이상 복구할 수 없어요. 정말 해지하시겠어요?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('최초 입금 금액', '${currencyFormat.format(account.balance)}원'),
                _buildInfoRow('가입 기간 / 적용 금리', '1년 / 연 ${account.interestRate}%'),
                _buildInfoRow('이자', '+ ${currencyFormat.format(interest)}원', isHighlight: true),
                const Divider(height: 24),
                _buildInfoRow('예상 최종액', '${currencyFormat.format(finalAmount)}원', isFinal: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, bool isFinal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(value, style: TextStyle(
              fontSize: isFinal ? 20 : 16,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.red : Colors.black
          )),
        ],
      ),
    );
  }
}