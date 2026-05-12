// progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final lvl = AppConstants.getLevelInfo(p.xp);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold), onPressed: () => context.go('/home')),
        title: Text(p.lang == 'si' ? '📊 ඉගෙනීම් ප්‍රගතිය' : p.lang == 'ta' ? '📊 கற்றல் முன்னேற்றம்' : '📊 Learning Progress',
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: [
                _statCard('${p.xp}', p.lang == 'si' ? 'මුළු XP' : 'Total XP'),
                _statCard('${p.accuracy}%', p.lang == 'si' ? 'නිරවද්‍යතාව' : 'Accuracy'),
                _statCard('${p.provincesVisited.length}/9', p.lang == 'si' ? 'පළාත්' : 'Provinces'),
                _statCard('${p.totalAnswered}', p.lang == 'si' ? 'ප්‍රශ්න' : 'Questions'),
              ],
            ),
            const SizedBox(height: 14),

            // Quiz history chart
            _chartCard(p),
            const SizedBox(height: 14),

            // Topic progress
            _topicCard(p),
            const SizedBox(height: 14),

            // Achievements
            _achievementsCard(p),
            const SizedBox(height: 14),

            // Leaderboard button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/leaderboard'),
                icon: const Text('🏆'),
                label: Text(p.lang == 'si' ? 'Leaderboard බලන්න' : 'View Leaderboard'),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x0FFFFFFF))),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.gold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    ),
  );

  Widget _chartCard(AppProvider p) {
    final history = p.quizHistory.isEmpty ? [0] : p.quizHistory;
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    while (history.length < 7) history.insert(0, 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x0FFFFFFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.lang == 'si' ? '📅 ප්‍රශ්නාවලි ලකුණු' : '📅 Quiz Score History',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 13)),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(7, (i) => BarChartGroupData(
                  x: i,
                  barRods: [BarChartRodData(toY: history[i].toDouble(), color: AppColors.gold, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
                )),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(days[v.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 9)), reservedSize: 20)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topicCard(AppProvider p) {
    final topics = [
      {'icon': '👑', 'name': p.lang == 'si' ? 'රජවරු' : 'Kings', 'pct': p.kingsViewed.isEmpty ? 0 : (p.kingsViewed.length * 100 ~/ 6)},
      {'icon': '🗺️', 'name': p.lang == 'si' ? 'පළාත්' : 'Provinces', 'pct': p.provincesVisited.isEmpty ? 0 : (p.provincesVisited.length * 100 ~/ 9)},
      {'icon': '🎯', 'name': 'Quiz Accuracy', 'pct': p.accuracy},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x0FFFFFFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.lang == 'si' ? '📚 මාතෘකා ප්‍රගතිය' : '📚 Topic Progress', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 13)),
          const SizedBox(height: 14),
          ...topics.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Text(t['icon']! as String, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['name']! as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (t['pct']! as int) / 100.0,
                      backgroundColor: const Color(0x14FFFFFF),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      minHeight: 7,
                    ),
                  ),
                ],
              )),
              const SizedBox(width: 10),
              Text('${t['pct']}%', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _achievementsCard(AppProvider p) {
    final achs = [
      {'icon': '👑', 'name': 'King Expert', 'lit': p.kingsViewed.length >= 6},
      {'icon': '🗺️', 'name': 'Explorer', 'lit': p.provincesVisited.length >= 5},
      {'icon': '🏆', 'name': 'Champion', 'lit': p.xp >= 200},
      {'icon': '🌟', 'name': 'Regular', 'lit': p.totalAnswered >= 10},
      {'icon': '💡', 'name': 'Sharp Mind', 'lit': p.accuracy >= 80 && p.totalAnswered >= 5},
      {'icon': '📚', 'name': 'Scholar', 'lit': p.totalAnswered >= 25},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x0FFFFFFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.lang == 'si' ? '🏅 Achievements' : '🏅 Achievements', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 13)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.1),
            itemCount: achs.length,
            itemBuilder: (_, i) {
              final ach = achs[i];
              final lit = ach['lit'] as bool;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: lit ? const Color(0x0AD4A017) : AppColors.card2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: lit ? const Color(0x4DD4A017) : const Color(0x0AFFFFFF)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(lit ? (ach['icon'] as String) : '🔒', style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(ach['name'] as String, style: TextStyle(fontSize: 10, color: lit ? AppColors.gold : AppColors.textMuted, textBaseline: TextBaseline.alphabetic), textAlign: TextAlign.center),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}
