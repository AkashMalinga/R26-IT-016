import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  PROGRESS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true, _error = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final api = context.read<ApiService>();
      final d   = await api.getDashboard();
      setState(() { _data = d; _loading = false; });
    } catch (_) {
      setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('📊 My Progress'),
        backgroundColor: AppColors.warning,
        actions: [IconButton(icon: const Icon(Icons.refresh),
            onPressed: _load)]),
    backgroundColor: AppColors.background,
    body: _loading ? const Center(child: CircularProgressIndicator())
        : _error ? _OfflineMode()
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const _SectionTitle('📚 By Language'),
              const SizedBox(height: 10),
              ...(_data!['byCorpus'] as List? ?? [])
                  .map((item) => _CorpusCard(item: item)),
              const SizedBox(height: 20),
              const _SectionTitle('📅 Weekly Activity'),
              const SizedBox(height: 10),
              _WeeklyChart(data: _data!['weeklyProgress'] ?? []),
              const SizedBox(height: 20),
              const _SectionTitle('🕐 Recent Practice'),
              const SizedBox(height: 10),
              ...(_data!['recentAttempts'] as List? ?? []).take(6)
                  .map((a) => _AttemptTile(attempt: a)),
              const SizedBox(height: 20),
              if (_data!['sessionStats'] != null)
                _SessionCard(stats: _data!['sessionStats']),
            ]),
          ),
  );
}

class _OfflineMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('📡', style: TextStyle(fontSize: 60)),
      const SizedBox(height: 12),
      const Text('No connection to server',
          style: TextStyle(fontSize: 17, color: Colors.grey)),
      const Text('Your practice is saved locally.',
          style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Go Back'),
      ),
    ],
  ));
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
      fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)));
}

class _CorpusCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _CorpusCard({required this.item});

  static const _colors = {
    'Latin Uppercase': AppColors.english,
    'Latin Lowercase': Color(0xFF42A5F5),
    'Sinhala': AppColors.sinhala,
    'Tamil':   AppColors.tamil,
  };

  @override
  Widget build(BuildContext context) {
    final corpus  = item['_id'] as String? ?? '';
    final color   = _colors[corpus] ?? AppColors.primary;
    final avg     = (item['avgScore'] as num?)?.toDouble() ?? 0;
    final passed  = item['passed'] as int? ?? 0;
    final letters = (item['lettersLearned'] as List?)?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(AppCorpora.corpusEmojis[corpus] ?? '📝',
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(AppCorpora.corpusNames[corpus] ?? corpus,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const Spacer(),
          Text('${avg.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: avg / 100, backgroundColor: color.withOpacity(0.1),
            color: color, minHeight: 10)),
        const SizedBox(height: 8),
        Row(children: [
          _Chip('✅ $passed passed', color),
          const SizedBox(width: 8),
          _Chip('📝 $letters letters', color),
        ]),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text; final Color color;
  const _Chip(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10)),
    child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
  );
}

class _WeeklyChart extends StatelessWidget {
  final List<dynamic> data;
  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return Container(
      height: 80, decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16)),
      child: const Center(child: Text('No activity this week yet.',
          style: TextStyle(color: Colors.grey))));

    final maxScore = data.fold<double>(0, (m, d) =>
        [m, (d['avgScore'] as num).toDouble()].reduce((a, b) => a > b ? a : b));

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final score = (d['avgScore'] as num).toDouble();
          final label = (d['_id'] as String).substring(5);
          final h     = maxScore > 0 ? score / maxScore : 0.0;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('${score.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 8, color: Colors.grey)),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: (100 * h).clamp(4, 100),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF7986CB)],
                    begin: Alignment.bottomCenter, end: Alignment.topCenter),
                  borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
            ]),
          ));
        }).toList(),
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final Map<String, dynamic> attempt;
  const _AttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final passed = attempt['passed'] as bool? ?? false;
    final score  = attempt['score']  as int?  ?? 0;
    final letter = attempt['letter'] as String? ?? '';
    final corpus = attempt['corpus'] as String? ?? '';
    final color  = passed ? AppColors.success : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: Text(letter,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(corpus, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text('Score: $score%', style: TextStyle(
              fontWeight: FontWeight.w700, color: color)),
        ])),
        Text(passed ? '✅' : '❌', style: const TextStyle(fontSize: 20)),
      ]),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _SessionCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final secs = stats['totalSeconds'] as int? ?? 0;
    final sess = stats['sessions']     as int? ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF7986CB)]),
        borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Stat('$sess', 'Sessions', '📅'),
        _Stat('${secs ~/ 60}', 'Minutes', '⏱️'),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label, emoji;
  const _Stat(this.value, this.label, this.emoji);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 28)),
    Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
//  BADGES SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});
  @override State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<dynamic> _badges = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final api = context.read<ApiService>();
      final b   = await api.getBadges();
      setState(() { _badges = b; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🏆 My Badges'),
        backgroundColor: AppColors.accent),
    backgroundColor: AppColors.background,
    body: _loading ? const Center(child: CircularProgressIndicator())
        : _badges.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🏅', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            const Text('No badges yet!', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const Text('Start practicing to earn badges 🚀',
                style: TextStyle(color: Colors.grey)),
          ]))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14),
            itemCount: _badges.length,
            itemBuilder: (_, i) {
              final b = _badges[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.2),
                      blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(b['icon'] ?? '🏅', style: const TextStyle(fontSize: 44)),
                  const SizedBox(height: 8),
                  Text(b['title'] ?? '', textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                          color: Color(0xFF2D2B55))),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(b['description'] ?? '', textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                ]),
              );
            },
          ),
  );
}
