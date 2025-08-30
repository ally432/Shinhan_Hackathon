// import 'package:flutter/material.dart';
// import 'package:Frontend/screens_shinhanbank/step7_auth_confirm_screen.dart';
// import 'package:Frontend/widgets/step_layout.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class Step6AccountVerifyScreen extends StatefulWidget {
//   const Step6AccountVerifyScreen({super.key});
//
//   @override
//   State<Step6AccountVerifyScreen> createState() => _Step6AccountVerifyScreenState();
// }
//
// class _Step6AccountVerifyScreenState extends State<Step6AccountVerifyScreen> {
//   static const String baseUrl = 'http://211.188.50.244:8080';
//   static const int kAccountNoLen = 16;
//   static const String kSelectedAccountNoKey = 'selectedAccountNo';
//   final _accountController = TextEditingController();
//   bool _isAccountVerified = false;
//   bool _isLoading = false;
//   bool _isVerifyButtonEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _accountController.addListener(_validateAccountInput);
//   }
//
//   void _validateAccountInput() {
//     final txt = _accountController.text.trim();
//     final ok = txt.length == kAccountNoLen && int.tryParse(txt) != null;
//     if (ok != _isVerifyButtonEnabled) {
//       setState(() => _isVerifyButtonEnabled = ok);
//     }
//   }
//
//
//   // '확인' 버튼 눌렀을 때
//   Future<void> _verifyAccount() async {
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userKey = prefs.getString('userKey') ?? '';
//       final accountNo = _accountController.text.trim();
//
//       if (userKey.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
//         );
//         return;
//       }
//
//       final res = await http.post(
//         Uri.parse('$baseUrl/deposit/findOneOpenDeposit'),
//         headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
//         body: jsonEncode({'userKey': userKey, 'accountNo': accountNo}),
//       ).timeout(const Duration(seconds: 8));
//
//       if (!mounted) return;
//
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         final header = (data['Header'] as Map?) ?? {};
//         final code = header['responseCode']?.toString();
//
//         final rec = data['REC'];
//         final hasRec = (rec is Map && rec.isNotEmpty) || (rec is List && rec.isNotEmpty);
//
//         if (code == 'H0000' && hasRec) {
//           setState(() => _isAccountVerified = true);
//           final prefs = await SharedPreferences.getInstance();
//           final accountNo = _accountController.text.trim();
//           await prefs.setString('verifiedAccountNo', accountNo);
//           await prefs.setString('selectedAccountNo', accountNo); // ← Step8에서 쓰는 키와 통일
//         }
//         else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('❌ 계좌 확인에 실패했습니다.')),
//           );
//         }
//
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('검증 실패: ${res.statusCode}')),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('네트워크 오류: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//
//   void _showVideoCallDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('영상 통화 인증'),
//         content: const Text('상담사 연결을 통해 비대면 인증을 시작합니다.\n(실제 영상 통화는 연결되지 않습니다.)'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('연결')),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _accountController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StepLayout(
//       title: '계좌 확인',
//       nextButtonText: '다음',
//       onNext: _isAccountVerified
//           ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Step7AuthConfirmScreen()))
//           : null,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('본인 명의의 계좌를 인증해주세요.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 32),
//           const Text('계좌번호', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _accountController,
//                   enabled: !_isAccountVerified,
//                   keyboardType: TextInputType.number,
//                   maxLength: kAccountNoLen,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     hintText: "'-' 없이 숫자 $kAccountNoLen자리 입력",
//                     filled: true,
//                     fillColor: Colors.white,
//                     counterText: '',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   // '확인' 버튼 활성화 로직 수정
//                   onPressed: _isLoading || _isAccountVerified || !_isVerifyButtonEnabled ? null : _verifyAccount,
//                   child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('확인'),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           const Center(child: Text('또는', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
//           const SizedBox(height: 16),
//           Center(
//             child: OutlinedButton(
//               onPressed: _showVideoCallDialog,
//               style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
//               child: const Text('계좌가 없으신가요? (영상 통화 인증)'),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frontend/screens_shinhanbank/step8_terms_agree_screen.dart';
import 'package:Frontend/widgets/step_layout.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Step6AccountVerifyScreen extends StatefulWidget {
  const Step6AccountVerifyScreen({super.key});

  @override
  State<Step6AccountVerifyScreen> createState() => _Step6AccountVerifyScreenState();
}

class _Step6AccountVerifyScreenState extends State<Step6AccountVerifyScreen> {
  static const String baseUrl = 'http://211.188.50.244:8080';
  final _accountController = TextEditingController();
  bool _isAccountVerified = false;
  bool _isLoading = false;
  bool _isVerifyButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_validateAccountInput);
  }

  void _validateAccountInput() {
    final txt = _accountController.text.trim();
    final ok = txt.length >= 10 && txt.length <= 16 && int.tryParse(txt.replaceAll('-', '')) != null;
    if (ok != _isVerifyButtonEnabled) {
      setState(() => _isVerifyButtonEnabled = ok);
    }
  }

  Future<void> _verifyAccount() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('userKey') ?? '';
      final accountNo = _accountController.text.trim().replaceAll('-', '');

      if (userKey.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
        );
        return;
      }

      final res = await http.post(
        Uri.parse('$baseUrl/deposit/findOneOpenDeposit'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'userKey': userKey, 'accountNo': accountNo}),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rec = data['REC'];
        final hasRec = (rec is Map && rec.isNotEmpty) || (rec is List && rec.isNotEmpty);

        if (hasRec) {
          setState(() => _isAccountVerified = true); // 👈 성공 시 상태 변경
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('verifiedAccountNo', accountNo);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ 일치하는 계좌 정보가 없습니다.')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검증 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToNextStep() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Step8TermsAgreeScreen()));
  }

  void _showVideoCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('영상 통화 인증'),
        content: const Text('상담사 연결을 통해 비대면 인증을 시작합니다.\n(실제 영상 통화는 연결되지 않습니다.)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('연결')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: '계좌 확인',
      onNext: _navigateToNextStep,
      isNextEnabled: _isAccountVerified,

      child: _isAccountVerified ? _buildSuccessView() : _buildInputForm(),
    );
  }

  /// 인증 성공 시 보여줄 위젯
  Widget _buildSuccessView() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.blue[600],
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            '본인 인증이\n안전하게 완료되었습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4),
          ),
          // const SizedBox(height: 12),
          // Text(
          //   '이제 다음 단계를 진행해주세요.',
          //   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          // ),
        ],
      ),
    );
  }

  /// 계좌번호 입력을 위한 폼 위젯
  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('본인 명의의 수시 입출금 계좌를 \n인증해주세요.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('(신한은행 또는 다른 은행의 입출금계좌)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        const SizedBox(height: 25),

        const Text('계좌번호', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "'-' 없이 숫자만 입력",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading || !_isVerifyButtonEnabled ? null : _verifyAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('확인'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('또는', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 24),

        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.video_call_outlined),
            onPressed: _showVideoCallDialog,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: const Text('계좌가 없으신가요? (영상 통화 인증)'),
          ),
        )
      ],
    );
  }
}