import 'package:flutter/material.dart';
// 시작 화면은 동료분이 만든 main_screen.dart를 그대로 유지합니다.
import 'screens_heyyoung/main_screen.dart';

void main() {
  runApp(const MyApp());
}

// MyApp 클래스 이름이 다를 수 있으니, 동료분의 코드에 맞춰주세요.
// 여기서는 MyApp으로 가정합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // const와 super.key를 추가하는 것이 최신 Flutter 스타일입니다.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '헤이영 캠퍼스',
      // 우리가 설정했던 테마(ThemeData)를 여기에 적용합니다.
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSans', // 동료분의 폰트 설정은 유지
        scaffoldBackgroundColor: Colors.grey[100], // 우리의 배경색 설정 추가
        // 우리가 설정했던 AppBar 테마 (제목 볼드체 등) 추가
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSans', // 폰트를 일관성 있게 맞춰줌
          ),
        ),
      ),
      home: MainScreen(), // 시작 화면은 동료분의 MainScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
