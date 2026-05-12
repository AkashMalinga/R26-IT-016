// timeline_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  static const _events = [
    {'year': '543 BC', 'name': 'Prince Vijaya Arrives', 'desc': 'First recorded king arrives from India, founding Sinhala civilization.', 'type': 'king'},
    {'year': '247 BC', 'name': 'Buddhism Introduced', 'desc': 'Arahat Mahinda arrives at Mihintale, King Devanampiya Tissa converts.', 'type': 'temple'},
    {'year': '245 BC', 'name': 'Sri Maha Bodhi Planted', 'desc': 'Sacred Bodhi tree cutting brought from India and planted in Anuradhapura.', 'type': 'temple'},
    {'year': '161 BC', 'name': 'Dutugamunu Rises', 'desc': 'Prince Dutugamunu rallies to unify the island against King Elara.', 'type': 'king'},
    {'year': '145 BC', 'name': 'King Elara Defeated', 'desc': 'Dutugamunu defeats Elara at the Battle of Anuradhapura, unifying Sri Lanka.', 'type': 'battle'},
    {'year': '140 BC', 'name': 'Ruwanwelisaya Built', 'desc': 'King Dutugamunu begins construction of the great Ruwanwelisaya stupa.', 'type': 'temple'},
    {'year': '276 AD', 'name': 'Mahasena Begins Reign', 'desc': 'Great irrigation king starts building 16 major tanks transforming agriculture.', 'type': 'water'},
    {'year': '477 AD', 'name': 'Kashyapa Builds Sigiriya', 'desc': 'King Kashyapa constructs the magnificent rock fortress on a 200m monolith.', 'type': 'king'},
    {'year': '1153 AD', 'name': 'Parakramabahu Unifies', 'desc': 'Golden Age king reunites three warring kingdoms under one rule.', 'type': 'king'},
    {'year': '1165 AD', 'name': 'Parakrama Samudraya', 'desc': "Vast reservoir built — Sri Lanka's greatest engineering achievement.", 'type': 'water'},
    {'year': '1505 AD', 'name': 'Portuguese Arrive', 'desc': 'Portuguese establish coastal trade posts, beginning colonial era.', 'type': 'battle'},
    {'year': '1948 AD', 'name': 'Independence', 'desc': 'Sri Lanka gains independence from British colonial rule on February 4th.', 'type': 'king'},
  ];

  Color _typeColor(String type) {
    switch (type) {
      case 'king': return AppColors.gold;
      case 'battle': return AppColors.red;
      case 'temple': return AppColors.purple;
      case 'water': return AppColors.blue;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold), onPressed: () => context.go('/home')),
        title: Text(p.lang == 'si' ? '📜 ඉතිහාස Timeline' : '📜 History Timeline',
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _events.length,
        itemBuilder: (_, i) {
          final event = _events[i];
          final color = _typeColor(event['type']!);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Text(event['year']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold), textAlign: TextAlign.right),
              ),
              const SizedBox(width: 12),
              Column(children: [
                const SizedBox(height: 10),
                Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                if (i < _events.length - 1)
                  Container(width: 2, height: 60, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withOpacity(0.4), color.withOpacity(0.05)]))),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0x0FFFFFFF))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['name']!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(event['desc']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.5)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
                        child: Text(event['type']!.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════
// KING STORY SCREEN
// ══════════════════════════════════════
class KingStoryScreen extends StatelessWidget {
  final int kingId;
  const KingStoryScreen({super.key, required this.kingId});

  static const _kings = [
    {'name': 'Prince Vijaya', 'period': '543 BC', 'icon': '🤴', 'kingdom': 'Tambapanni', 'story': "Sri Lanka's recorded history begins with Prince Vijaya, who sailed from India around 543 BC. He founded the Kingdom of Tambapanni, establishing the Sinhala civilization and creating the foundation for Sri Lanka's rich cultural heritage.", 'contributions': ['Established first recorded kingdom','Founded Tambapanni','Began Sinhala civilization'], 'monuments': [], 'xpReward': 10},
    {'name': 'King Devanampiya Tissa', 'period': '247–207 BC', 'icon': '🙏', 'kingdom': 'Anuradhapura', 'story': "King Devanampiya Tissa's reign marks the most transformative event in Sri Lankan history — the arrival of Buddhism. Arahat Mahinda arrived at Mihintale. He brought the sacred Sri Maha Bodhi tree and established the Mahavihara monastery.", 'contributions': ['Accepted Buddhism as state religion','Brought Sri Maha Bodhi tree','Built Mahavihara monastery'], 'monuments': ['Mihintale','Sri Maha Bodhi'], 'xpReward': 12},
    {'name': 'King Dutugamunu', 'period': '161–137 BC', 'icon': '⚔️', 'kingdom': 'Anuradhapura', 'story': "King Dutugamunu is one of Sri Lanka's greatest warrior-kings. He unified the island by defeating King Elara and his armies. His war elephant Kandula became legendary. He built the Ruwanwelisaya, Lovamahapaya, and Mirisawetiya.", 'contributions': ['Unified Sri Lanka','Defeated King Elara','Built Ruwanwelisaya'], 'monuments': ['Ruwanwelisaya','Mirisawetiya'], 'xpReward': 15},
    {'name': 'King Mahasena', 'period': '276–303 AD', 'icon': '💧', 'kingdom': 'Anuradhapura', 'story': 'Known as the "Great Tank Builder," King Mahasena transformed Sri Lanka by constructing 16 major reservoirs and 2 canals. His engineering achievements made Sri Lanka one of the most advanced hydraulic civilizations.', 'contributions': ['Built 16 major irrigation tanks','Advanced agriculture','Built Jetavanaramaya stupa'], 'monuments': ['Minneriya Tank','Kaudulla Tank','Jetavanaramaya'], 'xpReward': 12},
    {'name': 'King Kashyapa', 'period': '477–495 AD', 'icon': '🏰', 'kingdom': 'Sigiriya', 'story': "King Kashyapa built one of the world's most extraordinary fortresses on a 200-meter granite monolith — Sigiriya. Now a UNESCO World Heritage Site called the \"Eighth Wonder of the World.\"", 'contributions': ['Built UNESCO Sigiriya','Created water gardens','Cloud Maiden frescoes'], 'monuments': ['Sigiriya Rock Fortress','Sigiriya Water Gardens'], 'xpReward': 15},
    {'name': 'King Parakramabahu I', 'period': '1153–1186 AD', 'icon': '👑', 'kingdom': 'Polonnaruwa', 'story': "King Parakramabahu I created Sri Lanka's Golden Age. He unified three warring kingdoms and built the vast Parakrama Samudraya reservoir. His declaration about water remains a legendary quote of wisdom.", 'contributions': ['Unified three warring kingdoms','Built Parakrama Samudraya','Commissioned Gal Viharaya'], 'monuments': ['Parakrama Samudraya','Gal Viharaya','Lankathilaka'], 'xpReward': 18},
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final k = _kings[kingId.clamp(0, _kings.length - 1)];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold), onPressed: () => context.go('/kings')),
        title: Text('📖 ${k['name']}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.card, AppColors.card2]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33D4A017)),
              ),
              child: Column(
                children: [
                  Text(k['icon']! as String, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 12),
                  Text(k['name']! as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold)),
                  Text(k['period']! as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  Text(k['kingdom']! as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Story
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x0FFFFFFF))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📖 Historical Narrative', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 12)),
                  const SizedBox(height: 10),
                  Text(k['story']! as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.9)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Contributions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x0FFFFFFF))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐ Key Contributions', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 12)),
                  const SizedBox(height: 10),
                  ...List<String>.from(k['contributions']! as List).map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 8),
                    child: Row(children: [
                      const Text('▸ ', style: TextStyle(color: AppColors.gold, fontSize: 10)),
                      Expanded(child: Text(c, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5))),
                    ]),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Quiz button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/quiz/kings'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(p.lang == 'si' ? '🎯 ප්‍රශ්නාවලිය ගන්න' : '🎯 Take the Kings Quiz', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// LEADERBOARD SCREEN
// ══════════════════════════════════════
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _board = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final svc = ApiService();
      _board = await svc.getLeaderboard();
    } catch (_) {
      _board = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold), onPressed: () => context.go('/progress')),
        title: const Text('🏆 Leaderboard', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _board.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🏆', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text('No rankings yet!', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
              const Text('Login and complete quizzes to appear here.', style: TextStyle(color: AppColors.textMuted, fontSize: 13), textAlign: TextAlign.center),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _board.length,
              itemBuilder: (_, i) {
                final entry = _board[i];
                final rank = entry['rank'] ?? (i + 1);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: rank <= 3 ? const Color(0x1AD4A017) : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rank <= 3 ? const Color(0x33D4A017) : const Color(0x0FFFFFFF)),
                  ),
                  child: Row(children: [
                    Text(rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '#$rank',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(entry['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14)),
                      Text('Level ${entry['level'] ?? 1} · ${entry['accuracy'] ?? 0}% accuracy', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${entry['xp'] ?? 0} XP', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 14)),
                      Text('🪙 ${entry['coins'] ?? 0}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ]),
                  ]),
                );
              },
            ),
    );
  }
}

// Import needed (add at top of this file in real project)
import '../services/api_service.dart';
