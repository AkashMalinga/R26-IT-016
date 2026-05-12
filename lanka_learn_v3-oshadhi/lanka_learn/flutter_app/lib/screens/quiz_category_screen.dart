import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class QuizCategoryScreen extends StatelessWidget {
  const QuizCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final categories = [
      {'icon': '👑', 'name': p.lang == 'si' ? 'රජවරු' : p.lang == 'ta' ? 'அரசர்கள்' : 'Kings', 'cat': 'kings', 'count': '8'},
      {'icon': '🗺️', 'name': p.lang == 'si' ? 'පළාත්' : p.lang == 'ta' ? 'மாகாணங்கள்' : 'Provinces', 'cat': 'provinces', 'count': '7'},
      {'icon': '🏛️', 'name': p.lang == 'si' ? 'ස්මාරක' : p.lang == 'ta' ? 'நினைவுச்சின்னங்கள்' : 'Monuments', 'cat': 'monuments', 'count': '5'},
      {'icon': '🎲', 'name': p.lang == 'si' ? 'සියල්ල' : p.lang == 'ta' ? 'அனைத்தும்' : 'All Topics', 'cat': 'all', 'count': '20'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold), onPressed: () => context.go('/home')),
        title: Text(p.lang == 'si' ? '🎯 ප්‍රශ්නාවලිය' : p.lang == 'ta' ? '🎯 வினாடி வினா' : '🎯 Quiz Challenge',
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // AI banner
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0x338E44AD), Color(0x262980B9)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x4D8E44AD)),
              ),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Adaptive Quiz', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFC39BD3), fontSize: 13)),
                      GestureDetector(
                        onTap: () => context.go('/quiz/ai'),
                        child: const Text('Claude AI generates personalized questions based on your level', style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.5)),
                      ),
                    ],
                  )),
                  GestureDetector(
                    onTap: () => context.go('/quiz/ai'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF8E44AD), Color(0xFF2980B9)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                return GestureDetector(
                  onTap: () => context.go('/quiz/${cat['cat']}'),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x0FFFFFFF))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat['icon']!, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(cat['name']!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13), textAlign: TextAlign.center),
                        const SizedBox(height: 3),
                        Text('${cat['count']} questions', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
