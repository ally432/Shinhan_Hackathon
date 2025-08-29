import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/info_input/set_tax_type_screen.dart';

class SetPeriodScreen extends StatefulWidget {
  const SetPeriodScreen({super.key});

  @override
  State<SetPeriodScreen> createState() => _SetPeriodScreenState();
}

class _SetPeriodScreenState extends State<SetPeriodScreen> {
  String? _selectedPeriod;

  Future<void> _saveAndNavigate() async {
    if (_selectedPeriod == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('depositPeriod', _selectedPeriod!);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetTaxTypeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final periods = ['12개월'];
    final isComplete = _selectedPeriod != null;

    return Scaffold(
      appBar: AppBar(
          title: const Text('예금 가입')
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('언제까지 모아볼까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: periods.map((period) {
                return Expanded(
                  child: _buildChoiceChip(
                    label: period,
                    selected: _selectedPeriod == period,
                    onSelected: (selected) => setState(() => _selectedPeriod = selected ? period : null),
                  ),
                );
              }).toList(),
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
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedColor: Colors.blue[100], backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.blue[800] : Colors.black, fontWeight: FontWeight.bold),
      side: BorderSide(color: selected ? Colors.blue[800]! : Colors.grey[300]!),
    );
  }
}