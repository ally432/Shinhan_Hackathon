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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '수시입출금 계좌 개설',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 상품 정보 섹션
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // 신한은행 로고 섹션
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0046FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '\$',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '신한은행',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 상품명
                        const Text(
                          '쏠편한 입출금통장',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 계좌 정보 카드
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF7BB3F0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A90E2).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.money_off,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '수수료',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        '무료',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.autorenew,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '입출금',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Text(
                                        '자유롭게',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 상품 특징
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFeatureTag('수수료 없음'),
                            const SizedBox(width: 8),
                            _buildFeatureTag('자유입출금'),
                            const SizedBox(width: 8),
                            _buildFeatureTag('온라인 뱅킹'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 계좌 혜택 정보
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '계좌 개설 혜택',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• 모바일 이체수수료 무제한 면제\n• 신한은행 인출수수료 면제\n• 자동이체 수수료 면제',
                                style: TextStyle(
                                  color: Colors.black87,
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

                  const SizedBox(height: 16),

                  // 약관 동의 섹션
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
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
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _allAgreed
                                  ? const Color(0xFF4A90E2).withOpacity(0.1)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _allAgreed
                                    ? const Color(0xFF4A90E2)
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _allAgreed
                                        ? const Color(0xFF4A90E2)
                                        : Colors.white,
                                    border: Border.all(
                                      color: _allAgreed
                                          ? const Color(0xFF4A90E2)
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
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
                        ),

                        const SizedBox(height: 20),

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
                        const SizedBox(height: 12),

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
                        const SizedBox(height: 12),

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
                        const SizedBox(height: 12),

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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 하단 계속하기 버튼
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _term1Agreed && _term2Agreed && _term3Agreed
                      ? _handleContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_term1Agreed && _term2Agreed && _term3Agreed)
                        ? const Color(0xFF4A90E2)
                        : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: (_term1Agreed && _term2Agreed && _term3Agreed) ? 4 : 0,
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

  Widget _buildFeatureTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4A90E2),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, bool isChecked, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF4A90E2) : Colors.white,
              border: Border.all(
                color: isChecked ? const Color(0xFF4A90E2) : Colors.grey[400]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
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
            size: 14,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
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