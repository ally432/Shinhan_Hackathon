import 'package:flutter/material.dart';
import 'account_creation_screen.dart';

class AccountTermsScreen extends StatefulWidget {
  final String? imagePath;

  const AccountTermsScreen({super.key, this.imagePath});

  @override
  State<AccountTermsScreen> createState() => _AccountOpeningTermsScreenState();
}

class _AccountOpeningTermsScreenState extends State<AccountTermsScreen> {
  bool _allAgreed = false;
  bool _term1Agreed = false;
  bool _term2Agreed = false;
  bool _term3Agreed = false;
  bool _term4Agreed = false;

  void _updateAllAgreed() {
    setState(() {
      _allAgreed = _term1Agreed && _term2Agreed && _term3Agreed && _term4Agreed;
    });
  }

  void _toggleAll(bool value) {
    setState(() {
      _allAgreed = value;
      _term1Agreed = value;
      _term2Agreed = value;
      _term3Agreed = value;
      _term4Agreed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '수시입출금 계좌 개설 약관',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 계좌 정보 섹션
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '신한 SOL 수시입출금통장',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 서비스 태그들
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildServiceTag('연회비 없음'),
                            const SizedBox(width: 8),
                            _buildServiceTag('자유입출금'),
                            const SizedBox(width: 8),
                            _buildServiceTag('온라인 뱅킹'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 계좌 이미지
                        Container(
                          width: 200,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: 40,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '수시입출금통장',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          '연회비 없음, 온라인뱅킹 가능',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '언제든 자유롭게 입출금 가능, 인터넷뱅킹 가능',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 혜택 정보
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '계좌 개설 혜택',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• 계좌 개설 후 30일간 타행 이체 수수료 면제\n• 모바일뱅킹 이용료 3개월 면제',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 약관 동의 섹션
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 전체 동의
                        GestureDetector(
                          onTap: () => _toggleAll(!_allAgreed),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _allAgreed ? Colors.blue[600] : Colors.white,
                                  border: Border.all(
                                    color: _allAgreed
                                        ? Colors.blue[600]!
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _allAgreed
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '약관 전체동의',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16),

                        // 개별 약관들
                        _buildTermItem(
                          '(필수) 예금약관',
                          _term1Agreed,
                              (value) {
                            setState(() {
                              _term1Agreed = value;
                              _updateAllAgreed();
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTermItem(
                          '(필수) 개인정보 처리방침',
                          _term2Agreed,
                              (value) {
                            setState(() {
                              _term2Agreed = value;
                              _updateAllAgreed();
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTermItem(
                          '(필수) 금융거래정보 활용 동의',
                          _term3Agreed,
                              (value) {
                            setState(() {
                              _term3Agreed = value;
                              _updateAllAgreed();
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTermItem(
                          '(선택) 마케팅 정보 수신 동의',
                          _term4Agreed,
                              (value) {
                            setState(() {
                              _term4Agreed = value;
                              _updateAllAgreed();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 계속하기 버튼
          Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _term1Agreed && _term2Agreed && _term3Agreed
                      ? _handleContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_term1Agreed && _term2Agreed && _term3Agreed)
                        ? Colors.blue[600]
                        : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '동의하고 계속하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[600],
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, bool isChecked, Function(bool) onChanged) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!isChecked),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isChecked ? Colors.blue[600] : Colors.white,
              border: Border.all(
                color: isChecked ? Colors.blue[600]! : Colors.grey[400]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  void _handleContinue() {
    // 약관 동의 완료 후 계좌 개설 정보 입력 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountCreationScreen(
          imagePath: widget.imagePath,
        ),
      ),
    );
  }
}