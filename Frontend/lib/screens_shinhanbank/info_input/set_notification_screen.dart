import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/step4_school_auth_screen.dart'; // 최종 목적지
import 'package:Frontend/widgets/step_layout.dart';

class SetNotificationScreen extends StatefulWidget {
  const SetNotificationScreen({super.key});

  @override
  State<SetNotificationScreen> createState() => _SetNotificationScreenState();
}

class _SetNotificationScreenState extends State<SetNotificationScreen> {
  String _selectedNotificationType = '선택안함';
  String _phoneNumber = '010-1234-5678'; // 예시 번호

  @override
  void initState() {
    super.initState();
    _loadUserPhoneNumber();
  }

  Future<void> _loadUserPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumber = prefs.getString('userPhonenumber') ?? '010-1234-5678';
    });
  }

  Future<void> _saveAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('depositNotificationType', _selectedNotificationType);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Step4SchoolAuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '만기 알림 설정',
      onNext: _saveAndNavigate,
      isNextEnabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '만기 알림 어떻게 받을까요?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            value: _selectedNotificationType,
            items: ['선택안함', '카카오톡', '문자메세지', '이메일'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedNotificationType = value);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              '휴대폰 번호',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: _phoneNumber),
            decoration: InputDecoration(
              fillColor: Colors.grey[200],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}