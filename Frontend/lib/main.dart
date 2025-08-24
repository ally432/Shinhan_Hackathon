import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ★ 추가
import 'screens_heyyoung/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ★ 비동기 초기화 준비

  // 앱 시작할 때마다 로그인 관련 키 제거 → 항상 로그아웃 상태로 시작
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLoggedIn');
  await prefs.remove('userId');
  await prefs.remove('userKey');
  await prefs.remove('autoLogin');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '헤이영 캠퍼스',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSans',
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSans',
          ),
        ),
      ),
      home: MainScreen(), // 동료분의 메인 화면
      debugShowCheckedModeBanner: false,
    );
  }
}
