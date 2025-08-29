 import 'package:flutter/foundation.dart';
  import 'package:flutter/services.dart';
  import 'package:path_provider/path_provider.dart';
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:Frontend/screens_shinhanbank/step3_confirm_info_screen.dart';
  import 'package:Frontend/screens_shinhanbank/account_creation_screen.dart';
  import 'package:Frontend/widgets/step_layout.dart';

  class Step2IdPhotoScreen extends StatefulWidget {
    final bool isForAccountCreation;

    const Step2IdPhotoScreen({
      super.key,
      this.isForAccountCreation = false,
    });

    @override
    State<Step2IdPhotoScreen> createState() => _Step2IdPhotoScreenState();
  }

  class _Step2IdPhotoScreenState extends State<Step2IdPhotoScreen> {
    final ImagePicker _picker = ImagePicker();

      Future<void> _pickImage(ImageSource source) async {
      XFile? pickedFile;

      // kDebugMode는 디버그(개발) 모드일 때만 true
      if (kDebugMode) {
        final byteData = await rootBundle.load('assets/id_card_dummy.png');
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/temp_id_card.png').writeAsBytes(
          byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
        pickedFile = XFile(file.path);
      } else {
        try {
          pickedFile = await _picker.pickImage(source: source);
          } catch (e) {
          if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사진을 가져오지 못했습니다. 권한을 확인해주세요.')),
          );
        }
      }

      if (pickedFile != null && mounted) {
        if (widget.isForAccountCreation) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AccountCreationScreen(
              imagePath: pickedFile!.path,
              ),
            ),
          );
        } else {
        Navigator.push(
          context,
            MaterialPageRoute(
              builder: (context) => Step3ConfirmInfoScreen(
              imagePath: pickedFile!.path,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: widget.isForAccountCreation ? '신분증 촬영 (계좌 개설용)' : '사진 촬영',
      onNext: null,
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

          // 계좌 개설용 안내 메세지
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