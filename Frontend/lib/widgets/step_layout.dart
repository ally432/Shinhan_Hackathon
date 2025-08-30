import 'package:flutter/material.dart';

class StepLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final String? nextButtonText;
  final VoidCallback? onNext;
  final bool isNextEnabled;
  final bool centerTitle;

  const StepLayout({
    super.key,
    required this.title,
    required this.child,
    this.nextButtonText = '다음',
    this.onNext,
    this.isNextEnabled = true,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(title),
        centerTitle: centerTitle,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: child,
            ),
          ),
          // '다음' 버튼이 필요한 경우에만 하단 버튼 영역 표시
          if (onNext != null)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: isNextEnabled ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(nextButtonText!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}