import 'package:flutter/material.dart';
import 'package:Frontend/screens_shinhanbank/registration_complete_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Step8TermsAgreeScreen extends StatefulWidget {
  const Step8TermsAgreeScreen({super.key});

  @override
  State<Step8TermsAgreeScreen> createState() => _Step8TermsAgreeScreenState();
}

class _Step8TermsAgreeScreenState extends State<Step8TermsAgreeScreen> {
  static const String baseUrl = 'http://211.188.50.244:8080';
  bool _submitting = false;

  bool _allAgreed = false;
  final Map<String, bool> _agreements = {
    '예금거래기본약관': false,
    '거치식예금약관': false,
    '쏠편한 정기예금 특약': false,
    '비과세종합저축 특약': false,
    '불법/탈법 차명거래 금지 설명 확인서': false,
  };
  final Map<String, bool> _isExpanded = {};
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _agreements.keys.forEach((key) {
      _isExpanded[key] = false;
    });
    _validateInput();
  }

  void _validateInput() {
    final isAllChecked = _agreements.values.every((item) => item == true);
    if (isAllChecked != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isAllChecked;
      });
    }
    if (isAllChecked != _allAgreed) {
      setState(() {
        _allAgreed = isAllChecked;
      });
    }
  }

  void _toggleAllAgreed(bool? value) {
    setState(() {
      _allAgreed = value ?? false;
      _agreements.updateAll((key, _) => _allAgreed);
      _validateInput();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '약관 동의',
      nextButtonText: _submitting ? '요청 중...' : '완료',
      onNext: _submitAndNext,
      isNextEnabled: _isButtonEnabled && !_submitting,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('예금 가입을 위해 약관에 동의해주세요.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildOverallAgreement(),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _agreements.keys.length,
              itemBuilder: (context, index) {
                String title = _agreements.keys.elementAt(index);
                return _buildAgreementTile(title);
              },
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200], indent: 16, endIndent: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAndNext() async {
    setState(() => _submitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      final selectedAccountNo = prefs.getString('verifiedAccountNo') ?? '';
      final depositInitAmount = prefs.getInt('depositInitAmount') ?? 0;

      if (userKey.isEmpty || selectedAccountNo.isEmpty || depositInitAmount <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('필수 정보가 없습니다. 이전 단계부터 다시 진행해주세요.')),
        );
        return;
      }

      final res = await http.post(
        Uri.parse('$baseUrl/deposit/openDeposit'),
        headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'userKey': userKey,
          'withdrawalAccountNo': selectedAccountNo,
          'depositBalance': depositInitAmount,
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final newAccountNo = data['REC']?['accountNo']?.toString();
        if (newAccountNo != null) {
          await prefs.setString('newlyOpenedAccountNo', newAccountNo);
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RegistrationCompleteScreen()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('개설 요청 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildOverallAgreement() {
    return InkWell(
      onTap: () => _toggleAllAgreed(!_allAgreed),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _allAgreed ? Colors.blue[600]! : Colors.grey[300]!, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: _allAgreed ? Colors.blue[600] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _allAgreed ? Colors.blue[600]! : Colors.grey[400]!, width: 1.5),
              ),
              child: _allAgreed ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('전체 동의', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementTile(String title) {
    bool isChecked = _agreements[title] ?? false;
    bool isExpanded = _isExpanded[title] ?? false;

    return Column(
      children: [
        // 체크박스와 제목 부분
        InkWell(
          onTap: () {
            setState(() => _agreements[title] = !isChecked);
            _validateInput();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isChecked ? Colors.blue[600] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isChecked ? Colors.blue[600]! : Colors.grey[400]!, width: 1.5),
                  ),
                  child: isChecked ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('[필수] $title', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                InkWell(
                  onTap: () {
                    setState(() => _isExpanded[title] = !isExpanded);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 상세 내용
        if (isExpanded)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            width: double.infinity,
            color: Colors.white,
            child: Text(
              '이것은 "$title"에 대한 상세 약관 내용입니다. 사용자는 이 약관에 동의함으로써 발생하는 모든 법적 효력을 인지하였으며...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
            ),
          ),
      ],
    );
  }
}