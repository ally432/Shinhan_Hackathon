import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/step4_school_auth_screen.dart'; // 최종 목적지

class SetNotificationScreen extends StatefulWidget {
  const SetNotificationScreen({super.key});

  @override
  State<SetNotificationScreen> createState() => _SetNotificationScreenState();
}

class _SetNotificationScreenState extends State<SetNotificationScreen> {
  String _selectedNotificationType = '카카오톡';
  String _phoneNumber = '010-1234-5678';

  Future<void> _saveAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('depositNotificationType', _selectedNotificationType);
    await prefs.setString('userPhonenumber', _phoneNumber);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Step4SchoolAuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('예금 가입 (5/5)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('만기 알림\n어떻게 받을까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedNotificationType,
              items: ['카카오톡', '문자메세지', '이메일', '선택안함'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedNotificationType = value);
              },
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 32),
            const Text('휴대폰 번호', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: _phoneNumber),
              decoration: const InputDecoration(
                fillColor: Colors.black12,
                filled: true,
                border: InputBorder.none,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('이전'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _saveAndNavigate, child: const Text('다음'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}