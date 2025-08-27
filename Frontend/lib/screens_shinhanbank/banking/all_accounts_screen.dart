import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/account_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';

class AllAccountsScreen extends StatefulWidget {
  const AllAccountsScreen({super.key});

  @override
  State<AllAccountsScreen> createState() => _AllAccountsScreenState();
}

class _AllAccountsScreenState extends State<AllAccountsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true;
  String? _error;

  Account? mainAccount;             // 최상단 카드에 보여줄 대표 계좌 (예금 > 수시입출금)
  List<Account> allAccounts = [];   // 전체
  List<Account> checkingAccounts = []; // 수시입출금
  List<Account> savingsAccounts = [];  // 예금/적금

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAccounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------- Networking ----------------------

  Future<void> _loadAccounts() async {
    setState(() { _loading = true; _error = null; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      if (userKey.isEmpty) {
        throw Exception('로그인 정보(userKey)가 없습니다.');
      }

      // 1) 예금(시험보험 등) 목록
      final savings = await _fetchSavingsList(userKey);
      // 2) 수시입출금 목록
      final demand  = await _fetchDemandList(userKey);

      // 매핑
      final mappedSavings = savings.map(_mapSavingsToAccount).toList();
      final mappedDemand  = demand.map(_mapDemandToAccount).toList();

      // 우선순위: 예금 > 수시입출금
      final combined = <Account>[...mappedSavings, ...mappedDemand];

      setState(() {
        savingsAccounts = mappedSavings;
        checkingAccounts = mappedDemand;
        allAccounts = combined;
        mainAccount = combined.isNotEmpty ? combined.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '계좌 목록을 불러오지 못했습니다: $e';
        _loading = false;
      });
    }
  }

  /// 예금 목록 호출 (/deposit/findSavingsDeposit)
  Future<List<Map<String, dynamic>>> _fetchSavingsList(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findSavingsDeposit')
        .replace(queryParameters: {'userKey': userKey});
    final res = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));

    if (res.statusCode != 200) return [];

    final root = jsonDecode(res.body);
    // 구조: { REC: { list: [...] } } 형태가 일반적
    final rec = root['REC'];
    if (rec is Map && rec['list'] is List) {
      return List<Map<String, dynamic>>.from(rec['list'].map((e) => Map<String, dynamic>.from(e)));
    }
    return [];
  }

  /// 수시입출금 목록 호출 (/deposit/findOpenDeposit)
  Future<List<Map<String, dynamic>>> _fetchDemandList(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit')
        .replace(queryParameters: {'userKey': userKey});
    final res = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));

    if (res.statusCode != 200) return [];

    final root = jsonDecode(res.body);
    // 경우에 따라 REC가 배열/오브젝트 모두 올 수 있어 방어적으로 처리
    final rec = root['REC'];
    if (rec is List) {
      return List<Map<String, dynamic>>.from(rec.map((e) => Map<String, dynamic>.from(e)));
    } else if (rec is Map && rec['list'] is List) {
      return List<Map<String, dynamic>>.from(rec['list'].map((e) => Map<String, dynamic>.from(e)));
    }
    return [];
  }

  // ---------------------- Mapping ----------------------

  Account _mapSavingsToAccount(Map<String, dynamic> m) {
    String fmt(String? yyyymmdd) {
      if (yyyymmdd == null || yyyymmdd.length != 8) return '-';
      return '${yyyymmdd.substring(0,4)}.${yyyymmdd.substring(4,6)}.${yyyymmdd.substring(6,8)}';
    }

    return Account(
      bankName: (m['bankName'] ?? '신한은행').toString(),
      accountName: (m['accountName'] ?? '예금 계좌').toString(),
      accountNumber: (m['accountNo'] ?? '-').toString(),
      balance: int.tryParse((m['depositBalance'] ?? '0').toString()) ?? 0,
      productName: (m['accountName'] ?? '예금').toString(),
      openingDate: fmt(m['accountCreateDate']?.toString()),
      maturityDate: fmt(m['accountExpiryDate']?.toString()),
      interestRate: double.tryParse((m['interestRate'] ?? '0').toString()) ?? 0.0,
    );
  }

  Account _mapDemandToAccount(Map<String, dynamic> m) {
    return Account(
      bankName: (m['bankName'] ?? '신한은행').toString(),
      accountName: (m['accountName'] ?? '수시입출금 계좌').toString(),
      accountNumber: (m['accountNo'] ?? m['accountNumber'] ?? '-').toString(),
      balance: int.tryParse((m['balance'] ?? m['accountBalance'] ?? '0').toString()) ?? 0,
      productName: '수시입출금',
      openingDate: '-',
      maturityDate: '-',
      interestRate: 0.0,
    );
  }

  // ---------------------- UI ----------------------

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('전체계좌조회'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.home_outlined))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 메인 계좌 카드 (예금 > 수시입출금)
                    if (mainAccount != null)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccountDetailsScreen(account: mainAccount!),
                            ),
                          );
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
                              Text(mainAccount!.accountName, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(mainAccount!.accountNumber, style: TextStyle(color: Colors.blue[100], fontSize: 14)),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${currencyFormat.format(mainAccount!.balance)}원',
                                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('표시할 계좌가 없습니다.', style: TextStyle(color: Colors.black54)),
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
            _buildAccountList(allAccounts, currencyFormat),
            _buildAccountList(checkingAccounts, currencyFormat),
            _buildAccountList(savingsAccounts, currencyFormat),
          ],
        ),
      ),
    );
  }

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

// TabBar 고정용
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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
