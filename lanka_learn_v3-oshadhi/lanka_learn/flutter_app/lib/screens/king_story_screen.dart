import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class KingStoryScreen extends StatelessWidget {
  final int kingId;
  const KingStoryScreen({super.key, required this.kingId});

  static const _kings = [
    {
      'name': 'Prince Vijaya', 'period': '543 BC', 'icon': '🤴',
      'kingdom': 'Kingdom of Tambapanni',
      'story': "Sri Lanka's recorded history begins with Prince Vijaya, who sailed from India around 543 BC. According to the Mahavamsa, he was of the Sinhavamsa lineage. He married Kuveni and founded the Kingdom of Tambapanni, establishing the Sinhala civilization and creating the foundation for Sri Lanka's rich cultural heritage.",
      'contributions': ['Established first recorded kingdom', 'Founded Tambapanni', 'Began Sinhala civilization', 'Organized early administration'],
      'monuments': [],
      'xpReward': 10,
    },
    {
      'name': 'King Devanampiya Tissa', 'period': '247–207 BC', 'icon': '🙏',
      'kingdom': 'Anuradhapura Kingdom',
      'story': "King Devanampiya Tissa's reign marks the most transformative event in Sri Lankan history — the arrival of Buddhism. Arahat Mahinda Thero arrived at Mihintale and converted the king. He brought the sacred Sri Maha Bodhi tree and established the Mahavihara monastery, forever shaping Sri Lanka's identity.",
      'contributions': ['Accepted Buddhism as state religion', 'Brought Sri Maha Bodhi tree', 'Built Mahavihara monastery', 'Spread Buddhist culture'],
      'monuments': ['Mihintale', 'Sri Maha Bodhi', 'Mahavihara'],
      'xpReward': 12,
    },
    {
      'name': 'King Dutugamunu', 'period': '161–137 BC', 'icon': '⚔️',
      'kingdom': 'Anuradhapura Kingdom',
      'story': "King Dutugamunu is one of Sri Lanka's greatest warrior-kings. He unified the island by defeating King Elara and his 32 armies. His war elephant Kandula became legendary. He built the Ruwanwelisaya, Lovamahapaya, and Mirisawetiya, cementing his place as both unifier and devout Buddhist.",
      'contributions': ['Unified Sri Lanka', 'Defeated King Elara', 'Built Ruwanwelisaya', 'Strengthened national identity'],
      'monuments': ['Ruwanwelisaya', 'Mirisawetiya', 'Lovamahapaya'],
      'xpReward': 15,
    },
    {
      'name': 'King Mahasena', 'period': '276–303 AD', 'icon': '💧',
      'kingdom': 'Anuradhapura Kingdom',
      'story': 'Known as the "Great Tank Builder," King Mahasena transformed Sri Lanka by constructing 16 major reservoirs and 2 canals. His engineering achievements — Minneriya Tank and Jetavanaramaya — made Sri Lanka one of the most advanced hydraulic civilizations of the ancient world.',
      'contributions': ['Built 16 major irrigation tanks', 'Constructed 2 major canals', 'Advanced agriculture', 'Built Jetavanaramaya stupa'],
      'monuments': ['Minneriya Tank', 'Kaudulla Tank', 'Jetavanaramaya'],
      'xpReward': 12,
    },
    {
      'name': 'King Kashyapa', 'period': '477–495 AD', 'icon': '🏰',
      'kingdom': 'Kingdom of Sigiriya',
      'story': "King Kashyapa built one of the world's most extraordinary fortresses on a 200-meter granite monolith — Sigiriya. Now a UNESCO World Heritage Site called the \"Eighth Wonder of the World,\" it features remarkable Cloud Maiden frescoes, sophisticated water gardens, and an iconic Lion's Gate.",
      'contributions': ['Built UNESCO Sigiriya', 'Created water gardens', 'Cloud Maiden frescoes', 'Pioneered hydraulic engineering'],
      'monuments': ['Sigiriya Rock Fortress', 'Sigiriya Water Gardens', 'Sigiriya Frescoes'],
      'xpReward': 15,
    },
    {
      'name': 'King Parakramabahu I', 'period': '1153–1186 AD', 'icon': '👑',
      'kingdom': 'Polonnaruwa Kingdom',
      'story': "King Parakramabahu I created Sri Lanka's \"Golden Age.\" He unified three warring kingdoms, commissioned the magnificent Gal Viharaya sculptures, and built the vast Parakrama Samudraya reservoir. His declaration about not wasting water reflects deep wisdom still relevant today.",
      'contributions': ['Unified three warring kingdoms', 'Built Parakrama Samudraya', 'Commissioned Gal Viharaya', 'Strengthened naval power'],
      'monuments': ['Parakrama Samudraya', 'Gal Viharaya', 'Lankathilaka'],
      'xpReward': 18,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final k = _kings[kingId.clamp(0, _kings.length - 1)];
    final contributions = List<String>.from(k['contributions'] as List);
    final monuments = List<String>.from(k['monuments'] as List);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => context.go('/kings'),
        ),
        title: Text(
          '📖 ${k['name']}',
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.card, AppColors.card2]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withOpacity(0.2)),
              ),
              child: Column(children: [
                Text(k['icon']! as String, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 12),
                Text(k['name']! as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold)),
                const SizedBox(height: 4),
                Text(k['period']! as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                Text(k['kingdom']! as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
              ]),
            ),
            const SizedBox(height: 14),

            // Story
            _section(
              title: p.lang == 'si' ? '📖 ඉතිහාස කතාව' : p.lang == 'ta' ? '📖 வரலாறு' : '📖 Historical Narrative',
              child: Text(k['story']! as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.9)),
            ),
            const SizedBox(height: 14),

            // Key Facts Row
            Row(children: [
              _factBox(contributions.length.toString(), p.lang == 'si' ? 'සේවාවන්' : 'Contributions'),
              const SizedBox(width: 8),
              _factBox(monuments.length.toString(), p.lang == 'si' ? 'ස්මාරක' : 'Monuments'),
              const SizedBox(width: 8),
              _factBox('+${k['xpReward']}', 'XP'),
            ]),
            const SizedBox(height: 14),

            // Contributions
            _section(
              title: p.lang == 'si' ? '⭐ ප්‍රධාන කළ සේවාවන්' : '⭐ Key Contributions',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contributions.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 8),
                  child: Row(children: [
                    const Text('▸ ', style: TextStyle(color: AppColors.gold, fontSize: 10)),
                    Expanded(child: Text(c, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5))),
                  ]),
                )).toList(),
              ),
            ),

            if (monuments.isNotEmpty) ...[
              const SizedBox(height: 14),
              _section(
                title: p.lang == 'si' ? '🏛️ ඉදිකළ ස්ථාන' : '🏛️ Monuments Built',
                child: Wrap(
                  spacing: 8, runSpacing: 6,
                  children: monuments.map((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                    ),
                    child: Text(m, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/quiz/kings'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  p.lang == 'si' ? '🎯 ප්‍රශ්නාවලිය ගන්න' : p.lang == 'ta' ? '🎯 வினாடி வினா' : '🎯 Take the Kings Quiz',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 12, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  Widget _factBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.gold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}
