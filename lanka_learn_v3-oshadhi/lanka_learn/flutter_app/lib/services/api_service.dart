import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Auth ──
  Future<Map<String, dynamic>> register(String name, String email, String password, String language) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'language': language}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) {
      await _storage.write(key: 'auth_token', value: data['token']);
      return data;
    }
    throw Exception(data['error'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await _storage.write(key: 'auth_token', value: data['token']);
      return data;
    }
    throw Exception(data['error'] ?? 'Login failed');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // ── Provinces ──
  Future<List<dynamic>> getProvinces(String lang) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/provinces?lang=$lang'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['provinces'];
    throw Exception('Failed to load provinces');
  }

  // ── Kings ──
  Future<List<dynamic>> getKings(String lang) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/kings?lang=$lang'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['kings'];
    throw Exception('Failed to load kings');
  }

  // ── Quiz ──
  Future<List<dynamic>> getQuiz({String category = 'all', String lang = 'en', int count = 5}) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/quiz?category=$category&lang=$lang&count=$count'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['questions'];
    throw Exception('Failed to load quiz');
  }

  // ── AI Quiz ──
  Future<List<dynamic>> getAIQuiz({required int level, required int accuracy, required String language, List<String> weakTopics = const []}) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/ai/quiz'),
      headers: await _headers(auth: true),
      body: jsonEncode({'level': level, 'accuracy': accuracy, 'language': language, 'weakTopics': weakTopics}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['questions'];
    // Fallback to local quiz on AI failure
    return await getQuiz(lang: language, count: 5);
  }

  // ── AI King Chat ──
  Future<String> sendKingChat({required int kingId, required String message, required String language, List<Map<String, String>> history = const []}) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/ai/king-chat'),
      headers: await _headers(auth: true),
      body: jsonEncode({'kingId': kingId, 'message': message, 'language': language, 'history': history}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['reply'];
    throw Exception('Chat failed');
  }

  // ── Progress ──
  Future<Map<String, dynamic>> getProgress() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/progress'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['progress'];
    throw Exception('Failed to load progress');
  }

  Future<void> addXP(int xp, int coins) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/progress/xp'),
      headers: await _headers(auth: true),
      body: jsonEncode({'xp': xp, 'coins': coins}),
    );
  }

  Future<void> saveQuizResult(int score, int total, String topic, int percentage) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/progress/quiz'),
      headers: await _headers(auth: true),
      body: jsonEncode({'score': score, 'total': total, 'topic': topic, 'percentage': percentage}),
    );
  }

  Future<void> markProvinceVisited(int provinceId) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/progress/province'),
      headers: await _headers(auth: true),
      body: jsonEncode({'provinceId': provinceId}),
    );
  }

  Future<void> markKingViewed(int kingId) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/progress/king'),
      headers: await _headers(auth: true),
      body: jsonEncode({'kingId': kingId}),
    );
  }

  // ── Leaderboard ──
  Future<List<dynamic>> getLeaderboard() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/analytics/leaderboard'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['leaderboard'];
    throw Exception('Failed to load leaderboard');
  }
}
