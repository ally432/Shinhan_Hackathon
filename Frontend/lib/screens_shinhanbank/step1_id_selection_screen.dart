import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/step2_id_photo_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';

class Step1IdSelectionScreen extends StatelessWidget {
  const Step1IdSelectionScreen({super.key});

  Widget _buildIdButton(BuildContext context, String title) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Step2IdPhotoScreen()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '신분증 확인',
      onNext: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '본인인증을 위해\n신분증을 선택해주세요.',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '촬영 시 빛 반사가 없는 곳에서 진행해주세요.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildIdButton(context, '주민등록증'),
          const SizedBox(height: 16),
          _buildIdButton(context, '운전면허증'),
          const SizedBox(height: 16),
          _buildIdButton(context, '건강보험증'),
        ],
      ),
    );
  }
}