import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Frontend/models/account_model.dart';
import 'package:Frontend/screens_shinhanbank/banking/account_details_screen.dart';
import 'package:Frontend/screens_shinhanbank/banking/all_accounts_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 작은 헬퍼: Iterable.firstOrNull
extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

const String baseUrl = 'http://211.188.50.244:8080';

class HomeFailScreen extends StatefulWidget {
  const HomeFailScreen({super.key});

  @override
  State<HomeFailScreen> createState() => _HomeFailScreenState();
}

class _HomeFailScreenState extends State<HomeFailScreen> {
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
      backgroundColor: const Color(0xFFF5F7FA), // 홈과 통일
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
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,
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
                  right: 0, top: 0,
                  child: Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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
            // 포인트 정보 배너 (홈과 통일)
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24, shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.control_point_duplicate, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      '마이신한포인트   2,020',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // 섹션 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('은행', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllAccountsScreen()));
                    },
                    child: const Text('전체보기', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 메인 계좌 카드 (홈과 통일된 그라디언트/라운딩/섀도우)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  InkWell(
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
                                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _mainAccount!.accountName,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _mainAccount!.accountNumber,
                                      style: TextStyle(color: Colors.blue[100], fontSize: 12),
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
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 실패 화면만의 위로 버튼(정보 아이콘)
                  if (_mainAccount != null)
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => _showComfortPopup(context),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: Colors.orange[400],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.info, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 포인트 모으기 (홈과 통일)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('포인트 모으기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 16),

            // 포인트 카드 3개
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildPointItem(icon: Icons.savings, title: '서울크루', subtitle: '크루미션하고 포인트...', color: Colors.blue),
                  const SizedBox(height: 12),
                  _buildPointItem(icon: Icons.local_fire_department, title: '밸런스게임', subtitle: '짜장면 vs 짬뽕', color: Colors.orange),
                  const SizedBox(height: 12),
                  _buildPointItem(icon: Icons.quiz, title: '출석퀴즈', subtitle: '매일 퀴즈 풀고 포인...', color: Colors.purple),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 바로가기 (홈과 통일)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('바로가기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('편집', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 바로가기 아이콘 3x2 (홈과 통일)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildShortcutIcon(Icons.savings, '처음크루', Colors.blue),
                      _buildShortcutIcon(Icons.account_balance, '원클릭\n통합대출', Colors.green),
                      _buildShortcutIcon(Icons.swap_horiz, '원클릭\n투자추천', Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildShortcutIcon(Icons.airplanemode_active, 'SOL트래블', Colors.amber),
                      _buildShortcutIcon(Icons.account_balance, '정책지원금', Colors.indigo),
                      _buildShortcutIcon(Icons.local_shipping, '땡겨요', Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
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

  // ---------- 공통 UI 요소들 (홈과 동일 스타일) ----------
  Widget _buildPointItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
            child: const Text('참여하기', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  // ---------- 데이터 로딩 ----------
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
        setState(() { _mainAccount = _mapSavingsToAccount(savings); _loading = false; });
        return;
      }

      final demand = await _fetchDemand(userKey);
      if (demand != null) {
        setState(() { _mainAccount = _mapDemandToAccount(demand); _loading = false; });
        return;
      }

      setState(() { _mainAccount = _fallbackAccount(); _loading = false; });
    } catch (e) {
      setState(() {
        _error = '계좌 정보를 불러오지 못했습니다: $e';
        _mainAccount = _fallbackAccount();
        _loading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchSavings(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findSavingsDeposit')
        .replace(queryParameters: {'userKey': userKey});
    final res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 7));
    if (res.statusCode != 200 || res.body.isEmpty) return null;

    final root = jsonDecode(res.body);
    final rec = root['REC'];
    if (rec is Map) {
      final list = rec['list'];
      if (list is List && list.isNotEmpty) {
        final first = list.first;
        return (first is Map) ? Map<String, dynamic>.from(first) : null;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchDemand(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit').replace(queryParameters: {'userKey': userKey});
    final res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 7));
    if (res.statusCode != 200 || res.body.isEmpty) return null;

    dynamic root;
    try { root = jsonDecode(res.body); } catch (_) { return null; }

    if (root is Map && root['REC'] is List) {
      final list = root['REC'] as List;
      final first = list.firstOrNull;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    }
    if (root is Map && root['REC'] is Map) {
      final rec = root['REC'] as Map;
      List? list = rec['list'] as List?;
      list ??= rec['demandDepositAccountList'] as List?;
      list ??= rec.values.whereType<List>().firstOrNull;
      final first = list?.firstOrNull;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    }
    if (root is List && root.isNotEmpty) {
      final first = root.first;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    }
    if (root is Map && root['data'] is Map) {
      final data = root['data'] as Map;
      final list = data.values.whereType<List>().firstOrNull;
      final first = list?.firstOrNull;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    }
    return null;
  }

  // ---------- 매핑/기본값 ----------
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
    final rawBal = (m['balance'] ?? m['accountBalance'] ?? '0').toString();
    final bal = int.tryParse(rawBal.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0;
    return Account(
      bankName: (m['bankName'] ?? '신한은행').toString(),
      accountName: (m['accountName'] ?? '편한 입출금통장 (저축예금)').toString(),
      accountNumber: (m['accountNo'] ?? m['accountNumber'] ?? '-').toString(),
      balance: bal,
      productName: '수시입출금',
      openingDate: '-',
      maturityDate: '-',
      interestRate: 0.0,
    );
  }

  Account _fallbackAccount() {
    return Account(
      bankName: '신한은행',
      accountName: '편한 입출금통장 (저축예금)',
      accountNumber: '111-555-123123',
      balance: 251094,
      productName: '시험 보험 계좌',
      openingDate: '2025.08.17',
      maturityDate: '2026.08.17',
      interestRate: 2.1,
    );
  }

  // ---------- 실패 화면 전용 위로 팝업 ----------
  void _showComfortPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.blue[50]!, Colors.white],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
                  child: Icon(Icons.favorite, color: Colors.blue[600], size: 30),
                ),
                const SizedBox(height: 16),
                const Text('조금 아쉬웠지만 성장 중입니다! \n우리 계속 가요 🚀',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _buildRewardButton(context, '땡겨요', Icons.flash_on, Colors.orange),
                const SizedBox(height: 12),
                _buildRewardButton(context, '신한 마이포인트', Icons.stars, Colors.blue),
                const SizedBox(height: 12),
                _buildRewardButton(context, '기프티콘', Icons.card_giftcard, Colors.green),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardButton(BuildContext context, String title, IconData icon, MaterialColor color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          _showConfirmationDialog(context, title);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color[400], foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String selectedReward) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.green[50]!, Colors.white],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
                  child: Icon(Icons.check_circle, color: Colors.green[600], size: 30),
                ),
                const SizedBox(height: 16),
                Text('$selectedReward 선택!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('다시 열심히 해보자~',
                    style: TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600], foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: const Text('메인화면으로 돌아가기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
