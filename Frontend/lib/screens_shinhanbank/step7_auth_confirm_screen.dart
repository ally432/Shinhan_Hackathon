import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/step8_terms_agree_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';

class Step7AuthConfirmScreen extends StatelessWidget {
  const Step7AuthConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StepLayout(
        title: '인증 완료',
        nextButtonText: '마지막 단계로',
        onNext: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Step8TermsAgreeScreen()));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.blue, size: 80),
            const SizedBox(height: 24),
            const Text('본인인증이\n안전하게 완료되었습니다.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text('이제 마지막 단계인 약관 동의만 남았어요.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ));
  }
}