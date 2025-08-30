import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/info_input/set_period_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';

class SetAmountScreen extends StatefulWidget {
  const SetAmountScreen({super.key});

  @override
  State<SetAmountScreen> createState() => _SetAmountScreenState();
}

class _SetAmountScreenState extends State<SetAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  int? _selectedAmount;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      final v = _parseAmount(_amountController.text);
      // 입력값이 변경될 때마다 setState를 호출하여 UI(버튼 상태)를 갱신합니다.
      if (v != (_selectedAmount ?? -1)) {
        setState(() {
          _selectedAmount = (v > 0) ? v : null;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int _parseAmount(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  Future<void> _saveAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('depositInitAmount', _parseAmount(_amountController.text));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetPeriodScreen()),
      );
    }
  }

  Widget _buildChoiceChip({required String label, required bool selected, required Function(bool) onSelected}) {
    return ChoiceChip(
      label: SizedBox(width: double.infinity, child: Center(child: Text(label))),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedColor: Colors.blue[100],
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.blue[800] : Colors.black, fontWeight: FontWeight.bold),
      side: BorderSide(color: selected ? Colors.blue[800]! : Colors.grey[300]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenThousandFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '', decimalDigits: 0);
    final amounts = [500000, 1000000, 1500000, 2000000];

    // 버튼 활성화 조건을 계산하는 변수
    final isComplete = _parseAmount(_amountController.text) > 0;

    return StepLayout(
      title: '예치금 설정',
      onNext: _saveAndNavigate,
      // 계산된 조건을 isNextEnabled에 전달하여 버튼 상태를 동적으로 변경
      isNextEnabled: isComplete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('얼마로 시작할까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 14,
            children: amounts.map((amount) {
              final label = '${tenThousandFormat.format(amount / 10000)} 만원';
              return _buildChoiceChip(
                label: label,
                selected: _selectedAmount == amount,
                onSelected: (selected) {
                  // Chip을 선택할 때도 setState가 호출되므로 버튼 상태가 즉시 갱신
                  setState(() {
                    _amountController.text = selected ? amount.toString() : '';
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '직접입력',
              // border: const OutlineInputBorder(),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),

              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              // suffix: const Padding(
              //   padding: EdgeInsets.only(right:1.0),
              //   child: Text(
              //     '원',
              //     style: TextStyle(
              //       color: Colors.black,
              //       fontSize: 16,
              //     ),
              //   ),
              // ),
              suffix: Text(
                '원',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}