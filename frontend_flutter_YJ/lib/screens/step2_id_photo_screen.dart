import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_flutter_yj/screens/step3_confirm_info_screen.dart';
import 'package:frontend_flutter_yj/widgets/step_layout.dart';

class Step2IdPhotoScreen extends StatefulWidget {
  const Step2IdPhotoScreen({super.key});

  @override
  State<Step2IdPhotoScreen> createState() => _Step2IdPhotoScreenState();
}

class _Step2IdPhotoScreenState extends State<Step2IdPhotoScreen> {
  final ImagePicker _picker = ImagePicker();

  // 이미지 선택 로직 (카메라 또는 갤러리)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        // 사진 선택에 성공하면 바로 다음 화면으로 사진 경로를 넘겨줌
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Step3ConfirmInfoScreen(imagePath: pickedFile.path)),
        );
      }
    } catch (e) {
      // 권한 거부 등의 에러가 발생했을 때
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 가져오지 못했습니다. 권한을 확인해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '사진 촬영',
      onNext: null, // 하단 버튼 사용 안 함
      child: Column(
        children: [
          const Text('신분증을 가이드라인에 맞춰 화면에 꽉 채워주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          // 이 위젯을 누르면 카메라가 실행됨
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 50)),
            ),
          ),
          const SizedBox(height: 32),
          // 갤러리 선택 버튼
          OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('갤러리에서 선택하기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}