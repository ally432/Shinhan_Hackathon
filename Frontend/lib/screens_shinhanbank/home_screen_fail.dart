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
const String baseUrl = 'http://10.0.2.2:8080';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Account? _mainAccount;   // 표시할 메인 계좌
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildSectionHeader(
              context: context,
              title: '은행',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllAccountsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            Stack(
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: (_mainAccount == null)
                        ? const Text('표시할 계좌가 없습니다.',
                        style: TextStyle(color: Colors.white))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _mainAccount!.accountName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Text(
                            _mainAccount!.accountNumber,
                            style: TextStyle(
                                color: Colors.blue[100], fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${currencyFormat.format(_mainAccount!.balance)}원',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_mainAccount != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showComfortPopup(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.info, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
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

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
  }) {
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

  // ===================== 조회 로직 =====================

  Future<void> _loadAccount() async {
    setState(() { _loading = true; _error = null; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';

      if (userKey.isEmpty) {
        setState(() {
          _mainAccount = _fallbackAccount();
          _loading = false;
        });
        return;
      }

      // 1) 예금(시험보험 등) 우선
      final savings = await _fetchSavings(userKey);
      if (savings != null) {
        setState(() {
          _mainAccount = _mapSavingsToAccount(savings);
          _loading = false;
        });
        return;
      }

      // 2) 수시입출금 대체
      final demand = await _fetchDemand(userKey);
      if (demand != null) {
        setState(() {
          _mainAccount = _mapDemandToAccount(demand);
          _loading = false;
        });
        return;
      }

      // 3) 둘 다 없으면 임의
      setState(() {
        _mainAccount = _fallbackAccount();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '계좌 정보를 불러오지 못했습니다: $e';
        _mainAccount = _fallbackAccount();
        _loading = false;
      });
    }
  }

  /// 예금(정기/시험보험) 첫 번째 계좌
  Future<Map<String, dynamic>?> _fetchSavings(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findSavingsDeposit')
        .replace(queryParameters: {'userKey': userKey});
    final res = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));
    if (res.statusCode != 200 || res.body.isEmpty) return null;

    final root = jsonDecode(res.body);
    final rec = root['REC'];
    // 서버 샘플: { REC: { totalCount, list: [...] } }
    if (rec is Map) {
      final list = rec['list'];
      if (list is List && list.isNotEmpty) {
        final first = list.first;
        return (first is Map) ? Map<String, dynamic>.from(first) : null;
      }
    }
    return null;
  }

  /// 수시입출금 첫 번째 계좌
  Future<Map<String, dynamic>?> _fetchDemand(String userKey) async {
    final uri = Uri.parse('$baseUrl/deposit/findOpenDeposit')
        .replace(queryParameters: {'userKey': userKey});

    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 7));

    if (res.statusCode != 200 || res.body.isEmpty) return null;

    dynamic root;
    try {
      root = jsonDecode(res.body);
    } catch (_) {
      return null;
    }

    // 1) { REC: [...] } 인 경우
    if (root is Map && root['REC'] is List) {
      final list = root['REC'] as List;
      final first = list.firstOrNull;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    }

    // 2) { REC: { list: [...] } } 혹은 { REC: { demandDepositAccountList: [...] } }
    if (root is Map && root['REC'] is Map) {
      final rec = root['REC'] as Map;
      List? list = rec['list'] as List?;
      list ??= rec['demandDepositAccountList'] as List?;
      list ??= rec.values.whereType<List>().firstOrNull; // Map안의 첫번째 List

      final first = list?.firstOrNull;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    }

    // 3) 루트가 곧 리스트
    if (root is List && root.isNotEmpty) {
      final first = root.first;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    }

    // 4) { data: { list: [...] } } 같은 래핑
    if (root is Map && root['data'] is Map) {
      final data = root['data'] as Map;
      final list = data.values.whereType<List>().firstOrNull;
      final first = list?.firstOrNull;
      return (first is Map) ? Map<String, dynamic>.from(first) : null;
    }

    return null;
  }


  Account _mapDemandToAccount(Map<String, dynamic> m) {
    // 서버가 accountBalance/balance 혼용할 수 있음
    final rawBal = (m['balance'] ?? m['accountBalance'] ?? '0').toString();
    final bal = int.tryParse(rawBal.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0;

    return Account(
      bankName: (m['bankName'] ?? '신한은행').toString(),
      accountName: (m['accountName'] ?? '쏠편한 입출금통장 (저축예금)').toString(),
      accountNumber: (m['accountNo'] ?? m['accountNumber'] ?? '-').toString(),
      balance: bal,
      productName: '수시입출금',
      openingDate: '-',
      maturityDate: '-',
      interestRate: 0.0,
    );
  }


  // ===================== 매핑/기본값 =====================

  Account _mapSavingsToAccount(Map<String, dynamic> m) {
    String fmt(String? yyyymmdd) {
      if (yyyymmdd == null || yyyymmdd.length != 8) return '-';
      return '${yyyymmdd.substring(0, 4)}.${yyyymmdd.substring(4, 6)}.${yyyymmdd.substring(6, 8)}';
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

  Account _fallbackAccount() {
    return Account(
      bankName: '신한은행',
      accountName: '쏠편한 입출금통장 (저축예금)',
      accountNumber: '123-123-123123',
      balance: 251094,
      productName: '시험 보험 계좌',
      openingDate: '2025.08.17',
      maturityDate: '2026.08.17',
      interestRate: 2.1,
    );
  }

  // ===================== 팝업(그대로) =====================

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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[50]!, Colors.white],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
                  child: Icon(Icons.favorite, color: Colors.blue[600], size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  '안타깝다 정말 잘 해줬다 화이팅~',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
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

  Widget _buildRewardButton(
      BuildContext context, String title, IconData icon, MaterialColor color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          _showConfirmationDialog(context, title);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color[400],
          foregroundColor: Colors.white,
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green[50]!, Colors.white],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
                  child: Icon(Icons.check_circle, color: Colors.green[600], size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  '$selectedReward 선택!',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text('다시 열심히 해보자~',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
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
