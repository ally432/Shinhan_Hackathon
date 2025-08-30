// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:Frontend/models/account_model.dart';
// import 'package:Frontend/screens_shinhanbank/banking/account_details_screen.dart';
// import 'package:Frontend/screens_shinhanbank/banking/all_accounts_screen.dart';
// import 'package:Frontend/widgets/custom_dialogs.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// const String baseUrl = 'http://211.188.50.244:8080';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   Account? _mainAccount;     // 표시할 메인 계좌 (예금 > 수시입출금 > 임의)
//   bool _loading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAccount();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: RichText(
//           text: TextSpan(
//             style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
//             children: [
//               TextSpan(
//                 text: 'Super ',
//                 style: TextStyle(color: Colors.green),
//               ),
//               TextSpan(
//                 text: 'SOL',
//                 style: TextStyle(color: Colors.blue),
//               ),
//             ],
//           ),
//         ),
//
//     actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
//           IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : (_error != null)
//           ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 24),
//             Padding(
//               padding: const EdgeInsets.only(left: 8.0), // 👈 원하는 만큼 왼쪽 여백을 줍니다. (예: 8)
//               child: _buildSectionHeader(
//                 context: context,
//                 title: '대표 계좌',
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => const AllAccountsScreen()));
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 12),
//             InkWell(
//               onTap: () {
//                 if (_mainAccount == null) return;
//                 Navigator.push(context, MaterialPageRoute(
//                   builder: (context) => AccountDetailsScreen(account: _mainAccount!),
//                 ));
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[800],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: (_mainAccount == null)
//                     ? const Text('표시할 계좌가 없습니다.', style: TextStyle(color: Colors.white))
//                     : Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.account_balance, color: Colors.white, size: 20),
//                         const SizedBox(width: 8),
//                         Text(_mainAccount!.accountName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 30.0),
//                       child: Text(_mainAccount!.accountNumber, style: TextStyle(color: Colors.blue[100], fontSize: 14)),
//                     ),
//                     const SizedBox(height: 11),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         '${currencyFormat.format(_mainAccount!.balance)}원',
//                         style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
//           BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: '금융'),
//           BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: '혜택'),
//           BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '주식'),
//           BottomNavigationBarItem(icon: Icon(Icons.menu), label: '전체메뉴'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader({required BuildContext context, required String title, required VoidCallback onPressed}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         TextButton(
//           onPressed: onPressed,
//           child: const Row(
//             children: [
//               Text('전체보기', style: TextStyle(color: Colors.black54)),
//               Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // -------------------- 데이터 로딩 --------------------
//
//   Future<void> _loadAccount() async {
//     setState(() { _loading = true; _error = null; });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userKey = prefs.getString('userKey') ?? '';
//
//       if (userKey.isEmpty) {
//         setState(() { _mainAccount = _fallbackAccount(); _loading = false; });
//         return;
//       }
//
//       // 1) 예금(시험보험 등) 우선
//       final savings = await _fetchSavings(userKey);
//       if (savings != null) {
//         setState(() {
//           _mainAccount = _mapSavingsToAccount(savings);
//           _loading = false;
//         });
//         // _maybeShowMaturityPopup(); // 기존 코드
//         return;
//       }
//
//       // 2) 수시입출금 대체
//       final demand = await _fetchDemand(userKey);
//       if (demand != null) {
//         setState(() {
//           _mainAccount = _mapDemandToAccount(demand);
//           _loading = false;
//         });
//         return;
//       }
//
//       // 3) 둘 다 없으면 임의
//       setState(() { _mainAccount = _fallbackAccount(); _loading = false; });
//
//     } catch (e) {
//       setState(() {
//         _error = '계좌 정보를 불러오지 못했습니다: $e';
//         _mainAccount = _fallbackAccount();
//         _loading = false;
//       });
//     } finally {
//       if (mounted) {
//         final prefs = await SharedPreferences.getInstance();
//         final bool justLoggedIn = prefs.getBool('justLoggedIn') ?? false;
//
//         if (justLoggedIn) {
//           // Popup flag 있으면 팝업 발생
//           _maybeShowMaturityPopup();
//           await prefs.remove('justLoggedIn');
//         }
//       }
//     }
//   }
//
//   // 예금(시험보험 등) 첫 번째 계좌 반환
//   Future<Map<String, dynamic>?> _fetchSavings(String userKey) async {
//     final uri = Uri.parse('$baseUrl/deposit/findSavingsDeposit')
//         .replace(queryParameters: {'userKey': userKey});
//     final res = await http.get(uri, headers: {'Accept': 'application/json'})
//         .timeout(const Duration(seconds: 7));
//     if (res.statusCode != 200) return null;
//
//     final root = jsonDecode(res.body);
//     final recObj = (root['REC'] as Map?) ?? const {};
//     final list = (recObj['list'] as List?) ?? const [];
//     if (list.isEmpty) return null;
//     final first = list.first;
//     return (first is Map) ? Map<String, dynamic>.from(first) : null;
//   }
//
//   // 수시입출금(입출금 통장) 첫 번째 계좌 반환
//   Future<Map<String, dynamic>?> _fetchDemand(String userKey) async {
//     final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit')
//         .replace(queryParameters: {'userKey': userKey});
//     final res = await http.get(uri, headers: {'Accept': 'application/json'})
//         .timeout(const Duration(seconds: 7));
//     if (res.statusCode != 200) return null;
//
//     final root = jsonDecode(res.body);
//     final rec = root['REC'];
//     if (rec is List) {
//       if (rec.isEmpty) return null;
//       final first = rec.first;
//       return (first is Map) ? Map<String, dynamic>.from(first) : null;
//     } else if (rec is Map) {
//       final list = rec['list'];
//       if (list is List && list.isNotEmpty) {
//         final first = list.first;
//         return (first is Map) ? Map<String, dynamic>.from(first) : null;
//       }
//     }
//     return null;
//   }
//
//   // -------------------- 팝업 조건 --------------------
//
//   void _maybeShowMaturityPopup() {
//     if (!mounted || _mainAccount == null) return;
//     final acc = _mainAccount!;
//
//     // 수시입출금은 제외 (우린 예금만 체크)
//     final isSavings = acc.productName != '수시입출금';
//     if (!isSavings) return;
//
//     // '시험/성적' 키워드가 계좌명에 포함될 때만
//     final hasKeyword = acc.productName.contains('시험') ||
//         acc.productName.contains('성적') ||
//         acc.accountName.contains('시험') ||
//         acc.accountName.contains('성적');
//     if (!hasKeyword) return;
//
//     // 만기일이 오늘인지 확인 (형식: yyyy.MM.dd)
//     final todayStr = DateFormat('yyyy.MM.dd').format(DateTime.now().toUtc().add(const Duration(hours: 9)));
//     if (acc.maturityDate.isEmpty || acc.maturityDate == '-') return;
//     if (acc.maturityDate != todayStr) return;
//
//     // 살짝 지연 후 팝업 (UI 안정)
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (!mounted) return;
//       showCustomDialog(
//         context: context,
//         title: '🎉 목표 달성 성공!',
//         content: '성적계좌가 만기되었습니다. 우대 금리가 적용된 최종 금액을 확인해보세요!',
//         onConfirm: () {
//           Navigator.pop(context);
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: acc)),
//           );
//         },
//       );
//     });
//   }
//
//   // -------------------- 매핑/기본값 --------------------
//
//   Account _mapSavingsToAccount(Map<String, dynamic> m) {
//     String fmt(String? yyyymmdd) {
//       if (yyyymmdd == null || yyyymmdd.length != 8) return '-';
//       return '${yyyymmdd.substring(0,4)}.${yyyymmdd.substring(4,6)}.${yyyymmdd.substring(6,8)}';
//     }
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
//       accountName: (m['accountName'] ?? '쏠편한 입출금통장 (저축예금)').toString(),
//       accountNumber: (m['accountNo'] ?? m['accountNumber'] ?? '-').toString(),
//       balance: int.tryParse((m['balance'] ?? m['accountBalance'] ?? '0').toString()) ?? 0,
//       productName: '수시입출금',
//       openingDate: '-',
//       maturityDate: '-',
//       interestRate: 0.0,
//     );
//   }
//
//   Account _fallbackAccount() {
//     return Account(
//       bankName: '신한은행',
//       accountName: '쏠편한 입출금통장 (저축예금)',
//       accountNumber: '111-555-123123',
//       balance: 251094,
//       productName: '시험 보험 계좌',
//       openingDate: '2025.08.17',
//       maturityDate: '2026.08.17',
//       interestRate: 2.1,
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/account_details_screen.dart';
import 'package:Frontend/screens_shinhanbank/banking/all_accounts_screen.dart';
import 'package:Frontend/widgets/custom_dialogs.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://211.188.50.244:8080';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Account? _mainAccount;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'SuperSOL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black87),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.black87),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 8.0), // 👈 원하는 만큼 왼쪽 여백을 줍니다. (예: 8)
              child: _buildSectionHeader(
                context: context,
                title: '대표 계좌',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AllAccountsScreen()));
                },
              ),
            ),

            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                if (_mainAccount == null) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => AccountDetailsScreen(account: _mainAccount!),
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(20),
=======
            // 포인트 정보 배너
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
>>>>>>> 17348e7b2c76ab38be742ba1ce7ecbb0572d0db7
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.control_point_duplicate, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
<<<<<<< HEAD
                        const Icon(Icons.account_balance, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(_mainAccount!.accountName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text(_mainAccount!.accountNumber, style: TextStyle(color: Colors.blue[100], fontSize: 14)),
                    ),
                    const SizedBox(height: 11),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${currencyFormat.format(_mainAccount!.balance)}원',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
=======
                        Text(
                          '마이신한포인트 \t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t ${currencyFormat.format(2020)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 은행 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '은행',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllAccountsScreen()));
                    },
                    child: const Text(
                      '전체보기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
>>>>>>> 17348e7b2c76ab38be742ba1ce7ecbb0572d0db7
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 메인 계좌 카드
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () {
                  if (_mainAccount == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountDetailsScreen(account: _mainAccount!),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: (_mainAccount == null)
                      ? const Text('표시할 계좌가 없습니다.', style: TextStyle(color: Colors.white))
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _mainAccount!.accountName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _mainAccount!.accountNumber,
                                  style: TextStyle(
                                    color: Colors.blue[100],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${currencyFormat.format(_mainAccount!.balance)}원',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 포인트 모으기 섹션
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '포인트 모으기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 포인트 적립 옵션들
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildPointItem(
                    icon: Icons.savings,
                    title: '서울크루',
                    subtitle: '크루미션하고 포인트...',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildPointItem(
                    icon: Icons.local_fire_department,
                    title: '밸런스게임',
                    subtitle: '짜장면 vs 짬뽕',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildPointItem(
                    icon: Icons.quiz,
                    title: '출석퀴즈',
                    subtitle: '매일 퀴즈 풀고 포인...',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 바로가기 섹션
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '바로가기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '편집',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 바로가기 아이콘들
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShortcutIcon(Icons.savings, '처음크루', Colors.blue),
                  _buildShortcutIcon(Icons.account_balance, '원클릭\n통합대출', Colors.green),
                  _buildShortcutIcon(Icons.swap_horiz, '원클릭\n투자추천', Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShortcutIcon(Icons.airplanemode_active, 'SOL트래블', Colors.amber),
                  _buildShortcutIcon(Icons.account_balance, '정책지원금', Colors.indigo),
                  _buildShortcutIcon(Icons.local_shipping, '땡겨요', Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 100), // 하단 네비게이션 바를 위한 여백
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
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

  Widget _buildPointItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '참여하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------- 데이터 로딩 --------------------

  Future<void> _loadAccount() async {
    setState(() { _loading = true; _error = null; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';

      if (userKey.isEmpty) {
        setState(() { _mainAccount = _fallbackAccount(); _loading = false; });
        return;
      }

      final savings = await _fetchSavings(userKey);
      if (savings != null) {
        setState(() {
          _mainAccount = _mapSavingsToAccount(savings);
          _loading = false;
        });
<<<<<<< HEAD
        // _maybeShowMaturityPopup(); // 기존 코드
=======
>>>>>>> 17348e7b2c76ab38be742ba1ce7ecbb0572d0db7
        return;
      }

      final demand = await _fetchDemand(userKey);
      if (demand != null) {
        setState(() {
          _mainAccount = _mapDemandToAccount(demand);
          _loading = false;
        });
        return;
      }

      setState(() { _mainAccount = _fallbackAccount(); _loading = false; });

    } catch (e) {
      setState(() {
        _error = '계좌 정보를 불러오지 못했습니다: $e';
        _mainAccount = _fallbackAccount();
        _loading = false;
      });
    } finally {
<<<<<<< HEAD
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final bool justLoggedIn = prefs.getBool('justLoggedIn') ?? false;

        if (justLoggedIn) {
          // Popup flag 있으면 팝업 발생
          _maybeShowMaturityPopup();
          await prefs.remove('justLoggedIn');
        }
      }
    }
  }

  // 예금(시험보험 등) 첫 번째 계좌 반환
=======

    }
  }

>>>>>>> 17348e7b2c76ab38be742ba1ce7ecbb0572d0db7
  Future<Map<String, dynamic>?> _fetchSavings(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findSavingsDeposit')
        .replace(queryParameters: {'userKey': userKey});
    final res = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));
    if (res.statusCode != 200) return null;

    final root = jsonDecode(res.body);
    final recObj = (root['REC'] as Map?) ?? const {};
    final list = (recObj['list'] as List?) ?? const [];
    if (list.isEmpty) return null;
    final first = list.first;
    return (first is Map) ? Map<String, dynamic>.from(first) : null;
  }

<<<<<<< HEAD
  // 수시입출금(입출금 통장) 첫 번째 계좌 반환
=======
>>>>>>> 17348e7b2c76ab38be742ba1ce7ecbb0572d0db7
  Future<Map<String, dynamic>?> _fetchDemand(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit')
        .replace(queryParameters: {'userKey': userKey});
    final res = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));
    if (res.statusCode != 200) return null;

    final root = jsonDecode(res.body);
    final rec = root['REC'];
    if (rec is List) {
      if (rec.isEmpty) return null;
      final first = rec.first;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    } else if (rec is Map) {
      final list = rec['list'];
      if (list is List && list.isNotEmpty) {
        final first = list.first;
        return (first is Map) ? Map<String, dynamic>.from(first) : null;
      }
    }
    return null;
  }
<<<<<<< HEAD

  // -------------------- 팝업 조건 --------------------

  void _maybeShowMaturityPopup() {
    if (!mounted || _mainAccount == null) return;
    final acc = _mainAccount!;

    // 수시입출금은 제외 (우린 예금만 체크)
    final isSavings = acc.productName != '수시입출금';
    if (!isSavings) return;

    // '시험/성적' 키워드가 계좌명에 포함될 때만
    final hasKeyword = acc.productName.contains('시험') ||
        acc.productName.contains('성적') ||
        acc.accountName.contains('시험') ||
        acc.accountName.contains('성적');
    if (!hasKeyword) return;

    // 만기일이 오늘인지 확인 (형식: yyyy.MM.dd)
    final todayStr = DateFormat('yyyy.MM.dd').format(DateTime.now().toUtc().add(const Duration(hours: 9)));
    if (acc.maturityDate.isEmpty || acc.maturityDate == '-') return;
    if (acc.maturityDate != todayStr) return;

    // 살짝 지연 후 팝업 (UI 안정)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showCustomDialog(
        context: context,
        title: '🎉 목표 달성 성공!',
        content: '성적계좌가 만기되었습니다. 우대 금리가 적용된 최종 금액을 확인해보세요!',
        onConfirm: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: acc)),
          );
        },
      );
    });
  }

  // -------------------- 매핑/기본값 --------------------

=======
>>>>>>> 17348e7b2c76ab38be742ba1ce7ecbb0572d0db7
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
      accountName: (m['accountName'] ?? '편한 입출금통장 (저축예금)').toString(),
      accountNumber: (m['accountNo'] ?? m['accountNumber'] ?? '-').toString(),
      balance: int.tryParse((m['balance'] ?? m['accountBalance'] ?? '0').toString()) ?? 0,
      productName: '수시입출금',
      openingDate: '-',
      maturityDate: '-',
      interestRate: 0.0,
    );
  }

  Account _fallbackAccount() {
    return Account(
      bankName: '신한은행',
<<<<<<< HEAD
      accountName: '쏠편한 입출금통장 (저축예금)',
=======
      accountName: '편한 입출금통장 (저축예금)',
>>>>>>> 17348e7b2c76ab38be742ba1ce7ecbb0572d0db7
      accountNumber: '111-555-123123',
      balance: 251094,
      productName: '시험 보험 계좌',
      openingDate: '2025.08.17',
      maturityDate: '2026.08.17',
      interestRate: 2.1,
    );
  }
}