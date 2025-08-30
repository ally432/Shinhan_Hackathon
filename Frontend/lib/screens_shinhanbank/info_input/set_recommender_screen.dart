import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/info_input/set_notification_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';

class SetRecommenderScreen extends StatefulWidget {
  const SetRecommenderScreen({super.key});

  @override
  State<SetRecommenderScreen> createState() => _SetRecommenderScreenState();
}

class _SetRecommenderScreenState extends State<SetRecommenderScreen> {
  final TextEditingController _recommenderController = TextEditingController();
  bool _noRecommenderSelected = false;

  @override
  void initState() {
    super.initState();
    _recommenderController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _recommenderController.dispose();
    super.dispose();
  }

  Future<void> _saveAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final recommender = _noRecommenderSelected ? '없음' : _recommenderController.text;
    await prefs.setString('depositRecommender', recommender);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetNotificationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // '다음' 버튼 활성화 조건
    final isComplete = _recommenderController.text.isNotEmpty || _noRecommenderSelected;

    return StepLayout(
      title: '추천 직원',
      onNext: _saveAndNavigate,
      isNextEnabled: isComplete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '권유 직원이 있으신가요?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _recommenderController,
            // '권유 직원 없음' 선택 시 TextField 비활성화
            enabled: !_noRecommenderSelected,
            decoration: InputDecoration(
              hintText: '직원 이름 입력',
              fillColor: _noRecommenderSelected ? Colors.grey[200] : Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // '권유 직원 없음' 선택 버튼
          _buildChoiceChip(
            label: '권유 직원 없음',
            selected: _noRecommenderSelected,
            onSelected: (selected) {
              setState(() {
                _noRecommenderSelected = selected;
                // '없음'을 선택하면, 입력 필드를 초기화
                if (selected) _recommenderController.clear();
              });
            },
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
      label: SizedBox(
        width: double.infinity,
        child: Center(child: Text(label)),
      ),
      showCheckmark: false,
      selected: selected,
      onSelected: onSelected,
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