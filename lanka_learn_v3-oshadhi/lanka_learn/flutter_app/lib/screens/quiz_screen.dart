import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  const QuizScreen({super.key, required this.category});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> _questions = [];
  int _qIdx = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _loading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final p = context.read<AppProvider>();
    try {
      if (widget.category == 'ai') {
        _questions = await ApiService().getAIQuiz(
          level: p.level,
          accuracy: p.accuracy,
          language: p.lang,
          weakTopics: p.weakTopics,
        );
      } else {
        _questions = await ApiService().getQuiz(category: widget.category, lang: p.lang, count: widget.category == 'daily' ? 7 : 5);
      }
    } catch (_) {
      _questions = _localFallback(p.lang);
    }
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _localFallback(String lang) => [
    {'q': lang == 'si' ? 'සිගිරිය ඉදිකළේ?' : lang == 'ta' ? 'சிகிரியாவை கட்டியவர்?' : 'Who built Sigiriya?', 'opts': lang == 'si' ? ['මහාසේන','දුටුගැමුණු','කාශ්‍යප','පරාක්‍රමබාහු'] : ['Mahasena','Dutugamunu','Kashyapa','Parakramabahu'], 'a': 2, 'e': 'King Kashyapa', 'diff': 'easy'},
    {'q': lang == 'si' ? 'ශ්‍රී ලංකාවේ පළාත් කීයක්?' : lang == 'ta' ? 'இலங்கையில் எத்தனை மாகாணங்கள்?' : 'How many provinces does Sri Lanka have?', 'opts': ['7','8','9','10'], 'a': 2, 'e': '9 provinces', 'diff': 'easy'},
    {'q': lang == 'si' ? '"වැව් බැඳි රජු"?' : '"Great Tank Builder"?', 'opts': lang == 'si' ? ['විජය','දේවානම්පිය','කාශ්‍යප','මහාසේන'] : ['Vijaya','Devanampiya','Kashyapa','Mahasena'], 'a': 3, 'e': 'King Mahasena', 'diff': 'easy'},
    {'q': lang == 'si' ? 'රුවන්වැලිසෑය ඉදිකළේ?' : 'Who built Ruwanwelisaya?', 'opts': lang == 'si' ? ['විජය','දේවානම්පිය','දුටුගැමුණු','මහාසේන'] : ['Vijaya','Devanampiya','Dutugamunu','Mahasena'], 'a': 2, 'e': 'King Dutugamunu', 'diff': 'medium'},
    {'q': 'Is Sigiriya a UNESCO World Heritage Site?', 'opts': ['Yes','No'], 'a': 0, 'e': 'Yes, Sigiriya is UNESCO.', 'diff': 'easy'},
  ];

  void _answer(int idx) {
    if (_answered) return;
    setState(() {
      _selected = idx;
      _answered = true;
      if (idx == (_questions[_qIdx]['a'] as int)) _score++;
    });
  }

  void _next() {
    if (_qIdx < _questions.length - 1) {
      setState(() { _qIdx++; _selected = null; _answered = false; });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final p = context.read<AppProvider>();
    final pct = (_score * 100 ~/ _questions.length);
    final xpGain = _score * (widget.category == 'daily' ? 20 : 10);
    final coinsGain = _score * 5;
    await p.addXP(xpGain, coins: coinsGain);
    await p.saveQuizResult(_score, _questions.length, widget.category, pct);
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold), onPressed: () => context.go('/quiz-category')),
        title: Text(p.lang == 'si' ? '🎯 ප්‍රශ්නාවලිය' : p.lang == 'ta' ? '🎯 வினாடி வினா' : '🎯 Quiz',
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? _loadingView(p)
          : _finished
          ? _endView(context, p)
          : _questionView(context, p),
    );
  }

  Widget _loadingView(AppProvider p) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircularProgressIndicator(color: AppColors.purple),
      const SizedBox(height: 16),
      Text(widget.category == 'ai' ? '🤖 AI Generating Quiz...' : '📚 Loading Quiz...', style: const TextStyle(color: Color(0xFFC39BD3), fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(p.lang == 'si' ? 'ඔබේ ඉගෙනීම් ස්තරය අනුව...' : 'Personalizing for your level...', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
    ],
  ));

  Widget _questionView(BuildContext context, AppProvider p) {
    final q = _questions[_qIdx];
    final opts = List<String>.from(q['opts'] ?? []);
    final correctIdx = q['a'] as int;
    final letters = ['A','B','C','D'];
    final diff = q['diff'] ?? 'medium';

    return Column(
      children: [
        // Progress dots
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: List.generate(_questions.length, (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: i < _qIdx ? AppColors.gold : i == _qIdx ? AppColors.goldLight : const Color(0x1AFFFFFF),
              ),
            ),
          ))),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meta row
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('$_score/${_qIdx} ✓', style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: diff == 'easy' ? const Color(0x1A27AE60) : diff == 'hard' ? const Color(0x1AE74C3C) : const Color(0x1AE67E22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(diff.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: diff == 'easy' ? const Color(0xFF5DDE8C) : diff == 'hard' ? const Color(0xFFFF7675) : const Color(0xFFF39C12))),
                  ),
                ]),
                const SizedBox(height: 16),

                // Question
                Text(q['q'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.7)),
                const SizedBox(height: 18),

                // Options
                ...List.generate(opts.length, (i) {
                  Color bgColor = const Color(0x0DFFFFFF);
                  Color borderColor = const Color(0x1AFFFFFF);
                  if (_answered) {
                    if (i == correctIdx) { bgColor = const Color(0x1A27AE60); borderColor = AppColors.green; }
                    else if (i == _selected) { bgColor = const Color(0x1AE74C3C); borderColor = AppColors.red; }
                  }
                  return GestureDetector(
                    onTap: () => _answer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor, width: 1.5)),
                      child: Row(children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: _answered && i == correctIdx ? AppColors.green : _answered && i == _selected ? AppColors.red : const Color(0x14FFFFFF),
                          ),
                          child: Center(child: Text(
                            _answered && i == correctIdx ? '✓' : _answered && i == _selected ? '✗' : letters[i],
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(opts[i], style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                      ]),
                    ),
                  );
                }),

                // Feedback
                if (_answered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selected == correctIdx ? const Color(0x0A27AE60) : const Color(0x0AE74C3C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selected == correctIdx ? const Color(0x3327AE60) : const Color(0x33E74C3C)),
                    ),
                    child: Text(
                      '${_selected == correctIdx ? "✅" : "❌"} ${q['e'] ?? ''}',
                      style: TextStyle(color: _selected == correctIdx ? const Color(0xFFA8E6C0) : const Color(0xFFFFB3B3), fontSize: 13, height: 1.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Next button
        if (_answered)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(_qIdx < _questions.length - 1 ? (p.lang == 'si' ? 'ඊළඟ ප්‍රශ්නය →' : p.lang == 'ta' ? 'அடுத்த கேள்வி →' : 'Next Question →') : (p.lang == 'si' ? 'ප්‍රතිඵල බලන්න 🏆' : 'See Results 🏆'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _endView(BuildContext context, AppProvider p) {
    final pct = (_score * 100 ~/ _questions.length);
    final icon = pct >= 80 ? '🏆' : pct >= 60 ? '⭐' : pct >= 40 ? '📚' : '💪';
    final xpGain = _score * (widget.category == 'daily' ? 20 : 10);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text('$_score/${_questions.length}', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: AppColors.gold)),
            Text(p.lang == 'si' ? 'ප්‍රශ්න' : p.lang == 'ta' ? 'கேள்விகள்' : 'questions', style: const TextStyle(color: AppColors.textMuted, fontSize: 18)),
            const SizedBox(height: 8),
            Text('$pct%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: const Color(0x1AD4A017), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0x33D4A017))),
              child: Text('🌟 +$xpGain XP · +${_score * 5} 🪙${widget.category == 'daily' ? ' (2x Daily!)' : ''}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                onPressed: () { setState(() { _qIdx = 0; _score = 0; _selected = null; _answered = false; _finished = false; _loading = true; }); _loadQuiz(); },
                child: Text(p.lang == 'si' ? 'නැවත' : p.lang == 'ta' ? 'மீண்டும்' : 'Try Again'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.textMuted)),
                child: Text(p.lang == 'si' ? 'ගෙදර' : p.lang == 'ta' ? 'முகப்பு' : 'Home', style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
