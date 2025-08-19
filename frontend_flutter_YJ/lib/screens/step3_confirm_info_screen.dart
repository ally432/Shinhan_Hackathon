import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_flutter_yj/screens/step4_school_auth_screen.dart';
import 'package:frontend_flutter_yj/widgets/step_layout.dart';

class Step3ConfirmInfoScreen extends StatelessWidget {
  final String imagePath; // Step 2로부터 사진 파일 경로를 전달받음

  const Step3ConfirmInfoScreen({super.key, required this.imagePath});

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label, style: TextStyle(color: Colors.grey[600]))),
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
                builder: (context) => const Step4SchoolAuthScreen()));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('신분증 정보가 맞는지 확인해주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // 촬영된 사진을 여기서 보여줌
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.file(
              File(imagePath),
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
                _buildInfoRow('이름', '김싸피'),
                const Divider(),
                _buildInfoRow('주민등록번호', '001212-3******'),
                const Divider(),
                _buildInfoRow('발급일자', '2024.08.16'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}