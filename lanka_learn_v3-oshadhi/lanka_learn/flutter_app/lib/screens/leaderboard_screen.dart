import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _board = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final svc = ApiService();
      _board = await svc.getLeaderboard();
    } catch (e) {
      _error = e.toString();
      _board = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => context.go('/progress'),
        ),
        title: const Text(
          '🏆 Leaderboard',
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gold),
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _board.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      const Text(
                        'No rankings yet!',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Login and complete quizzes\nto appear on the leaderboard.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Backend: $_error',
                          style: const TextStyle(color: AppColors.red, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _board.length,
                  itemBuilder: (_, i) {
                    final entry = _board[i];
                    final rank = (entry['rank'] ?? (i + 1)) as int;
                    final isTop3 = rank <= 3;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isTop3 ? AppColors.gold.withOpacity(0.1) : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isTop3 ? AppColors.gold.withOpacity(0.3) : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Row(children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '#$rank',
                            style: TextStyle(
                              fontSize: rank <= 3 ? 22 : 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              entry['name'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
                            ),
                            Text(
                              'Level ${entry['level'] ?? 1} · ${entry['accuracy'] ?? 0}% accuracy',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ]),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(
                            '${entry['xp'] ?? 0} XP',
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          Text(
                            '🪙 ${entry['coins'] ?? 0}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ]),
                      ]),
                    );
                  },
                ),
    );
  }
}
