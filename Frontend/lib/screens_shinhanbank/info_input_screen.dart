import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/step4_school_auth_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoInputScreen extends StatefulWidget {
  const InfoInputScreen({super.key});

  @override
  State<InfoInputScreen> createState() => _InfoInputScreenState();
}

class _InfoInputScreenState extends State<InfoInputScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- 각 단계별 상태 변수 ---
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recommenderController = TextEditingController();
  int? _selectedAmount;
  String? _selectedPeriod;
  String? _selectedTaxType;
  bool _noRecommenderSelected = false;
  bool _isTaxGuideExpanded = false;
  static const String kSelectedAmountKey = 'depositInitAmount';

  int _parseAmount(String s) {
    // 숫자만 남기고 파싱(혹시 콤마/공백이 들어와도 안전)
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  Future<void> _saveSelectedAmount() async {
    final prefs = await SharedPreferences.getInstance();
    final amount = _parseAmount(_amountController.text);
    await prefs.setInt(kSelectedAmountKey, amount);
  }


  @override
  void initState() {
    super.initState();
    _recommenderController.addListener(() => setState(() {}));
    _amountController.addListener(() {
      final v = _parseAmount(_amountController.text);
      if (v != (_selectedAmount ?? -1)) {
        setState(() {
          _selectedAmount = (v > 0) ? v : null;
        });
      }
    });
  }


  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    _recommenderController.dispose();
    super.dispose();
  }

  // --- 각 단계의 완료 여부 ---
  bool get _isCurrentStepComplete {
    switch (_currentPage) {
      case 0:
        return _parseAmount(_amountController.text) > 0; // ← 변경
      case 1:
        return _selectedPeriod != null;
      case 2:
        return _selectedTaxType != null;
      case 3:
        return _recommenderController.text.isNotEmpty || _noRecommenderSelected;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1단계(출금계좌)를 제외한 페이지 목록
    final List<Widget> pages = [
      _buildPage(_buildStep_SetAmount()),
      _buildPage(_buildStep_SetPeriod()),
      _buildPage(_buildStep_SetTaxType()),
      _buildPage(_buildStep_SetRecommender()),
      _buildPage(_buildStep_SetNotification()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('예금 가입'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소'))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('정보입력', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('${_currentPage + 1}/${pages.length}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              children: pages,
            ),
          ),
          _buildBottomButtons(pages.length),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(int pageCount) {
    bool isLastPage = _currentPage == pageCount - 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('이전', style: TextStyle(color: Colors.black)),
                )
              ),
            if (_currentPage > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isCurrentStepComplete ? () async {
                  if (_currentPage == 0) {
                    await _saveSelectedAmount();
                  }

                  if (isLastPage) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Step4SchoolAuthScreen()),
                    );
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                } : null,

                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isLastPage ? '다음' : '다음', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: child);

  // --- 각 단계별 UI 구현 ---

  Widget _buildStep_SetAmount() {
    final tenThousandFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '', decimalDigits: 1);
    final amounts = [500000, 1000000, 1500000, 2000000];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('얼마로 시작할까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amounts.map((amount) {
              final label = '${tenThousandFormat.format(amount / 10000)}만원';
              return _buildChoiceChip(
                label: label,
                selected: _selectedAmount == amount,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAmount = amount;
                      _amountController.text = amount.toString();
                    } else {
                      _selectedAmount = null;
                      _amountController.clear();
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '직접입력',
              suffixText: '원',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep_SetPeriod() {
    final periods = ['12개월'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('언제까지 모아볼까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          children: periods.map((period) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildChoiceChip(
                  label: period,
                  selected: _selectedPeriod == period,
                  onSelected: (selected) {
                    setState(() => _selectedPeriod = selected ? period : null);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep_SetTaxType() {
    final taxTypes = ['일반과세', '비과세종합'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('과세유형을 선택해주세요', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          children: taxTypes.map((type) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildChoiceChip(
                  label: type,
                  selected: _selectedTaxType == type,
                  onSelected: (selected) {
                    setState(() => _selectedTaxType = selected ? type : null);
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            ListTile(
              title: const Text('과세유형안내'),
              trailing: Icon(_isTaxGuideExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onTap: () {
                setState(() {
                  _isTaxGuideExpanded = !_isTaxGuideExpanded;
                });
              },
            ),
            if (_isTaxGuideExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  '비과세종합저축은 만 65세 이상 거주자, 장애인 등 관련 법령에서 정하는 가입대상만 가입 가능하며, 전 금융기관 통합 한도로 운영됩니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep_SetRecommender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('권유 직원이 있으신가요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextField(
          controller: _recommenderController,
          enabled: !_noRecommenderSelected,
          decoration: InputDecoration(
            hintText: '직원 이름 입력',
            fillColor: _noRecommenderSelected ? Colors.grey[200] : Colors.white,
            filled: true,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _buildChoiceChip(
            label: '권유 직원 없음',
            selected: _noRecommenderSelected,
            onSelected: (selected) {
              setState(() {
                _noRecommenderSelected = selected;
                if (selected) {
                  _recommenderController.clear();
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep_SetNotification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('만기 알림\n어떻게 받을까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4)),
        const SizedBox(height: 32),
        DropdownButtonFormField<String>(
          value: '카카오톡',
          items: ['카카오톡', '문자메세지', '이메일', '선택안함'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {},
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 32),
        const Text('휴대폰번호', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        const TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: '010-1234-5678',
            fillColor: Colors.black12,
            filled: true,
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: SizedBox(
        width: double.infinity,
        child: Center(child: Text(label)),
      ),
      selected: selected,
      onSelected: onSelected,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedColor: Colors.blue[100],
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.blue[800] : Colors.black, fontWeight: FontWeight.bold),
      side: BorderSide(color: selected ? Colors.blue[800]! : Colors.grey[300]!),
    );
  }
}