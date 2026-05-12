import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;
  bool _loading = true;

  Map<String, dynamic>? get user       => _user;
  String?               get token      => _token;
  bool                  get isLoggedIn => _token != null;
  bool                  get isAdmin    => _user?['role'] == 'admin';
  bool                  get loading    => _loading;

  String get userName   => _user?['name']     ?? 'Learner';
  String get userAvatar => _user?['avatar']   ?? '🧒';
  String get userId     => _user?['_id']      ?? '';
  int    get totalXP    => (_user?['totalXP'] ?? 0) as int;
  int    get level      => (_user?['level']   ?? 1) as int;
  int    get streak     => (_user?['streak']  ?? 0) as int;

  AuthService() { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('auth_token');
    final s = p.getString('auth_user');
    if (s != null) _user = jsonDecode(s);
    _loading = false;
    notifyListeners();
  }

  Future<void> save(String token, Map<String, dynamic> user) async {
    _token = token; _user = user;
    final p = await SharedPreferences.getInstance();
    await p.setString('auth_token', token);
    await p.setString('auth_user', jsonEncode(user));
    notifyListeners();
  }

  void updateXP(int newXP, int newLevel) {
    if (_user == null) return;
    _user!['totalXP'] = newXP;
    _user!['level']   = newLevel;
    SharedPreferences.getInstance().then((p) => p.setString('auth_user', jsonEncode(_user)));
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null; _user = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('auth_token');
    await p.remove('auth_user');
    notifyListeners();
  }
}
