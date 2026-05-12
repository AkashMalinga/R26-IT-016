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
      case 'king':   return AppColors.gold;
      case 'battle': return AppColors.red;
      case 'temple': return AppColors.purple;
      case 'water':  return AppColors.blue;
      default:       return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          p.lang == 'si' ? '📜 ඉතිහාස Timeline' : p.lang == 'ta' ? '📜 வரலாறு Timeline' : '📜 History Timeline',
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 16),
        ),
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    event['year']!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(children: [
                const SizedBox(height: 10),
                Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                if (i < _events.length - 1)
                  Container(width: 2, height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [color.withOpacity(0.4), color.withOpacity(0.05)],
                      ),
                    ),
                  ),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
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
