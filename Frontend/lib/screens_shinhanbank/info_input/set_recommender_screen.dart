import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/info_input/set_notification_screen.dart';

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
    final isComplete = _recommenderController.text.isNotEmpty || _noRecommenderSelected;

    return Scaffold(
      appBar: AppBar(title: const Text('예금 가입 (4/5)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
                    if (selected) _recommenderController.clear();
                  });
                },
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('이전'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: isComplete ? _saveAndNavigate : null, child: const Text('다음'))),
              ],
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