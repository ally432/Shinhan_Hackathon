import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/info_input/set_recommender_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';

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

    return StepLayout(
      title: '과세 유형 설정',
      onNext: _saveAndNavigate,
      isNextEnabled: isComplete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '과세유형을 선택해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
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
          // 과세유형 안내 (확장/축소 기능)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('과세 유형 안내', style: TextStyle(fontSize: 14,)),
                  trailing: Icon(_isTaxGuideExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  onTap: () {
                    setState(() => _isTaxGuideExpanded = !_isTaxGuideExpanded);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                if (_isTaxGuideExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      '[일반과세] \n· 가입대상: 제한 없음 (모든 거주자 가능)\n· 세율: 이자·배당소득 15.4% 원천징수\n· 한도: 제한 없음\n\n[비과세종합저축]\n· 가입대상: 만 65세 이상, 장애인 등 법령상 요건 충족자\n· 세율: 이자·배당소득 전액 비과세\n· 한도: 전 금융기관 통합 5천만 원 (초과분은 일반과세)',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: SizedBox(width: double.infinity, child: Center(child: Text(label))),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedColor: Colors.blue[100],
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.blue[800] : Colors.black,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(color: selected ? Colors.blue[800]! : Colors.grey[300]!),
    );
  }
}