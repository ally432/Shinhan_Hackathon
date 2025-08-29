// lib/services/goals_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://211.188.50.244:8080';
const String kSem1GoalKeyPrefix = 'goal';
const String kSem2GoalKeyPrefix = 'goal';

class TargetScoreDto {
  final double? goalSem1;
  final double? goalSem2;
  TargetScoreDto({this.goalSem1, this.goalSem2});

  factory TargetScoreDto.fromJson(Map<String, dynamic> j) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().replaceAll(',', '.');
      return double.tryParse(s);
    }
    return TargetScoreDto(
      goalSem1: toDouble(j['goalSem1'] ?? j['goal_sem1']),
      goalSem2: toDouble(j['goalSem2'] ?? j['goal_sem2']),
    );
  }
}

class GoalsService {
  static String _k1(String userKey) => 'goal:$userKey:sem1';
  static String _k2(String userKey) => 'goal:$userKey:sem2';

  // ---- 서버 ----
  static Future<TargetScoreDto?> fetchFromServer(String userKey) async {
    final uri = Uri.parse('$baseUrl/api/target-score')
        .replace(queryParameters: {'userKey': userKey});
    final res = await http.get(uri, headers: {'Accept':'application/json'})
        .timeout(const Duration(seconds: 7));
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body);
    if (body is Map<String, dynamic>) {
      return TargetScoreDto.fromJson(body);
    }
    return null;
  }

  static Future<void> upsertToServer(
      String userKey, double? goalSem1, double? goalSem2) async {
    final uri = Uri.parse('$baseUrl/api/target-score');
    final res = await http.post(
      uri,
      headers: {'Content-Type':'application/json','Accept':'application/json'},
      body: jsonEncode({'userKey': userKey, 'goalSem1': goalSem1, 'goalSem2': goalSem2}),
    ).timeout(const Duration(seconds: 7));
    if (res.statusCode != 200) {
      throw Exception('목표 저장 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  // ---- 로컬 캐시 ----
  static Future<void> saveLocal(String userKey, String? g1, String? g2) async {
    final prefs = await SharedPreferences.getInstance();
    if (g1 != null) await prefs.setString(_k1(userKey), g1);
    if (g2 != null) await prefs.setString(_k2(userKey), g2);
  }

  static Future<TargetScoreDto?> loadLocal(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    double? parse(String? s) =>
        (s == null || s.trim().isEmpty) ? null : double.tryParse(s.trim());
    final g1 = parse(prefs.getString(_k1(userKey)));
    final g2 = parse(prefs.getString(_k2(userKey)));
    if (g1 == null && g2 == null) return null;
    return TargetScoreDto(goalSem1: g1, goalSem2: g2);
  }
}
