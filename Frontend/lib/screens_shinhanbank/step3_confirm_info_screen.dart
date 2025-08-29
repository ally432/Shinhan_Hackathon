import 'dart:io';
import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/info_input_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Step3ConfirmInfoScreen extends StatefulWidget {
  final String imagePath;

  const Step3ConfirmInfoScreen({super.key, required this.imagePath});

  @override
  State<Step3ConfirmInfoScreen> createState() => _Step3ConfirmInfoScreenState();
}

class _Step3ConfirmInfoScreenState extends State<Step3ConfirmInfoScreen> {
  String _name = '불러오는 중...';
  String _residentNumber = '불러오는 중...';
  String _birthdate = '불러오는 중...';
  final String _issueDate = '2020.06.12';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final storedName = prefs.getString('userName') ?? '정보 없음';
    final storedBirthdate = prefs.getString('userBirthdate') ?? '정보 없음';

    String residentNumberPrefix = '정보 없음';
    if (storedBirthdate.length == 8) {
      residentNumberPrefix = storedBirthdate.substring(2);
    }

    setState(() {
      _name = storedName;
      _birthdate = storedBirthdate;
      _residentNumber = '$residentNumberPrefix-*******';
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Text(value,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '정보 확인',
      onNext: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const InfoInputScreen()));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('신분증 정보가 맞는지 확인해주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('이름', _name),
                const Divider(),
                _buildInfoRow('주민등록번호', _residentNumber),
                const Divider(),
                _buildInfoRow('발급일자', _issueDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}