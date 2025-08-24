import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Frontend/screens_shinhanbank/step3_confirm_info_screen.dart';
import 'package:Frontend/screens_shinhanbank/account_creation_screen.dart';  // 새로 생성한 화면
import 'package:Frontend/widgets/step_layout.dart';

class Step2IdPhotoScreen extends StatefulWidget {
  final bool isForAccountCreation; // 계좌 개설용인지 구분하는 플래그

  const Step2IdPhotoScreen({
    super.key,
    this.isForAccountCreation = false,
  });

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
        // 계좌 개설용인지에 따라 다른 화면으로 이동
        if (widget.isForAccountCreation) {
          // 계좌 개설용: 계좌 개설 정보 입력 화면으로
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AccountCreationScreen(
                imagePath: pickedFile.path,
              ),
            ),
          );
        } else {
          // 기존 로직: 정보 확인 화면으로
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Step3ConfirmInfoScreen(
                imagePath: pickedFile.path,
              ),
            ),
          );
        }
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
      title: widget.isForAccountCreation ? '신분증 촬영 (계좌 개설용)' : '사진 촬영',
      onNext: null, // 하단 버튼 사용 안 함
      child: Column(
        children: [
          Text(
            widget.isForAccountCreation
                ? '계좌 개설을 위해 신분증을\n가이드라인에 맞춰 화면에 꽉 채워주세요.'
                : '신분증을 가이드라인에 맞춰 화면에 꽉 채워주세요.',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 계좌 개설용일 때 안내 메시지 추가
          if (widget.isForAccountCreation) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '신분증 정보는 계좌 개설을 위한\n본인 확인 용도로만 사용됩니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

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
                child: Icon(Icons.camera_alt, color: Colors.white, size: 50),
              ),
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