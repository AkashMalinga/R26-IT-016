import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade, _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

    _scale = Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _slide = Tween(begin: 40.0, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    final auth = context.read<AuthService>();
    Navigator.pushReplacementNamed(context, auth.isLoggedIn ? '/home' : '/login');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3949AB), Color(0xFF5C6BC0), Color(0xFF7E57C2)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        // Background circles
        Positioned(top: -60, right: -60,
          child: Container(width: 220, height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06)))),
        Positioned(bottom: -80, left: -80,
          child: Container(width: 300, height: 300,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05)))),

        Center(child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: const Center(child: Text('✏️', style: TextStyle(fontSize: 56))),
                  ),
                ),
                const SizedBox(height: 28),
                Transform.translate(
                  offset: Offset(0, _slide.value),
                  child: Column(children: [
                    const Text('ScriptMind', style: TextStyle(
                      color: Colors.white, fontSize: 40,
                      fontWeight: FontWeight.w900, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 8),
                    Text('Learn · Write · Grow', style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 16,
                      fontWeight: FontWeight.w500, letterSpacing: 2,
                    )),
                    const SizedBox(height: 6),
                    Text('සිංහල  •  தமிழ்  •  English', style: TextStyle(
                      color: Colors.white.withOpacity(0.65), fontSize: 14,
                    )),
                  ]),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.5), strokeWidth: 2),
                ),
              ],
            ),
          ),
        )),
      ]),
    ),
  );
}
