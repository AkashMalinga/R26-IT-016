import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});
  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  int? _activeGame;
  int _matchScore = 0;

  final List<Map<String, dynamic>> _games = [
    {'icon': '👑', 'title': 'King–Kingdom Match', 'desc': 'Match each king to their kingdom!', 'pairs': [
      {'left': 'Vijaya', 'right': 'Tambapanni'}, {'left': 'Kashyapa', 'right': 'Sigiriya'},
      {'left': 'Mahasena', 'right': 'Anuradhapura'}, {'left': 'Parakramabahu', 'right': 'Polonnaruwa'},
    ]},
    {'icon': '🗺️', 'title': 'Province–City Match', 'desc': 'Match provinces to their main city!', 'pairs': [
      {'left': 'Western', 'right': 'Colombo'}, {'left': 'Central', 'right': 'Kandy'},
      {'left': 'Southern', 'right': 'Galle'}, {'left': 'Northern', 'right': 'Jaffna'},
    ]},
    {'icon': '🏛️', 'title': 'Monument Builder', 'desc': 'Match monuments to their builders!', 'pairs': [
      {'left': 'Ruwanwelisaya', 'right': 'Dutugamunu'}, {'left': 'Sigiriya', 'right': 'Kashyapa'},
      {'left': 'Minneriya Tank', 'right': 'Mahasena'}, {'left': 'Gal Viharaya', 'right': 'Parakramabahu'},
    ]},
  ];

  String? _selectedLeft;
  Set<String> _matched = {};

  void _startGame(int idx) {
    setState(() {
      _activeGame = idx;
      _selectedLeft = null;
      _matched = {};
      _matchScore = 0;
    });
  }

  void _tapLeft(String val) {
    setState(() => _selectedLeft = val);
  }

  void _tapRight(BuildContext context, AppProvider p, String rightVal) {
    if (_selectedLeft == null) return;
    final pairs = _games[_activeGame!]['pairs'] as List<Map<String, dynamic>>;
    final correct = pairs.any((pair) => pair['left'] == _selectedLeft && pair['right'] == rightVal);
    if (correct) {
      setState(() {
        _matched.add(_selectedLeft!);
        _matchScore++;
        _selectedLeft = null;
      });
      p.addXP(10, coins: 5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Correct! +10 XP'), backgroundColor: AppColors.green, duration: Duration(seconds: 1)),
      );
      if (_matchScore == pairs.length) {
        Future.delayed(const Duration(milliseconds: 400), () {
          p.addXP(50, coins: 25);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🏆 All matched! +50 XP'), backgroundColor: AppColors.gold, duration: Duration(seconds: 2)),
          );
        });
      }
    } else {
      setState(() => _selectedLeft = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Try again!'), backgroundColor: AppColors.red, duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () {
            if (_activeGame != null) setState(() => _activeGame = null);
            else context.go('/home');
          },
        ),
        title: Text(p.lang == 'si' ? '🎮 ඉගෙනීම් ක්‍රීඩා' : '🎮 Learning Games',
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800)),
      ),
      body: _activeGame != null ? _gameView(context, p) : _gameList(context),
    );
  }

  Widget _gameList(BuildContext context) => ListView(
    padding: const EdgeInsets.all(14),
    children: _games.asMap().entries.map((e) => GestureDetector(
      onTap: () => _startGame(e.key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x0FFFFFFF))),
        child: Row(children: [
          Text(_games[e.key]['icon'], style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_games[e.key]['title'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text(_games[e.key]['desc'], style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0x33D4A017), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0x4DD4A017))),
            child: const Text('🎮 Play', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    )).toList(),
  );

  Widget _gameView(BuildContext context, AppProvider p) {
    final game = _games[_activeGame!];
    final pairs = List<Map<String, dynamic>>.from(game['pairs']);
    final lefts = pairs.map((e) => e['left'] as String).toList()..shuffle();
    final rights = pairs.map((e) => e['right'] as String).toList()..shuffle();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(game['title'], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 14)),
            Text('$_matchScore/${pairs.length} matched', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: Text('Match This', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      ...lefts.map((left) {
                        final isMatched = _matched.contains(left);
                        final isSelected = _selectedLeft == left;
                        return GestureDetector(
                          onTap: isMatched ? null : () => _tapLeft(left),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMatched ? const Color(0x1A27AE60) : isSelected ? const Color(0x1AD4A017) : AppColors.card2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isMatched ? AppColors.green : isSelected ? AppColors.gold : const Color(0x1AFFFFFF), width: 1.5),
                            ),
                            child: Text(left, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isMatched ? const Color(0xFF5DDE8C) : isSelected ? AppColors.goldLight : AppColors.textPrimary), textAlign: TextAlign.center),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: Text('To This', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      ...rights.map((right) {
                        final isMatched = pairs.any((pair) => pair['right'] == right && _matched.contains(pair['left']));
                        return GestureDetector(
                          onTap: isMatched ? null : () => _tapRight(context, p, right),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMatched ? const Color(0x1A27AE60) : AppColors.card2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isMatched ? AppColors.green : const Color(0x33FFFFFF), style: BorderStyle.solid),
                            ),
                            child: Text(right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isMatched ? const Color(0xFF5DDE8C) : AppColors.textSecondary), textAlign: TextAlign.center),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => _startGame(_activeGame!), child: const Text('🔄 Restart'))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton(
              onPressed: () => setState(() => _activeGame = null),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.textMuted)),
              child: const Text('← Back', style: TextStyle(color: AppColors.textSecondary)),
            )),
          ]),
        ),
      ],
    );
  }
}
