// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:Frontend/models/account_model.dart';
// import 'package:Frontend/screens_shinhanbank/banking/account_details_screen.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// const String baseUrl = 'http://211.188.50.244:8080';
//
// class AllAccountsScreen extends StatefulWidget {
//   const AllAccountsScreen({super.key});
//
//   @override
//   State<AllAccountsScreen> createState() => _AllAccountsScreenState();
// }
//
// class _AllAccountsScreenState extends State<AllAccountsScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   bool _loading = true;
//   String? _error;
//
//   Account? mainAccount;             // 최상단 카드에 보여줄 대표 계좌 (예금 > 수시입출금)
//   List<Account> allAccounts = [];   // 전체
//   List<Account> checkingAccounts = []; // 수시입출금
//   List<Account> savingsAccounts = [];  // 예금/적금
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadAccounts();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   // ---------------------- Networking ----------------------
//
//   Future<void> _loadAccounts() async {
//     setState(() { _loading = true; _error = null; });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userKey = prefs.getString('userKey') ?? '';
//       if (userKey.isEmpty) {
//         throw Exception('로그인 정보(userKey)가 없습니다.');
//       }
//
//       // 1) 예금(시험보험 등) 목록
//       final savings = await _fetchSavingsList(userKey);
//       // 2) 수시입출금 목록
//       final demand  = await _fetchDemandList(userKey);
//
//       // 매핑
//       final mappedSavings = savings.map(_mapSavingsToAccount).toList();
//       final mappedDemand  = demand.map(_mapDemandToAccount).toList();
//
//       // 우선순위: 예금 > 수시입출금
//       final combined = <Account>[...mappedSavings, ...mappedDemand];
//
//       setState(() {
//         savingsAccounts = mappedSavings;
//         checkingAccounts = mappedDemand;
//         allAccounts = combined;
//         mainAccount = combined.isNotEmpty ? combined.first : null;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = '계좌 목록을 불러오지 못했습니다: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   /// 예금 목록 호출 (/deposit/findSavingsDeposit)
//   Future<List<Map<String, dynamic>>> _fetchSavingsList(String userKey) async {
//     final uri = Uri.parse('$baseUrl/deposit/findSavingsDeposit')
//         .replace(queryParameters: {'userKey': userKey});
//     final res = await http.get(uri, headers: {'Accept': 'application/json'})
//         .timeout(const Duration(seconds: 7));
//
//     if (res.statusCode != 200) return [];
//
//     final root = jsonDecode(res.body);
//     // 구조: { REC: { list: [...] } } 형태가 일반적
//     final rec = root['REC'];
//     if (rec is Map && rec['list'] is List) {
//       return List<Map<String, dynamic>>.from(rec['list'].map((e) => Map<String, dynamic>.from(e)));
//     }
//     return [];
//   }
//
//   /// 수시입출금 목록 호출 (/deposit/findOpenDeposit)
//   Future<List<Map<String, dynamic>>> _fetchDemandList(String userKey) async {
//     final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit')
//         .replace(queryParameters: {'userKey': userKey});
//     final res = await http.get(uri, headers: {'Accept': 'application/json'})
//         .timeout(const Duration(seconds: 7));
//
//     if (res.statusCode != 200) return [];
//
//     final root = jsonDecode(res.body);
//     // 경우에 따라 REC가 배열/오브젝트 모두 올 수 있어 방어적으로 처리
//     final rec = root['REC'];
//     if (rec is List) {
//       return List<Map<String, dynamic>>.from(rec.map((e) => Map<String, dynamic>.from(e)));
//     } else if (rec is Map && rec['list'] is List) {
//       return List<Map<String, dynamic>>.from(rec['list'].map((e) => Map<String, dynamic>.from(e)));
//     }
//     return [];
//   }
//
//   // ---------------------- Mapping ----------------------
//
//   Account _mapSavingsToAccount(Map<String, dynamic> m) {
//     String fmt(String? yyyymmdd) {
//       if (yyyymmdd == null || yyyymmdd.length != 8) return '-';
//       return '${yyyymmdd.substring(0,4)}.${yyyymmdd.substring(4,6)}.${yyyymmdd.substring(6,8)}';
//     }
//
//     return Account(
//       bankName: (m['bankName'] ?? '신한은행').toString(),
//       accountName: (m['accountName'] ?? '예금 계좌').toString(),
//       accountNumber: (m['accountNo'] ?? '-').toString(),
//       balance: int.tryParse((m['depositBalance'] ?? '0').toString()) ?? 0,
//       productName: (m['accountName'] ?? '예금').toString(),
//       openingDate: fmt(m['accountCreateDate']?.toString()),
//       maturityDate: fmt(m['accountExpiryDate']?.toString()),
//       interestRate: double.tryParse((m['interestRate'] ?? '0').toString()) ?? 0.0,
//     );
//   }
//
//   Account _mapDemandToAccount(Map<String, dynamic> m) {
//     return Account(
//       bankName: (m['bankName'] ?? '신한은행').toString(),
//       accountName: (m['accountName'] ?? '수시입출금 계좌').toString(),
//       accountNumber: (m['accountNo'] ?? m['accountNumber'] ?? '-').toString(),
//       balance: int.tryParse((m['balance'] ?? m['accountBalance'] ?? '0').toString()) ?? 0,
//       productName: '수시입출금',
//       openingDate: '-',
//       maturityDate: '-',
//       interestRate: 0.0,
//     );
//   }
//
//   // ---------------------- UI ----------------------
//
//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('전체계좌조회'),
//         actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.home_outlined))],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : (_error != null)
//           ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
//           : NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // 메인 계좌 카드 (예금 > 수시입출금)
//                     if (mainAccount != null)
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AccountDetailsScreen(account: mainAccount!),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[800],
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(mainAccount!.accountName, style: const TextStyle(color: Colors.white, fontSize: 16)),
//                               const SizedBox(height: 4),
//                               Text(mainAccount!.accountNumber, style: TextStyle(color: Colors.blue[100], fontSize: 14)),
//                               const SizedBox(height: 16),
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Text(
//                                   '${currencyFormat.format(mainAccount!.balance)}원',
//                                   style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     else
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: const Text('표시할 계좌가 없습니다.', style: TextStyle(color: Colors.black54)),
//                       ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _SliverTabBarDelegate(
//                 TabBar(
//                   controller: _tabController,
//                   tabs: const [Tab(text: '전체'), Tab(text: '입출금'), Tab(text: '예적금')],
//                   labelColor: Colors.black,
//                   unselectedLabelColor: Colors.grey,
//                   indicatorColor: Colors.black,
//                 ),
//               ),
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildAccountList(allAccounts, currencyFormat),
//             _buildAccountList(checkingAccounts, currencyFormat),
//             _buildAccountList(savingsAccounts, currencyFormat),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAccountList(List<Account> accounts, NumberFormat formatter) {
//     if (accounts.isEmpty) {
//       return const Center(child: Text('해당하는 계좌가 없습니다.'));
//     }
//     return ListView.separated(
//       itemCount: accounts.length,
//       padding: const EdgeInsets.all(16),
//       itemBuilder: (context, index) => _buildAccountCard(accounts[index], formatter),
//       separatorBuilder: (context, index) => const SizedBox(height: 12),
//     );
//   }
//
//   Widget _buildAccountCard(Account account, NumberFormat formatter) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailsScreen(account: account)));
//       },
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('${account.bankName} ${account.accountName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//             const SizedBox(height: 4),
//             Text(account.accountNumber, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//             const SizedBox(height: 16),
//             Align(
//               alignment: Alignment.centerRight,
//               child: Text('${formatter.format(account.balance)}원', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // TabBar 고정용
// class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverTabBarDelegate(this._tabBar);
//   final TabBar _tabBar;
//
//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(color: Colors.grey[100], child: _tabBar);
//   }
//
//   @override
//   bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/account_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://211.188.50.244:8080';

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '전체계좌조회',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF475569),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {},
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  size: 20,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '계좌 정보를 불러오는 중...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      )
          : (_error != null)
          ? Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 32,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 메인 계좌 카드 (예금 > 수시입출금)
                      if (mainAccount != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountDetailsScreen(account: mainAccount!),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1E40AF),
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF60A5FA),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        mainAccount!.accountName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        mainAccount!.bankName,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const SizedBox(height: 6),
                                Text(
                                  mainAccount!.accountNumber,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '잔액',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${currencyFormat.format(mainAccount!.balance)}원',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.account_balance_outlined,
                                  size: 32,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '표시할 계좌가 없습니다.',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: [
                    _buildTab('전체', Icons.apps_rounded),
                    _buildTab('입출금', Icons.account_balance_wallet_outlined),
                    _buildTab('예적금', Icons.savings_outlined),
                  ],
                  labelColor: const Color(0xFF1E40AF),
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  indicator: BoxDecoration(
                    color: const Color(0xFF1E40AF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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

  Widget _buildTab(String text, IconData icon) {
    return Tab(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildAccountList(List<Account> accounts, NumberFormat formatter) {
    if (accounts.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 40,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '해당하는 계좌가 없습니다.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: accounts.length,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) => _buildAccountCard(accounts[index], formatter, index),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }

  Widget _buildAccountCard(Account account, NumberFormat formatter, int index) {
    final isChecking = account.productName == '수시입출금';
    final cardColors = isChecking
        ? [const Color(0xFF059669), const Color(0xFF10B981), const Color(0xFF34D399)]
        : [const Color(0xFF1E40AF), const Color(0xFF3B82F6), const Color(0xFF60A5FA)];

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AccountDetailsScreen(account: account)
            )
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + (index * 100)),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: cardColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cardColors[1].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      account.bankName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    account.accountName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                account.accountNumber,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '잔액',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${formatter.format(account.balance)}원',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}