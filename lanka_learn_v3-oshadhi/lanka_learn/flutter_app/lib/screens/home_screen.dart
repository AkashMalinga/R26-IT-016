import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final lvl = AppConstants.getLevelInfo(p.xp);
    final nextLvl = AppConstants.levels[((lvl['level'] as int) - 1).clamp(0, 3)];
    final xpInLevel = p.xp - (lvl['xpReq'] as int);
    final xpNeeded = ((nextLvl['xpNext'] as int) - (lvl['xpReq'] as int)).clamp(1, 9999);
    final progress = (xpInLevel / xpNeeded).clamp(0.0, 1.0);

    final List<String> tips = p.lang == 'si'
        ? ['සිගිරිය "ලෝකයේ 8 වැනි පුදුමය" ලෙස හඳුන්වනු ලැබේ! 🏰', 'ශ්‍රී ලංකාවේ ඉතිහාසය වසර 2500 කට වැඩිය. 📜']
        : p.lang == 'ta'
        ? ['சிகிரியா "உலகின் 8வது அதிசயம்"! 🏰', 'இலங்கையின் வரலாறு 2500 ஆண்டுகள். 📜']
        : ['Sigiriya is called the "Eighth Wonder of the World"! 🏰', "Sri Lanka's history spans over 2,500 years. 📜", 'The Ruwanwelisaya stupa was built by King Dutugamunu. ⚔️'];

    final tip = tips[DateTime.now().minute % tips.length];

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Text('🦁 ', style: TextStyle(fontSize: 20)), Text('Lanka Learn', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800))]),
        actions: [
          TextButton(
            onPressed: () => _showLangPicker(context, p),
            child: Text(p.lang.toUpperCase(), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
          ),
          if (p.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.textMuted, size: 20),
              onPressed: () async { await p.logout(); if (context.mounted) context.go('/login'); },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP Card
            _xpCard(context, p, lvl, progress),
            const SizedBox(height: 14),

            // Daily Challenge
            _dailyCard(context, p),
            const SizedBox(height: 14),

            // Menu grid
            _sectionLabel(p.lang == 'si' ? 'ගවේෂණ කරන්න' : p.lang == 'ta' ? 'ஆராய்வோம்' : 'Explore'),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _menuCard(context, '🗺️', p.lang == 'si' ? 'ශ්‍රී ලංකා සිතියම' : p.lang == 'ta' ? 'இலங்கை வரைபடம்' : 'Sri Lanka Map', '9 Provinces', '/map'),
                _menuCard(context, '👑', p.lang == 'si' ? 'රජවරු' : p.lang == 'ta' ? 'அரசர்கள்' : 'Kings', '6 Famous Kings', '/kings'),
                _menuCard(context, '🎯', p.lang == 'si' ? 'ප්‍රශ්නාවලිය' : p.lang == 'ta' ? 'வினாடி வினா' : 'Quiz', 'AI Powered', '/quiz-category', badge: '🤖 AI'),
                _menuCard(context, '🎮', p.lang == 'si' ? 'ක්‍රීඩා' : p.lang == 'ta' ? 'விளையாட்டு' : 'Games', 'Drag & Drop', '/games', badge: 'NEW'),
                _menuCard(context, '📜', p.lang == 'si' ? 'Timeline' : p.lang == 'ta' ? 'Timeline' : 'Timeline', p.lang == 'si' ? 'ඉතිහාසය' : 'History', '/timeline'),
                _menuCard(context, '📊', p.lang == 'si' ? 'ප්‍රගතිය' : p.lang == 'ta' ? 'முன்னேற்றம்' : 'Progress', 'Analytics', '/progress'),
              ],
            ),
            const SizedBox(height: 14),

            // Tip card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33295A9A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.lang == 'si' ? 'ඔබ දැනුවත්ද?' : p.lang == 'ta' ? 'தெரியுமா?' : 'Did You Know?',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF74B9E8), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(tip, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.6)),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _xpCard(BuildContext context, AppProvider p, Map<String, dynamic> lvl, double progress) {
    final avatars = ['🦁','🐘','🦚','🐢','🦋','🦜','👑','⚔️','🧝','🌺','🏰','💎'];
    final lvlNames = p.lang == 'si'
        ? ['ශිෂ්‍ය','ඉගෙනීමේ ශූරයා','ඉතිහාස පරීක්ෂකයා','සංස්කෘතික ශූරයා','Lanka Master']
        : p.lang == 'ta'
        ? ['மாணவர்','கற்றல் வீரர்','வரலாறு ஆய்வாளர்','கலாசார வீரர்','Lanka Master']
        : ['Student','Learning Hero','History Researcher','Cultural Champion','Lanka Master'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.card, AppColors.card2]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33D4A017)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/progress'),
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.gold, AppColors.goldDark])),
                  child: Center(child: Text(avatars[p.selectedAvatar.clamp(0, avatars.length - 1)], style: const TextStyle(fontSize: 28))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.isLoggedIn ? p.userName : 'Guest Learner',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('⭐ Level ${lvl['level']} — ${lvlNames[((lvl['level'] as int) - 1).clamp(0, 4)]}',
                      style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1FD4A017),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x40D4A017)),
                ),
                child: Row(children: [
                  const Text('🪙 ', style: TextStyle(fontSize: 13)),
                  Text('${p.coins}', style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0x14FFFFFF),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${p.xp} XP', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text((lvl['level'] as int) < 5 ? 'Next Level: ${AppConstants.levels[(lvl['level'] as int).clamp(0, 4)]['xpNext']} XP' : 'MAX LEVEL! 👑',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ]),
        ],
      ),
    );
  }

  Widget _dailyCard(BuildContext context, AppProvider p) {
    return GestureDetector(
      onTap: () => context.go('/quiz/daily'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0x1F27AE60), Color(0x0A2ECC71)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x4D27AE60)),
        ),
        child: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.lang == 'si' ? 'දිනපතා Challenge' : p.lang == 'ta' ? 'தினசரி சவால்' : 'Daily Challenge',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5DDE8C), fontSize: 13)),
                Text(p.lang == 'si' ? 'විශේෂ ප්‍රශ්නාවලිය — 2x XP!' : p.lang == 'ta' ? 'சிறப்பு வினாடி வினா — 2x XP!' : "Today's special quiz — Earn 2x XP!",
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            )),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF5DDE8C), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, String icon, String label, String sub, String route, {String? badge}) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 12), textAlign: TextAlign.center),
                const SizedBox(height: 3),
                Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), textAlign: TextAlign.center),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                  child: Text(badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.navy)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label.toUpperCase(),
    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1.5, fontWeight: FontWeight.w600),
  );

  void _showLangPicker(BuildContext context, AppProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navy2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Language', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.gold)),
            const SizedBox(height: 16),
            ...[ ('si', 'සිංහල'), ('ta', 'தமிழ்'), ('en', 'English') ].map((lang) =>
              ListTile(
                leading: Text(lang.$1 == p.lang ? '✅' : '  '),
                title: Text(lang.$2, style: const TextStyle(color: AppColors.textPrimary)),
                onTap: () { p.setLanguage(lang.$1); Navigator.pop(context); },
              )
            ),
          ],
        ),
      ),
    );
  }
}
