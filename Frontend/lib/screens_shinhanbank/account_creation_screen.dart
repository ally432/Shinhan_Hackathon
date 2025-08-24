import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Frontend/screens_shinhanbank/account_selection_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountCreationScreen extends StatefulWidget {
  final String? imagePath;

  const AccountCreationScreen({super.key, this.imagePath});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  static const String baseUrl = 'http://10.0.2.2:8080';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('수시입출금 계좌 개설'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.account_balance,
                          color: Colors.blue[600], size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        '신한 SOL 수시입출금통장',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '언제든 자유롭게 입출금 가능한 기본 통장',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  '개인정보 입력',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 이름 입력
                _buildInputField(
                  controller: _nameController,
                  label: '이름',
                  hintText: '실명을 입력하세요',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),

                // 이메일 입력
                _buildInputField(
                  controller: _emailController,
                  label: '이메일',
                  hintText: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '이메일을 입력해주세요';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }
                    return null;
                  },
                ),

                // 생년월일 입력
                _buildInputField(
                  controller: _birthdateController,
                  label: '생년월일',
                  hintText: 'YYYYMMDD (8자리)',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '생년월일을 입력해주세요';
                    }
                    if (value!.length != 8) {
                      return '생년월일을 8자리로 입력해주세요';
                    }
                    return null;
                  },
                ),

                // 휴대폰 번호 입력
                _buildInputField(
                  controller: _phoneController,
                  label: '휴대폰 번호',
                  hintText: '01012345678',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '휴대폰 번호를 입력해주세요';
                    }
                    if (value!.length != 11) {
                      return '휴대폰 번호를 정확히 입력해주세요';
                    }
                    return null;
                  },
                ),

                // 주소 입력
                _buildInputField(
                  controller: _addressController,
                  label: '주소',
                  hintText: '주소를 입력하세요',
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '주소를 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  '계좌 비밀번호 설정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 계좌 비밀번호 입력
                _buildInputField(
                  controller: _passwordController,
                  label: '계좌 비밀번호',
                  hintText: '숫자 4자리',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '계좌 비밀번호를 입력해주세요';
                    }
                    if (value!.length != 4) {
                      return '계좌 비밀번호는 4자리로 입력해주세요';
                    }
                    return null;
                  },
                ),

                // 계좌 비밀번호 확인
                _buildInputField(
                  controller: _confirmPasswordController,
                  label: '계좌 비밀번호 확인',
                  hintText: '비밀번호를 다시 입력하세요',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '계좌 비밀번호를 다시 입력해주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // 계좌 개설 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      '계좌 개설하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscureText = false,
    int maxLines = 1,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            obscureText: obscureText,
            maxLines: maxLines,
            textInputAction: textInputAction,
            onTap: () {
              Future.delayed(const Duration(milliseconds: 300), () {
                _scrollToField(controller);
              });
            },
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _scrollToField(TextEditingController controller) {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = _scrollController.position;
      if (position.hasContentDimensions) {
        _scrollController.animateTo(
          position.pixels + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSavingsAccount', true);
      // 페이크 계좌 번호 저장
      await prefs.setString('accountNumber', '110-123-456789');

      if (!mounted) return;

      _showSuccessDialog();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계좌 개설 중 오류가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(Icons.check_circle,
                  color: Colors.green[600], size: 48),
              const SizedBox(height: 16),
              const Text(
                '계좌 개설 완료',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            '수시입출금 계좌가 성공적으로\n개설되었습니다!\n\n이제 송금 서비스를 이용하실 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSelectionScreen(),
                  ),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}