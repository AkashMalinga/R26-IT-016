import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ── User State ──
  String _lang = 'si';
  String? _userId;
  String _userName = '';
  String _userEmail = '';
  bool _isLoggedIn = false;

  // ── Progress State ──
  int _xp = 0;
  int _coins = 0;
  int _level = 1;
  int _streak = 0;
  int _totalAnswered = 0;
  int _totalCorrect = 0;
  List<int> _quizHistory = [];
  List<int> _provincesVisited = [];
  List<int> _kingsViewed = [];
  int _selectedAvatar = 0;
  bool _dailyDone = false;

  Map<String, int> _topicCorrect = {'kings': 0, 'provinces': 0, 'monuments': 0};
  Map<String, int> _topicWrong  = {'kings': 0, 'provinces': 0, 'monuments': 0};

  // ── Getters ──
  String get lang => _lang;
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get xp => _xp;
  int get coins => _coins;
  int get level => _level;
  int get streak => _streak;
  int get totalAnswered => _totalAnswered;
  int get totalCorrect => _totalCorrect;
  List<int> get quizHistory => _quizHistory;
  List<int> get provincesVisited => _provincesVisited;
  List<int> get kingsViewed => _kingsViewed;
  int get selectedAvatar => _selectedAvatar;
  bool get dailyDone => _dailyDone;
  Map<String, int> get topicCorrect => _topicCorrect;
  Map<String, int> get topicWrong => _topicWrong;

  int get accuracy => _totalAnswered > 0 ? (_totalCorrect * 100 ~/ _totalAnswered) : 0;

  Map<String, dynamic> get levelInfo => AppConstants.getLevelInfo(_xp);

  List<String> get weakTopics {
    final weak = <String>[];
    if ((_topicWrong['kings'] ?? 0) > (_topicCorrect['kings'] ?? 0)) weak.add('kings');
    if ((_topicWrong['provinces'] ?? 0) > (_topicCorrect['provinces'] ?? 0)) weak.add('provinces');
    if ((_topicWrong['monuments'] ?? 0) > (_topicCorrect['monuments'] ?? 0)) weak.add('monuments');
    return weak;
  }

  // ── Init ──
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('lang') ?? 'si';
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _xp = prefs.getInt('xp') ?? 0;
    _coins = prefs.getInt('coins') ?? 0;
    _level = prefs.getInt('level') ?? 1;
    _selectedAvatar = prefs.getInt('selectedAvatar') ?? 0;
    _provincesVisited = (prefs.getStringList('provincesVisited') ?? []).map(int.parse).toList();
    _kingsViewed = (prefs.getStringList('kingsViewed') ?? []).map(int.parse).toList();
    _totalAnswered = prefs.getInt('totalAnswered') ?? 0;
    _totalCorrect = prefs.getInt('totalCorrect') ?? 0;
    notifyListeners();

    // Sync from server if logged in
    if (_isLoggedIn) {
      try {
        final progress = await _api.getProgress();
        _syncProgress(progress);
      } catch (_) {}
    }
  }

  void _syncProgress(Map<String, dynamic> p) {
    _xp = p['xp'] ?? _xp;
    _coins = p['coins'] ?? _coins;
    _level = p['level'] ?? _level;
    _streak = p['streak'] ?? _streak;
    _totalAnswered = p['totalAnswered'] ?? _totalAnswered;
    _totalCorrect = p['totalCorrect'] ?? _totalCorrect;
    _selectedAvatar = p['selectedAvatar'] ?? _selectedAvatar;
    _provincesVisited = List<int>.from(p['provincesVisited'] ?? _provincesVisited);
    _kingsViewed = List<int>.from(p['kingsViewed'] ?? _kingsViewed);
    _topicCorrect = Map<String, int>.from(p['topicCorrect'] ?? _topicCorrect);
    _topicWrong = Map<String, int>.from(p['topicWrong'] ?? _topicWrong);
    notifyListeners();
    _saveLocal();
  }

  // ── Language ──
  void setLanguage(String lang) async {
    _lang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    notifyListeners();
  }

  // ── Auth ──
  Future<void> register(String name, String email, String password) async {
    final data = await _api.register(name, email, password, _lang);
    _userId = data['user']['id'];
    _userName = data['user']['name'];
    _userEmail = data['user']['email'];
    _isLoggedIn = true;
    await _saveAuthLocal();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await _api.login(email, password);
    _userId = data['user']['id'];
    _userName = data['user']['name'];
    _userEmail = data['user']['email'];
    _lang = data['user']['language'] ?? 'si';
    _isLoggedIn = true;
    await _saveAuthLocal();
    // Load progress from server
    try {
      final progress = await _api.getProgress();
      _syncProgress(progress);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }

  // ── XP / Coins ──
  Future<void> addXP(int amount, {int coins = 0}) async {
    _xp += amount;
    _coins += coins;
    final newLevel = AppConstants.getLevelInfo(_xp)['level'] as int;
    _level = newLevel;
    notifyListeners();
    await _saveLocal();
    if (_isLoggedIn) {
      try { await _api.addXP(amount, coins); } catch (_) {}
    }
  }

  // ── Province ──
  Future<void> visitProvince(int id) async {
    if (!_provincesVisited.contains(id)) {
      _provincesVisited.add(id);
      notifyListeners();
      await _saveLocal();
      if (_isLoggedIn) {
        try { await _api.markProvinceVisited(id); } catch (_) {}
      }
    }
  }

  // ── King ──
  Future<void> viewKing(int id) async {
    if (!_kingsViewed.contains(id)) {
      _kingsViewed.add(id);
      notifyListeners();
      await _saveLocal();
      if (_isLoggedIn) {
        try { await _api.markKingViewed(id); } catch (_) {}
      }
    }
  }

  // ── Quiz Result ──
  Future<void> saveQuizResult(int score, int total, String topic, int percentage) async {
    _totalAnswered += total;
    _totalCorrect += score;
    _topicCorrect[topic] = (_topicCorrect[topic] ?? 0) + score;
    _topicWrong[topic] = (_topicWrong[topic] ?? 0) + (total - score);
    _quizHistory.add(percentage);
    if (_quizHistory.length > 7) _quizHistory.removeAt(0);
    notifyListeners();
    await _saveLocal();
    if (_isLoggedIn) {
      try { await _api.saveQuizResult(score, total, topic, percentage); } catch (_) {}
    }
  }

  // ── Avatar ──
  Future<void> setAvatar(int idx) async {
    _selectedAvatar = idx;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedAvatar', idx);
  }

  // ── Persist ──
  Future<void> _saveAuthLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', _isLoggedIn);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    await prefs.setString('lang', _lang);
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setInt('coins', _coins);
    await prefs.setInt('level', _level);
    await prefs.setInt('totalAnswered', _totalAnswered);
    await prefs.setInt('totalCorrect', _totalCorrect);
    await prefs.setInt('selectedAvatar', _selectedAvatar);
    await prefs.setStringList('provincesVisited', _provincesVisited.map((e) => e.toString()).toList());
    await prefs.setStringList('kingsViewed', _kingsViewed.map((e) => e.toString()).toList());
  }
}
