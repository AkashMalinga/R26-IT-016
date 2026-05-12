import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Header ────────────────────────────────────────────────────────
            Row(children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                child: Center(child: Text(auth.userAvatar,
                    style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, ${auth.userName}! 👋',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                        color: Color(0xFF1A237E))),
                const Text('Ready to learn today?',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ])),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.grey),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ]),
            const SizedBox(height: 20),

            // ── Hero Banner ───────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3949AB), Color(0xFF5C6BC0), Color(0xFF7986CB)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('✏️ Practice Handwriting', style: TextStyle(
                    color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('3 Languages', style: TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _LangPill('🇱🇰 සිංහල', 'Sinhala', context),
                  _LangPill('🌺 தமிழ்', 'Tamil', context),
                  _LangPill('🔤 English', 'Latin Uppercase', context),
                ]),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Section: Learn ────────────────────────────────────────────────
            _Section('✨ What do you want to do?'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
              children: [
                _MenuCard(emoji: '✏️', title: 'Write Letters',
                    subtitle: 'Practice handwriting',
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, '/handwriting')),
                _MenuCard(emoji: '🔤', title: 'Alphabet',
                    subtitle: 'Browse all letters',
                    color: AppColors.english,
                    onTap: () => Navigator.pushNamed(context, '/alphabet')),
                _MenuCard(emoji: '📖', title: 'Stories',
                    subtitle: 'Read & listen',
                    color: AppColors.secondary,
                    onTap: () => Navigator.pushNamed(context, '/stories')),
                _MenuCard(emoji: '🎮', title: 'Fun Games',
                    subtitle: 'Play & learn',
                    color: AppColors.success,
                    onTap: () => Navigator.pushNamed(context, '/fun')),
                _MenuCard(emoji: '📊', title: 'My Progress',
                    subtitle: 'See your growth',
                    color: AppColors.warning,
                    onTap: () => Navigator.pushNamed(context, '/progress')),
                _MenuCard(emoji: '🏆', title: 'My Badges',
                    subtitle: 'Achievements',
                    color: AppColors.accent,
                    onTap: () => Navigator.pushNamed(context, '/badges')),
              ],
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)));
}

class _LangPill extends StatelessWidget {
  final String label, corpus;
  final BuildContext ctx;
  const _LangPill(this.label, this.corpus, this.ctx);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pushNamed(ctx, '/handwriting', arguments: {'corpus': corpus}),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
    ),
  );
}

class _MenuCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _MenuCard({required this.emoji, required this.title,
      required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: color.withOpacity(0.18),
            blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
        ),
        const SizedBox(height: 10),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}
