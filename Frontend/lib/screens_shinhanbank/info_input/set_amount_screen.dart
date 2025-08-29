import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/info_input/set_period_screen.dart';

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
      if (v != (_selectedAmount ?? -1)) {
        setState(() => _selectedAmount = (v > 0) ? v : null);
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

  @override
  Widget build(BuildContext context) {
    final tenThousandFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '', decimalDigits: 1);
    final amounts = [500000, 1000000, 1500000, 2000000];
    final isComplete = _parseAmount(_amountController.text) > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('예금 가입 (1/5)'),
        actions: [TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('취소'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
                      _amountController.text = selected ? amount.toString() : '';
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '직접입력', suffixText: '원', border: OutlineInputBorder()),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isComplete ? _saveAndNavigate : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  backgroundColor: Colors.blue[800],
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('다음', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({required String label, required bool selected, required Function(bool) onSelected}) {
    return ChoiceChip(
      label: SizedBox(width: double.infinity, child: Center(child: Text(label))),
      selected: selected, onSelected: onSelected,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedColor: Colors.blue[100], backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.blue[800] : Colors.black, fontWeight: FontWeight.bold),
      side: BorderSide(color: selected ? Colors.blue[800]! : Colors.grey[300]!),
    );
  }
}