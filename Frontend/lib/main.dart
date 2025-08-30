import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens_heyyoung/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 설정 (선택사항)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
      title: 'SSAFY Campus',
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
      home: SSAFYSplashScreen(), // 스플래시 화면으로 시작
      debugShowCheckedModeBanner: false,
    );
  }
}

class SSAFYSplashScreen extends StatefulWidget {
  @override
  _SSAFYSplashScreenState createState() => _SSAFYSplashScreenState();
}

class _SSAFYSplashScreenState extends State<SSAFYSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();

    // 3초 후 메인 화면으로 이동
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
          transitionDuration: Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
            colors: [
              Color(0xFF6366F1), // 파란색
              Color(0xFF7C3AED), // 보라색
              Color(0xFF9333EA), // 보라색
              Color(0xFFA855F7), // 분홍보라색
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 책 아이콘 원형 컨테이너
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 6,
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 60),

                    // SSAFY 텍스트
                    Text(
                      'SSAFY',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Campus 텍스트
                    Text(
                      'Campus',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}