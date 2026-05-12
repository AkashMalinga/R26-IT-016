// ═══════════════════════════════════════
// MAP SCREEN — lib/screens/map_screen.dart
// ═══════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> _provinces = [];
  int _selected = -1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final lang = context.read<AppProvider>().lang;
    try {
      _provinces = await ApiService().getProvinces(lang);
    } catch (_) {
      _provinces = _fallback(lang);
    }
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _fallback(String lang) => [
    {'id': 0, 'name': lang == 'si' ? 'උතුරු පළාත' : 'Northern Province', 'flag': '🔵', 'tags': ['Tamil Culture'], 'places': ['Nallur Kovil','Jaffna Fort'], 'industry': 'Fisheries, Agriculture', 'dist': 'Jaffna, Kilinochchi'},
    {'id': 1, 'name': lang == 'si' ? 'නැගෙනහිර පළාත' : 'Eastern Province', 'flag': '🟠', 'tags': ['Surfing'], 'places': ['Arugam Bay','Pasikuda'], 'industry': 'Tourism, Fisheries', 'dist': 'Trincomalee, Batticaloa'},
    {'id': 2, 'name': lang == 'si' ? 'උතුරු මැද පළාත' : 'North Central Province', 'flag': '🟣', 'tags': ['UNESCO'], 'places': ['Sri Maha Bodhi','Ruwanwelisaya'], 'industry': 'Agriculture, Tourism', 'dist': 'Anuradhapura, Polonnaruwa'},
    {'id': 3, 'name': lang == 'si' ? 'වයඹ පළාත' : 'North Western Province', 'flag': '🟢', 'tags': ['Coconut'], 'places': ['Wilpattu'], 'industry': 'Coconut, Salt', 'dist': 'Kurunegala, Puttalam'},
    {'id': 4, 'name': lang == 'si' ? 'මධ්‍යම පළාත' : 'Central Province', 'flag': '🩷', 'tags': ['Tea'], 'places': ['Sigiriya','Temple of Tooth'], 'industry': 'Tea, Tourism', 'dist': 'Kandy, Matale'},
    {'id': 5, 'name': lang == 'si' ? 'බස්නාහිර පළාත' : 'Western Province', 'flag': '🟡', 'tags': ['Economic Hub'], 'places': ['Lotus Tower','Galle Face'], 'industry': 'IT, Banking', 'dist': 'Colombo, Gampaha'},
    {'id': 6, 'name': lang == 'si' ? 'ඌව පළාත' : 'Uva Province', 'flag': '🩵', 'tags': ['Tea','Ella'], 'places': ['Nine Arches Bridge','Ella Rock'], 'industry': 'Tea, Eco Tourism', 'dist': 'Badulla, Monaragala'},
    {'id': 7, 'name': lang == 'si' ? 'දකුණු පළාත' : 'Southern Province', 'flag': '🔴', 'tags': ['Galle Fort'], 'places': ['Galle Fort','Yala'], 'industry': 'Tourism, Fisheries', 'dist': 'Galle, Matara'},
    {'id': 8, 'name': lang == 'si' ? 'සබරගමුව පළාත' : 'Sabaragamuwa Province', 'flag': '🍏', 'tags': ['Gems'], 'places': ["Adam's Peak","Sinharaja"], 'industry': 'Gem Mining, Rubber', 'dist': 'Ratnapura, Kegalle'},
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold), onPressed: () => context.go('/home')),
        title: Text(p.lang == 'si' ? '🗺️ ශ්‍රී ලංකා සිතියම' : p.lang == 'ta' ? '🗺️ இலங்கை வரைபடம்' : '🗺️ Sri Lanka Map',
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Center(child: Text(p.lang == 'si' ? '📍 පළාතක් ස්පර්ශ කරන්න' : 'Tap a province to explore', style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
                const SizedBox(height: 10),
                ..._provinces.asMap().entries.map((e) {
                  final i = e.key;
                  final prov = e.value;
                  final visited = p.provincesVisited.contains(prov['id']);
                  return GestureDetector(
                    onTap: () async {
                      setState(() => _selected = i);
                      await p.visitProvince(prov['id'] as int);
                      await p.addXP(5, coins: 3);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('🗺️ ${prov['name']} · +5 XP · +3 🪙'), backgroundColor: AppColors.navy3, duration: const Duration(seconds: 2)),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selected == i ? const Color(0x1AD4A017) : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _selected == i ? AppColors.gold : const Color(0x0FFFFFFF), width: _selected == i ? 1.5 : 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(prov['flag'] ?? '🗺️', style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(prov['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 14)),
                                Text(prov['dist'] ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            )),
                            if (visited) const Icon(Icons.check_circle, color: AppColors.green, size: 20),
                          ]),
                          if (_selected == i) ...[
                            const SizedBox(height: 10),
                            Wrap(spacing: 5, runSpacing: 4, children: List<String>.from(prov['tags'] ?? []).map((tag) =>
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0x0DFFFFFF), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0x0FFFFFFF))),
                                child: Text(tag, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              )
                            ).toList()),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0x07FFFFFF), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0x07FFFFFF))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.lang == 'si' ? 'කර්මාන්ත' : 'Industries', style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(prov['industry'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(p.lang == 'si' ? '📍 ප්‍රසිද්ධ ස්ථාන' : '📍 Famous Places', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(height: 4),
                            Wrap(spacing: 6, runSpacing: 4, children: List<String>.from(prov['places'] ?? []).map((pl) =>
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: const Color(0x1A2980B9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0x332980B9))),
                                child: Text(pl, style: const TextStyle(color: Color(0xFF74B9E8), fontSize: 11)),
                              )
                            ).toList()),
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(child: ElevatedButton(onPressed: () => context.go('/kings'), child: Text(p.lang == 'si' ? 'ගවේෂණ →' : 'Explore →'))),
                              const SizedBox(width: 8),
                              Expanded(child: OutlinedButton(
                                onPressed: () => context.go('/quiz/provinces'),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold)),
                                child: const Text('🎯 Quiz', style: TextStyle(color: AppColors.gold)),
                              )),
                            ]),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
