import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/info_input/set_recommender_screen.dart';

class SetTaxTypeScreen extends StatefulWidget {
  const SetTaxTypeScreen({super.key});

  @override
  State<SetTaxTypeScreen> createState() => _SetTaxTypeScreenState();
}

class _SetTaxTypeScreenState extends State<SetTaxTypeScreen> {
  String? _selectedTaxType;
  bool _isTaxGuideExpanded = false;

  Future<void> _saveAndNavigate() async {
    if (_selectedTaxType == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('depositTaxType', _selectedTaxType!);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetRecommenderScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxTypes = ['일반과세', '비과세종합'];
    final isComplete = _selectedTaxType != null;

    return Scaffold(
      appBar: AppBar(
          title: const Text('예금 가입')
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
                      onSelected: (selected) => setState(() => _selectedTaxType = selected ? type : null),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('과세유형안내'),
              trailing: Icon(_isTaxGuideExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onTap: () => setState(() => _isTaxGuideExpanded = !_isTaxGuideExpanded),
            ),
            if (_isTaxGuideExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  '비과세종합저축은 만 65세 이상 거주자, 장애인 등 관련 법령에서 정하는 가입대상만 가입 가능하며, 전 금융기관 통합 한도로 운영됩니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
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