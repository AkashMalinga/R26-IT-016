import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ── URL Configuration ─────────────────────────────────────────────────────
  static const _base = 'http://10.246.114.137:3001/api'; // ← ඔයාගේ PC IP දාන්න
//   static const _base = 'http://10.0.2.2:3001/api'; // Android Emulator ✅
  // static const _base = 'http://localhost:3001/api';      // iOS Simulator
  // static const _base = 'http://172.28.23.66:3001/api'; // Real Device

  static const _timeout = Duration(seconds: 15);

  Future<String?> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('auth_token');
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final t = await _token();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  Future<dynamic> get(String path) async {
    final r = await http.get(Uri.parse('$_base$path'), headers: await _headers()).timeout(_timeout);
    return _handle(r);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final r = await http.post(Uri.parse('$_base$path'), headers: await _headers(auth: auth), body: jsonEncode(body)).timeout(_timeout);
    return _handle(r);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final r = await http.put(Uri.parse('$_base$path'), headers: await _headers(), body: jsonEncode(body)).timeout(_timeout);
    return _handle(r);
  }

  dynamic _handle(http.Response r) {
    final d = jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return d;
    throw Exception(d['error'] ?? 'API error ${r.statusCode}');
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async =>
      (await post('/auth/register', data, auth: false)) as Map<String, dynamic>;

  Future<Map<String, dynamic>> login(String username, String password) async =>
      (await post('/auth/login', {'username': username, 'password': password}, auth: false)) as Map<String, dynamic>;

  Future<Map<String, dynamic>> getMe() async =>
      (await get('/auth/me')) as Map<String, dynamic>;

  Future<void> endSession(int durationSeconds) async =>
      await put('/auth/session/end', {'durationSeconds': durationSeconds});

  // ── Attempts ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> submitAttempt(Map<String, dynamic> data) async =>
      (await post('/attempts', data)) as Map<String, dynamic>;

  Future<List<dynamic>> getBestScores() async =>
      (await get('/attempts/best')) as List<dynamic>;

  Future<Map<String, dynamic>> getAttemptStats() async =>
      (await get('/attempts/stats')) as Map<String, dynamic>;

  Future<Map<String, dynamic>> getMyAttempts({int page = 1, String? corpus}) async {
    var path = '/attempts/mine?page=$page';
    if (corpus != null) path += '&corpus=${Uri.encodeComponent(corpus)}';
    return (await get(path)) as Map<String, dynamic>;
  }

  // ── Progress ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMyProgress() async =>
      (await get('/progress')) as Map<String, dynamic>;

  Future<Map<String, dynamic>> getChildProgress(String childId) async =>
      (await get('/progress/$childId')) as Map<String, dynamic>;

  // ── Badges ────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getBadges() async =>
      (await get('/badges')) as List<dynamic>;

  // ── Stories ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> getStories() async =>
      (await get('/stories')) as List<dynamic>;

  // ── Analytics ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboard() async =>
      (await get('/analytics/dashboard')) as Map<String, dynamic>;

  Future<List<dynamic>> getLeaderboard() async =>
      (await get('/analytics/leaderboard')) as List<dynamic>;

  // ── Admin ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAdminOverview() async =>
      (await get('/admin/overview')) as Map<String, dynamic>;

  Future<Map<String, dynamic>> getAdminAnalytics() async =>
      (await get('/admin/analytics')) as Map<String, dynamic>;
}
