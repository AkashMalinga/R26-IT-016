import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class FunActivitiesScreen extends StatelessWidget {
  const FunActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🎮 Fun Activities'),
        backgroundColor: AppColors.success),
    backgroundColor: AppColors.background,
    body: GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.95,
      children: [
        _ActivityCard(emoji: '🔤', title: 'Letter Quiz',
            subtitle: 'Guess the letter!', color: AppColors.primary,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LetterQuizGame()))),
        _ActivityCard(emoji: '🧩', title: 'Word Match',
            subtitle: 'Match words & pics', color: AppColors.secondary,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WordMatchGame()))),
        _ActivityCard(emoji: '🃏', title: 'Memory Game',
            subtitle: 'Find the pairs!', color: AppColors.success,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MemoryCardGame()))),
        _ActivityCard(emoji: '🎵', title: 'Alphabet Song',
            subtitle: 'Browse all letters', color: AppColors.warning,
            onTap: () => Navigator.pushNamed(context, '/alphabet')),
        _ActivityCard(emoji: '🔢', title: 'Count & Write',
            subtitle: 'Numbers fun!', color: AppColors.accent,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CountWriteGame()))),
        _ActivityCard(emoji: '🌈', title: 'Colors',
            subtitle: 'Learn in 3 languages', color: const Color(0xFF9C27B0),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ColorLearnScreen()))),
      ],
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActivityCard({required this.emoji, required this.title,
      required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 64, height: 64,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30)))),
        const SizedBox(height: 10),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
//  1. LETTER QUIZ GAME
// ═══════════════════════════════════════════════════════════════════════════════
class LetterQuizGame extends StatefulWidget {
  const LetterQuizGame({super.key});
  @override State<LetterQuizGame> createState() => _LetterQuizGameState();
}

class _LetterQuizGameState extends State<LetterQuizGame> {
  static const _qBank = [
    {'q': '🍎 Apple starts with?', 'ans': 'A', 'opts': ['A','B','C','D']},
    {'q': '🍌 Banana starts with?', 'ans': 'B', 'opts': ['A','B','C','D']},
    {'q': '🐱 Cat starts with?',    'ans': 'C', 'opts': ['A','B','C','D']},
    {'q': '🐘 Elephant starts with?','ans': 'E', 'opts': ['E','F','G','H']},
    {'q': '🦊 Fox starts with?',    'ans': 'F', 'opts': ['E','F','G','H']},
    {'q': '🍇 Grapes starts with?', 'ans': 'G', 'opts': ['E','F','G','H']},
    {'q': '🦁 Lion starts with?',   'ans': 'L', 'opts': ['I','J','K','L']},
    {'q': '🌙 Moon starts with?',   'ans': 'M', 'opts': ['M','N','O','P']},
    {'q': '☀️ Sun starts with?',    'ans': 'S', 'opts': ['Q','R','S','T']},
    {'q': '🐢 Turtle starts with?', 'ans': 'T', 'opts': ['Q','R','S','T']},
    {'q': '🍉 Watermelon starts with?','ans': 'W', 'opts': ['U','V','W','X']},
    {'q': 'ක stands for?',          'ans': 'K', 'opts': ['K','G','C','T']},
  ];

  late List<Map> _qs;
  int _qi = 0, _score = 0;
  String? _selected;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final all = List<Map>.from(_qBank)..shuffle();
    _qs = all.take(8).toList();
  }

  void _answer(String opt) {
    if (_selected != null) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = opt);
    if (opt == _qs[_qi]['ans']) setState(() => _score++);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_qi + 1 < _qs.length) {
        setState(() { _qi++; _selected = null; });
      } else {
        setState(() => _done = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _ResultScreen(score: _score, total: _qs.length,
        onRestart: () => Navigator.pop(context));

    final q = _qs[_qi];
    return Scaffold(
      appBar: AppBar(title: const Text('🔤 Letter Quiz'),
          backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          LinearProgressIndicator(value: _qi / _qs.length,
              color: AppColors.primary, backgroundColor: Colors.grey.shade200,
              minHeight: 8, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 8),
          Text('${_qi + 1} / ${_qs.length}  •  ⭐ $_score',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFEDE9FF),
                borderRadius: BorderRadius.circular(20)),
            child: Text(q['q'] as String, style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D2B55)),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
            children: (q['opts'] as List<String>).map((opt) {
              Color bg = Colors.white;
              Color border = Colors.grey.shade300;
              if (_selected != null) {
                if (opt == q['ans']) { bg = const Color(0xFFE8F8F0); border = AppColors.success; }
                else if (opt == _selected) { bg = const Color(0xFFFFE8E8); border = AppColors.error; }
              }
              return GestureDetector(
                onTap: () => _answer(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 120, height: 64,
                  decoration: BoxDecoration(color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border, width: 2),
                      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: Center(child: Text(opt, style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900))),
                ),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  2. WORD MATCH GAME
// ═══════════════════════════════════════════════════════════════════════════════
class WordMatchGame extends StatefulWidget {
  const WordMatchGame({super.key});
  @override State<WordMatchGame> createState() => _WordMatchGameState();
}

class _WordMatchGameState extends State<WordMatchGame> {
  static const _pairs = [
    {'word': 'CAT','emoji': '🐱'}, {'word': 'DOG','emoji': '🐶'},
    {'word': 'SUN','emoji': '☀️'}, {'word': 'TREE','emoji': '🌳'},
    {'word': 'FISH','emoji': '🐟'}, {'word': 'MOON','emoji': '🌙'},
    {'word': 'STAR','emoji': '⭐'}, {'word': 'APPLE','emoji': '🍎'},
  ];

  late List<Map> _words, _emojis;
  String? _selWord;
  int _score = 0;
  final Set<String> _matched = {};

  @override void initState() { super.initState(); _init(); }

  void _init() {
    final p = List<Map>.from(_pairs)..shuffle();
    _words  = p.map((e) => {'word': e['word']}).toList();
    _emojis = List<Map>.from(p)..shuffle();
    _selWord = null; _score = 0; _matched.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_matched.length == _pairs.length) return _ResultScreen(
        score: _score, total: _pairs.length, onRestart: () => Navigator.pop(context));

    return Scaffold(
      appBar: AppBar(title: const Text('🧩 Word Match'),
          backgroundColor: AppColors.secondary),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Matched $_score / ${_pairs.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Tap a WORD then tap its EMOJI!',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          Expanded(child: Row(children: [
            // Words
            Expanded(child: Column(children: _words.map((item) {
              final w = item['word'] as String;
              final matched = _matched.contains(w);
              return Expanded(child: GestureDetector(
                onTap: matched ? null : () {
                  HapticFeedback.selectionClick();
                  setState(() => _selWord = w);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: matched ? const Color(0xFFE8F8F0)
                        : _selWord == w ? const Color(0xFFEDE9FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: matched ? AppColors.success
                          : _selWord == w ? AppColors.primary : Colors.grey.shade200,
                      width: 2),
                  ),
                  child: Center(child: Text(matched ? '✓ $w' : w,
                      style: TextStyle(fontWeight: FontWeight.w800,
                          color: matched ? AppColors.success : Colors.black87,
                          fontSize: 13))),
                ),
              ));
            }).toList())),
            // Emojis
            Expanded(child: Column(children: _emojis.map((item) {
              final w = item['word'] as String;
              final emoji = item['emoji'] as String;
              final matched = _matched.contains(w);
              return Expanded(child: GestureDetector(
                onTap: matched || _selWord == null ? null : () {
                  if (_selWord == w) {
                    HapticFeedback.lightImpact();
                    setState(() { _matched.add(w); _score++; _selWord = null; });
                  } else {
                    HapticFeedback.heavyImpact();
                    setState(() => _selWord = null);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: matched ? const Color(0xFFE8F8F0) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: matched ? AppColors.success : Colors.grey.shade200, width: 2),
                  ),
                  child: Center(child: Text(matched ? '✓' : emoji,
                      style: const TextStyle(fontSize: 28))),
                ),
              ));
            }).toList())),
          ])),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  3. MEMORY CARD GAME
// ═══════════════════════════════════════════════════════════════════════════════
class MemoryCardGame extends StatefulWidget {
  const MemoryCardGame({super.key});
  @override State<MemoryCardGame> createState() => _MemoryCardGameState();
}

class _MemoryCardGameState extends State<MemoryCardGame> {
  static const _items = ['🍎','🐱','☀️','🌳','🐟','🌙','⭐','🦁'];
  late List<String> _cards;
  late List<bool> _flipped, _matched;
  int? _first, _second;
  int _moves = 0, _pairs = 0;
  bool _checking = false;

  @override void initState() { super.initState(); _init(); }

  void _init() {
    _cards = [..._items, ..._items]..shuffle();
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _first = _second = null; _moves = _pairs = 0; _checking = false;
  }

  void _flip(int i) {
    if (_checking || _flipped[i] || _matched[i]) return;
    HapticFeedback.selectionClick();
    setState(() => _flipped[i] = true);
    if (_first == null) {
      _first = i;
    } else {
      _second = i; _moves++;
      _checking = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          if (_cards[_first!] == _cards[_second!]) {
            _matched[_first!] = _matched[_second!] = true;
            _pairs++;
            HapticFeedback.lightImpact();
          } else {
            _flipped[_first!] = _flipped[_second!] = false;
          }
          _first = _second = null; _checking = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pairs == _items.length) return _ResultScreen(score: _pairs, total: _items.length,
        onRestart: () => Navigator.pop(context));

    return Scaffold(
      appBar: AppBar(title: const Text('🃏 Memory Game'),
          backgroundColor: AppColors.success),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text('Moves: $_moves', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Pairs: $_pairs/${_items.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ])),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: _cards.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _flip(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _matched[i] ? const Color(0xFFE8F8F0)
                    : _flipped[i] ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Center(child: Text(
                _flipped[i] || _matched[i] ? _cards[i] : '?',
                style: TextStyle(fontSize: 28,
                    color: _flipped[i] || _matched[i] ? null : Colors.white,
                    fontWeight: FontWeight.w900),
              )),
            ),
          ),
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  4. COUNT & WRITE GAME
// ═══════════════════════════════════════════════════════════════════════════════
class CountWriteGame extends StatefulWidget {
  const CountWriteGame({super.key});
  @override State<CountWriteGame> createState() => _CountWriteGameState();
}

class _CountWriteGameState extends State<CountWriteGame> {
  static const _qs = [
    {'d': '🍎🍎🍎',    'n': 3}, {'d': '⭐⭐',       'n': 2},
    {'d': '🐱🐱🐱🐱',  'n': 4}, {'d': '🌳',         'n': 1},
    {'d': '🏠🏠🏠🏠🏠','n': 5}, {'d': '🎈🎈🎈🎈🎈🎈','n': 6},
    {'d': '🦋🦋🦋🦋🦋🦋🦋','n':7},
  ];

  int _qi = 0, _score = 0;
  int? _selected;
  bool _done = false;

  void _answer(int n) {
    if (_selected != null) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = n);
    if (n == _qs[_qi]['n']) setState(() => _score++);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_qi + 1 < _qs.length) setState(() { _qi++; _selected = null; });
      else setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _ResultScreen(score: _score, total: _qs.length,
        onRestart: () => Navigator.pop(context));

    return Scaffold(
      appBar: AppBar(title: const Text('🔢 Count & Write'),
          backgroundColor: AppColors.accent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          LinearProgressIndicator(value: _qi / _qs.length,
              color: AppColors.accent, minHeight: 8, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 24),
          const Text('How many?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(_qs[_qi]['d'] as String,
                style: const TextStyle(fontSize: 44), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
            children: List.generate(7, (i) {
              final n = i + 1;
              Color bg = Colors.white;
              if (_selected != null) {
                if (n == _qs[_qi]['n']) bg = const Color(0xFFE8F8F0);
                else if (n == _selected) bg = const Color(0xFFFFE8E8);
              }
              return GestureDetector(
                onTap: () => _answer(n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    color: bg, shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                    boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 4)],
                  ),
                  child: Center(child: Text('$n',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                ),
              );
            }),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  5. COLOR LEARN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class ColorLearnScreen extends StatefulWidget {
  const ColorLearnScreen({super.key});
  @override State<ColorLearnScreen> createState() => _ColorLearnScreenState();
}

class _ColorLearnScreenState extends State<ColorLearnScreen>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    {'color': 0xFFEF5350, 'en': 'RED',    'si': 'රතු',    'ta': 'சிவப்பு'},
    {'color': 0xFF1E88E5, 'en': 'BLUE',   'si': 'නිල්',   'ta': 'நீலம்'},
    {'color': 0xFF43A047, 'en': 'GREEN',  'si': 'කොළ',    'ta': 'பச்சை'},
    {'color': 0xFFFFB300, 'en': 'YELLOW', 'si': 'කහ',     'ta': 'மஞ்சள்'},
    {'color': 0xFFEF6C00, 'en': 'ORANGE', 'si': 'තැඹිලි', 'ta': 'ஆரஞ்சு'},
    {'color': 0xFF8E24AA, 'en': 'PURPLE', 'si': 'දම්',    'ta': 'ஊதா'},
    {'color': 0xFFE91E63, 'en': 'PINK',   'si': 'රෝස',    'ta': 'இளஞ்சிவப்பு'},
  ];

  int _ci = 0;
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
        ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.9, end: 1.0).animate(_pulse);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = _colors[_ci];
    final col = Color(c['color'] as int);
    return Scaffold(
      appBar: AppBar(title: const Text('🌈 Colors'), backgroundColor: col),
      body: Column(children: [
        Expanded(flex: 3, child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: double.infinity,
          color: col.withOpacity(0.1),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ScaleTransition(scale: _pulseAnim,
              child: Container(width: 150, height: 150,
                decoration: BoxDecoration(color: col, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: col.withOpacity(0.5), blurRadius: 30, spreadRadius: 6)]),
              )),
            const SizedBox(height: 20),
            Text(c['en'] as String, style: TextStyle(fontSize: 36,
                fontWeight: FontWeight.w900, color: col)),
          ]),
        )),
        // 3 language labels
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _LangLabel('🇬🇧', 'English', c['en'] as String, col),
            _LangLabel('🇱🇰', 'Sinhala', c['si'] as String, col),
            _LangLabel('🌺', 'Tamil',   c['ta'] as String, col),
          ]),
        ),
        // Dots
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
            _colors.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              width: i == _ci ? 20 : 8, height: 8,
              decoration: BoxDecoration(
                color: Color((_colors[i]['color'] as int)).withOpacity(i == _ci ? 1 : 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ))),
        // Nav buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(children: [
            Expanded(child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: BorderSide(color: col),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: _ci > 0 ? () => setState(() => _ci--) : null,
              child: Text('← Back', style: TextStyle(color: col, fontWeight: FontWeight.w700)),
            )),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: col,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: _ci < _colors.length - 1 ? () => setState(() => _ci++) : null,
              child: const Text('Next →', style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _LangLabel extends StatelessWidget {
  final String flag, lang, word;
  final Color color;
  const _LangLabel(this.flag, this.lang, this.word, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(flag, style: const TextStyle(fontSize: 18)),
    Text(lang, style: const TextStyle(color: Colors.grey, fontSize: 10)),
    const SizedBox(height: 3),
    Text(word, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
  ]);
}

// ── Shared Result Screen ──────────────────────────────────────────────────────
class _ResultScreen extends StatelessWidget {
  final int score, total;
  final VoidCallback onRestart;
  const _ResultScreen({required this.score, required this.total, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final pct = score / total;
    final emoji = pct >= 0.8 ? '🏆' : pct >= 0.5 ? '⭐' : '💪';
    final msg   = pct >= 0.8 ? 'Excellent!' : pct >= 0.5 ? 'Good Job!' : 'Keep Trying!';
    return Scaffold(
      body: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
              color: Color(0xFF2D2B55))),
          const SizedBox(height: 12),
          Text('$score out of $total correct!',
              style: const TextStyle(fontSize: 20, color: Colors.grey)),
          const SizedBox(height: 40),
          ElevatedButton.icon(icon: const Icon(Icons.replay),
              label: const Text('Play Again'), onPressed: onRestart),
          const SizedBox(height: 12),
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Back to Activities')),
        ]),
      )),
    );
  }
}
