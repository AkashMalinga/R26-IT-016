import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _api = ApiService();
  bool _loading = false;

  final _loginUser = TextEditingController();
  final _loginPass = TextEditingController();
  final _regName   = TextEditingController();
  final _regUser   = TextEditingController();
  final _regPass   = TextEditingController();
  final _regAge    = TextEditingController();
  String _selectedAvatar = '🧒';
  final _avatars = ['🧒','👦','👧','🧑','🦁','🐯','🐼','🦊','🐸','🦋'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_loginUser.text.isEmpty || _loginPass.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await _api.login(_loginUser.text.trim(), _loginPass.text.trim());
      await context.read<AuthService>().save(res['token'] as String, res['user'] as Map<String, dynamic>);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _register() async {
    if (_regName.text.isEmpty || _regUser.text.isEmpty || _regPass.text.isEmpty) {
      _showError('Name, username and password are required'); return;
    }
    setState(() => _loading = true);
    try {
      final res = await _api.register({
        'name': _regName.text.trim(), 'username': _regUser.text.trim(),
        'password': _regPass.text.trim(), 'avatar': _selectedAvatar,
        if (_regAge.text.isNotEmpty) 'age': int.tryParse(_regAge.text),
      });
      await context.read<AuthService>().save(res['token'] as String, res['user'] as Map<String, dynamic>);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 24),
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: Text('✍️', style: TextStyle(fontSize: 40)))),
          const SizedBox(height: 12),
          Text('ScriptMind', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.primary)),
          Text('Multilingual Handwriting Learning', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
            child: TabBar(controller: _tab, labelColor: AppColors.primary, unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              tabs: const [Tab(text: 'Login'), Tab(text: 'Register')])),
          const SizedBox(height: 20),
          Expanded(child: TabBarView(controller: _tab, children: [_buildLogin(), _buildRegister()])),
        ]),
      )),
    );
  }

  Widget _buildLogin() => SingleChildScrollView(child: Column(children: [
    _field(_loginUser, 'Username', Icons.person),
    const SizedBox(height: 12),
    _field(_loginPass, 'Password', Icons.lock, obscure: true),
    const SizedBox(height: 20),
    _button('Login 🚀', _login),
  ]));

  Widget _buildRegister() => SingleChildScrollView(child: Column(children: [
    _field(_regName, 'Full Name', Icons.badge),
    const SizedBox(height: 12),
    _field(_regUser, 'Username', Icons.person),
    const SizedBox(height: 12),
    _field(_regPass, 'Password', Icons.lock, obscure: true),
    const SizedBox(height: 12),
    _field(_regAge, 'Age (optional)', Icons.cake, keyboardType: TextInputType.number),
    const SizedBox(height: 16),
    Align(alignment: Alignment.centerLeft,
      child: Text('Choose Avatar', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8, children: _avatars.map((a) => GestureDetector(
      onTap: () => setState(() => _selectedAvatar = a),
      child: Container(width: 44, height: 44,
        decoration: BoxDecoration(
          color: _selectedAvatar == a ? AppColors.primary.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _selectedAvatar == a ? AppColors.primary : Colors.grey.shade200, width: 2)),
        child: Center(child: Text(a, style: const TextStyle(fontSize: 22)))),
    )).toList()),
    const SizedBox(height: 20),
    _button('Create Account ✨', _register),
  ]));

  Widget _field(TextEditingController c, String hint, IconData icon, {bool obscure = false, TextInputType keyboardType = TextInputType.text}) =>
    TextField(controller: c, obscureText: obscure, keyboardType: keyboardType,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)));

  Widget _button(String label, VoidCallback onTap) => SizedBox(width: double.infinity,
    child: ElevatedButton(onPressed: _loading ? null : onTap,
      child: _loading ? const SizedBox(width: 20, height: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(label)));
}
