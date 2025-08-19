import 'package:flutter/material.dart';
import 'package:frontend_flutter_yj/models/account_model.dart';
import 'package:frontend_flutter_yj/screens/banking/account_details_screen.dart';
import 'package:intl/intl.dart';

class AllAccountsScreen extends StatefulWidget {
  const AllAccountsScreen({super.key});

  @override
  State<AllAccountsScreen> createState() => _AllAccountsScreenState();
}

class _AllAccountsScreenState extends State<AllAccountsScreen> with SingleTickerProviderStateMixin {
  // --- Mock Data (가짜 데이터) ---
  final Account mainAccount = Account(
    bankName: '신한은행',
    accountName: '시험 보험 계좌 (저축예금)',
    accountNumber: '110-500-123456',
    balance: 500000,
    productName: '시험 보험 계좌',
    openingDate: '2025.08.17',
    maturityDate: '2026.08.17',
    interestRate: 2.1,
  );

  final List<Account> otherAccounts = [
    Account(
        bankName: '신한은행',
        accountName: '쏠편한 적금',
        accountNumber: '123456123456',
        balance: 1250000,
        productName: '쏠편한 적금',
        openingDate: '2025.01.17',
        maturityDate: '2026.01.17',
        interestRate: 3.5),
    Account(
        bankName: '신한은행',
        accountName: '주택청약 종합저축',
        accountNumber: '234567234567',
        balance: 420000,
        productName: '주택청약',
        openingDate: '2023.03.10',
        maturityDate: '-',
        interestRate: 2.8),
  ];
  // --- Mock Data 끝 ---

  late TabController _tabController;
  late List<Account> allAccounts;
  late List<Account> checkingAccounts; // 입출금 계좌
  late List<Account> savingsAccounts; // 예적금 계좌

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 필터링을 위해 전체 계좌 리스트를 미리 만듭니다.
    allAccounts = [mainAccount, ...otherAccounts];

    // 계좌 이름에 특정 키워드가 포함되어 있는지로 필터링합니다. (Mock Data용)
    checkingAccounts = allAccounts.where((acc) => acc.accountName.contains('입출금')).toList();
    savingsAccounts = allAccounts
        .where((acc) => acc.accountName.contains('예금') || acc.accountName.contains('적금') || acc.accountName.contains('청약'))
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('전체계좌조회'), // 화면 역할에 맞게 제목 변경
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.home_outlined))],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // ... (상단 메인 계좌 카드 부분은 이전과 동일) ...
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 메인 계좌 카드
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailsScreen(account: mainAccount)));
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
                            Text(mainAccount.accountName, style: const TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(mainAccount.accountNumber, style: TextStyle(color: Colors.blue[100], fontSize: 14)),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('${currencyFormat.format(mainAccount.balance)}원', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: '전체'), Tab(text: '입출금'), Tab(text: '예적금')],
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // 전체 탭: 모든 계좌 표시
            _buildAccountList(allAccounts, currencyFormat),
            // 입출금 탭: 필터링된 입출금 계좌만 표시
            _buildAccountList(checkingAccounts, currencyFormat),
            // 예적금 탭: 필터링된 예적금 계좌만 표시
            _buildAccountList(savingsAccounts, currencyFormat),
          ],
        ),
      ),
    );
  }

  // 계좌 목록을 만드는 위젯 (재사용을 위해 함수로 추출)
  Widget _buildAccountList(List<Account> accounts, NumberFormat formatter) {
    if (accounts.isEmpty) {
      return const Center(child: Text('해당하는 계좌가 없습니다.'));
    }
    return ListView.separated(
      itemCount: accounts.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => _buildAccountCard(accounts[index], formatter),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildAccountCard(Account account, NumberFormat formatter) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailsScreen(account: account)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${account.bankName} ${account.accountName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(account.accountNumber, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${formatter.format(account.balance)}원', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// TabBar를 SliverAppBar처럼 고정시키기 위한 Helper 클래스 (이전과 동일)
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.grey[100], child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}