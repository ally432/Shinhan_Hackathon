import 'package:flutter/material.dart';
import 'package:frontend_flutter_yj/models/account_model.dart';
import 'package:frontend_flutter_yj/screens/banking/account_details_screen.dart';
import 'package:frontend_flutter_yj/screens/banking/all_accounts_screen.dart';
import 'package:frontend_flutter_yj/widgets/custom_dialogs.dart'; // ######## 추가된 부분 ########
import 'package:intl/intl.dart';

// --- Mock Data ---
final Account _mainAccount = Account(
  bankName: '신한은행',
  accountName: '쏠편한 입출금통장 (저축예금)',
  accountNumber: '110-500-651356',
  balance: 251094,
  productName: '시험 보험 계좌',
  openingDate: '2025.08.17',
  maturityDate: '2026.08.17',
  interestRate: 2.1,
);
// ---

class HomeScreen extends StatefulWidget { // ######## StatelessWidget에서 변경 ########
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> { // ######## 새로 추가된 클래스 ########

  @override
  void initState() { // ######## 새로 추가된 함수 ########
    super.initState();
    // 화면이 렌더링된 후 2초 뒤에 팝업을 띄우는 시뮬레이션
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) { // 화면이 아직 활성화 상태일 때만 팝업 실행
        showCustomDialog(
          context: context,
          title: '🎉 목표 달성 성공!',
          content: '성적계좌가 만기되었습니다. 우대 금리가 적용된 최종 금액을 확인해보세요!',
          onConfirm: () {
            Navigator.pop(context); // 팝업 닫기
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountDetailsScreen(account: _mainAccount)),
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(child: Text('S')),
        ),
        title: const Text('Super SOL', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildSectionHeader(
              context: context,
              title: '은행',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllAccountsScreen()));
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailsScreen(account: _mainAccount)));
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(_mainAccount.accountName, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(_mainAccount.accountNumber, style: TextStyle(color: Colors.blue[100], fontSize: 14)),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${currencyFormat.format(_mainAccount.balance)}원', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: '금융'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: '혜택'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '주식'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: '전체메뉴'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required BuildContext context, required String title, required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: onPressed,
          child: const Row(
            children: [
              Text('전체보기', style: TextStyle(color: Colors.black54)),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
            ],
          ),
        ),
      ],
    );
  }
}