import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _lionCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _lionAnim;
  late Animation<double> _textAnim;
  String _selectedLang = 'si';

  final Map<String, Map<String, String>> _langText = {
    'si': {'cta': 'ඉගෙනීම ආරම්භ කරන්න →', 'note': 'ඔබේ භාෂාව තෝරන්න'},
    'ta': {'cta': 'கற்கலாம் →', 'note': 'உங்கள் மொழியை தேர்வு செய்யுங்கள்'},
    'en': {'cta': 'Start Learning →', 'note': 'Choose your preferred language'},
  };

  @override
  void initState() {
    super.initState();
    _lionCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _lionAnim = Tween<double>(begin: 0, end: -12).animate(CurvedAnimation(parent: _lionCtrl, curve: Curves.easeInOut));
    _textAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.elasticOut));
    _textCtrl.forward();
  }

  @override
  void dispose() {
    _lionCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _start() {
    final provider = context.read<AppProvider>();
    provider.setLanguage(_selectedLang);
    if (provider.isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1929), Color(0xFF1A3A5C), Color(0xFF0D2A1A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ScaleTransition(
              scale: _textAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lion animation
                    AnimatedBuilder(
                      animation: _lionAnim,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _lionAnim.value),
                        child: const Text('🦁', style: TextStyle(fontSize: 80)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Brand name
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [Color(0xFFF5C842), Color(0xFFD4A017), Color(0xFFF5C842)],
                      ).createShader(b),
                      child: const Text(
                        'LANKA LEARN',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 3, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Intelligent Multilingual Learning System v3',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7A9AB8), letterSpacing: 1),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ශ්‍රී ලංකාවේ ඉතිහාසය ඉගෙනගනිමු\nஇலங்கை வரலாற்றை கற்போம்\nExplore Sri Lanka\'s Cultural Heritage',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4A7A9A), height: 1.8),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Language selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _langBtn('si', 'සිංහල'),
                        const SizedBox(width: 8),
                        _langBtn('ta', 'தமிழ்'),
                        const SizedBox(width: 8),
                        _langBtn('en', 'English'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _langText[_selectedLang]!['note']!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4A7A9A)),
                    ),
                    const SizedBox(height: 24),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _start,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        child: Text(_langText[_selectedLang]!['cta']!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'v3.0 · AI King Chat · Voice · Adaptive · Games',
                      style: TextStyle(fontSize: 10, color: Color(0xFF4A7A9A)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _langBtn(String code, String label) {
    final selected = _selectedLang == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedLang = code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.navy : AppColors.gold,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
