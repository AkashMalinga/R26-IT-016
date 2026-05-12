import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class KingsScreen extends StatefulWidget {
  const KingsScreen({super.key});
  @override
  State<KingsScreen> createState() => _KingsScreenState();
}

class _KingsScreenState extends State<KingsScreen> {
  final Set<int> _expanded = {};

  static const _kings = [
    {
      'id': 0, 'icon': '🤴', 'xpReward': 10,
      'en': {'name': 'Prince Vijaya', 'period': '543 BC', 'kingdom': 'Kingdom of Tambapanni', 'contributions': ['Founded first recorded kingdom', 'Began Sinhala civilization', 'Organized early administration'], 'monuments': []},
      'si': {'name': 'කුමාර විජය', 'period': '543 BC', 'kingdom': 'තම්බපණ්ණි රාජධානිය', 'contributions': ['පළමු රාජධානිය ස්ථාපිත කළා', 'සිංහල ජනවාර්ගය ආරම්භ කළා', 'මුල් රාජ්‍ය පාලනය සංවිධානය කළා'], 'monuments': []},
      'ta': {'name': 'இளவரசன் விஜயன்', 'period': '543 கி.மு.', 'kingdom': 'தம்பபண்ணி இராச்சியம்', 'contributions': ['முதல் இராச்சியம் நிறுவினார்', 'சிங்கள நாகரிகம் தொடங்கினார்', 'ஆரம்பகால ஆட்சி ஏற்படுத்தினார்'], 'monuments': []},
    },
    {
      'id': 1, 'icon': '🤴', 'xpReward': 12,
      'en': {'name': 'King Devanampiya Tissa', 'period': '247–207 BC', 'kingdom': 'Anuradhapura Kingdom', 'contributions': ['Accepted Buddhism as state religion', 'Brought Sri Maha Bodhi tree', 'Built Mahavihara monastery'], 'monuments': ['Mihintale', 'Sri Maha Bodhi', 'Mahavihara']},
      'si': {'name': 'රජ දේවානම්පිය තිස්ස', 'period': '247–207 BC', 'kingdom': 'අනුරාධපුර රාජධානිය', 'contributions': ['බෞද්ධ ආගම රාජ්‍ය ආගම ලෙස පිළිගත්තා', 'ශ්‍රී මහා බෝධිය ගෙනා', 'මහාවිහාරය ඉදිකළා'], 'monuments': ['මිහින්තලය', 'ශ්‍රී මහා බෝධිය', 'මහාවිහාරය']},
      'ta': {'name': 'மன்னன் தேவானம்பியதிஸ்ஸ', 'period': '247–207 கி.மு.', 'kingdom': 'அனுராதபுர இராச்சியம்', 'contributions': ['பௌத்தத்தை அரச மதமாக ஏற்றார்', 'ஸ்ரீ மஹா போதியை கொண்டுவந்தார்', 'மகாவிஹாரை கட்டினார்'], 'monuments': ['மிஹிந்தலை', 'ஸ்ரீ மஹா போதி', 'மகாவிஹாரை']},
    },
    {
      'id': 2, 'icon': '🤴', 'xpReward': 15,
      'en': {'name': 'King Dutugamunu', 'period': '161–137 BC', 'kingdom': 'Anuradhapura Kingdom', 'contributions': ['Unified all of Sri Lanka', 'Defeated King Elara', 'Built Ruwanwelisaya stupa'], 'monuments': ['Ruwanwelisaya', 'Mirisawetiya', 'Lovamahapaya']},
      'si': {'name': 'රජ දුටුගැමුණු', 'period': '161–137 BC', 'kingdom': 'අනුරාධපුර රාජධානිය', 'contributions': ['ශ්‍රී ලංකාව එක්සේසත් කළා', 'රජ එළාරා පරාජය කළා', 'රුවන්වැලිසෑය ඉදිකළා'], 'monuments': ['රුවන්වැලිසෑය', 'මිරිසවැටිය', 'ලෝවාමහාපාය']},
      'ta': {'name': 'மன்னன் துட்டகாமினி', 'period': '161–137 கி.மு.', 'kingdom': 'அனுராதபுர இராச்சியம்', 'contributions': ['இலங்கையை ஒன்றுபடுத்தினார்', 'மன்னன் எழாரை தோற்கடித்தார்', 'ருவான்வெலிசாயை கட்டினார்'], 'monuments': ['ருவான்வெலிசாயா', 'மிரிசாவெட்டிய', 'லோவாமஹாபாயா']},
    },
    {
      'id': 3, 'icon': '🤴', 'xpReward': 12,
      'en': {'name': 'King Mahasena', 'period': '276–303 AD', 'kingdom': 'Anuradhapura Kingdom', 'contributions': ['Built 16 major irrigation tanks', 'Constructed 2 major canals', 'Advanced agriculture across the island'], 'monuments': ['Minneriya Tank', 'Kaudulla Tank', 'Jetavanaramaya']},
      'si': {'name': 'රජ මහසෙන්', 'period': '276–303 AD', 'kingdom': 'අනුරාධපුර රාජධානිය', 'contributions': ['ප්‍රධාන වාරි ජලාශ 16ක් ඉදිකළා', 'ප්‍රධාන ඇල මාර්ග 2ක් ඉදිකළා', 'රට පුරා කෘෂිකර්මය දියුණු කළා'], 'monuments': ['මිනිරිය වැව', 'කාවුඩුල්ල වැව', 'ජේතවනාරාමය']},
      'ta': {'name': 'மன்னன் மஹாசேனன்', 'period': '276–303 கி.பி.', 'kingdom': 'அனுராதபுர இராச்சியம்', 'contributions': ['16 பெரிய நீர்த்தேக்கங்கள் கட்டினார்', '2 பெரிய கால்வாய்கள் அமைத்தார்', 'விவசாயத்தை மேம்படுத்தினார்'], 'monuments': ['மின்னேரிய தடாகம்', 'கவுடுல்ல தடாகம்', 'ஜேத்தவனாராமய']},
    },
    {
      'id': 4, 'icon': '🤴', 'xpReward': 15,
      'en': {'name': 'King Kashyapa', 'period': '477–495 AD', 'kingdom': 'Kingdom of Sigiriya', 'contributions': ['Built UNESCO Sigiriya fortress', 'Created stunning water gardens', 'Cloud Maiden frescoes masterpiece'], 'monuments': ['Sigiriya Rock Fortress', 'Sigiriya Water Gardens']},
      'si': {'name': 'රජ කස්සප', 'period': '477–495 AD', 'kingdom': 'සීගිරිය රාජධානිය', 'contributions': ['යුනෙස්කෝ සීගිරිය ඉදිකළා', 'විශිෂ්ට ජල උද්‍යාන නිර්මාණය කළා', 'අප්සරා චිත්‍ර නිර්මාණය කළා'], 'monuments': ['සීගිරිය ගල් බළකොටුව', 'සීගිරිය ජල උද්‍යාන']},
      'ta': {'name': 'மன்னன் காஷ்யபன்', 'period': '477–495 கி.பி.', 'kingdom': 'சிகிரியா இராச்சியம்', 'contributions': ['யுனெஸ்கோ சிகிரியாவை கட்டினார்', 'அழகான நீர் தோட்டங்கள் அமைத்தார்', 'மேக கன்னி ஓவியங்கள் வரைந்தார்'], 'monuments': ['சிகிரியா பாறை கோட்டை', 'சிகிரியா நீர் தோட்டங்கள்']},
    },
    {
      'id': 5, 'icon': '🤴', 'xpReward': 18,
      'en': {'name': 'King Parakramabahu I', 'period': '1153–1186 AD', 'kingdom': 'Polonnaruwa Kingdom', 'contributions': ['Unified three warring kingdoms', 'Built vast Parakrama Samudraya', 'Commissioned Gal Viharaya sculptures'], 'monuments': ['Parakrama Samudraya', 'Gal Viharaya', 'Lankathilaka']},
      'si': {'name': 'රජ පරාක්‍රමබාහු I', 'period': '1153–1186 AD', 'kingdom': 'පොළොන්නරු රාජධානිය', 'contributions': ['සටන් කළ රාජධානි 3ක් එක්සේසත් කළා', 'විශාල පරාක්‍රම සමුද්‍රය ඉදිකළා', 'ගල් විහාරය ඉදිකළා'], 'monuments': ['පරාක්‍රම සමුද්‍රය', 'ගල් විහාරය', 'ලංකාතිලකය']},
      'ta': {'name': 'மன்னன் பராக்கிரமபாஹு I', 'period': '1153–1186 கி.பி.', 'kingdom': 'பொலன்னறுவை இராச்சியம்', 'contributions': ['மூன்று இராச்சியங்களை ஒன்றுபடுத்தினார்', 'பராக்கிரம சமுத்திரம் கட்டினார்', 'கல் விஹாரை கட்டினார்'], 'monuments': ['பராக்கிரம சமுத்திரம்', 'கல் விஹாரை', 'லங்காதிலகம்']},
    },
  ];

  Map<String, dynamic> _t(Map<String, dynamic> king, String lang) =>
      (king[lang] ?? king['en']) as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final lang = p.lang;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold), onPressed: () => context.go('/home')),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            lang == 'si' ? '👑 ශ්‍රී ලංකා රජවරු' : lang == 'ta' ? '👑 இலங்கை அரசர்கள்' : '👑 Kings of Sri Lanka',
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Text(
            lang == 'si' ? 'තට්ටු කරන්න · 💬 රජු සමඟ කතා කරන්න' : lang == 'ta' ? 'தட்டவும் · 💬 மன்னனிடம் பேசுங்கள்' : 'Tap to expand · 💬 Chat with King',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ]),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _kings.length,
        itemBuilder: (_, i) => _kingCard(context, p, _kings[i], i),
      ),
    );
  }

  Widget _kingCard(BuildContext context, AppProvider p, Map<String, dynamic> king, int i) {
    final lang = p.lang;
    final t = _t(king, lang);
    final expanded = _expanded.contains(i);
    final contributions = List<String>.from(t['contributions'] ?? []);
    final monuments = List<String>.from(t['monuments'] ?? []);
    final icon = king['icon'] as String;
    final xp = king['xpReward'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        // ── Header ──
        InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          onTap: () async {
            setState(() { if (expanded) _expanded.remove(i); else _expanded.add(i); });
            if (!expanded) {
              await p.viewKing(king['id'] as int);
              await p.addXP(xp, coins: 5);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('+$xp XP · +5 🪙'),
                backgroundColor: AppColors.navy3, duration: const Duration(seconds: 2),
              ));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              // ── Emoji only, no image/avatar container ──
              Text(icon, style: const TextStyle(fontSize: 38)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(t['period'] ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text(t['kingdom'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic)),
              ])),
              Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppColors.gold),
            ]),
          ),
        ),

        // ── Expanded ──
        if (expanded) ...[
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label(lang == 'si' ? 'කළ සේවාවන්' : lang == 'ta' ? 'சேவைகள்' : 'CONTRIBUTIONS'),
              ...contributions.map((c) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('▸ ', style: TextStyle(color: AppColors.gold, fontSize: 11)),
                  Expanded(child: Text(c, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5))),
                ]),
              )),
              if (monuments.isNotEmpty) ...[
                const SizedBox(height: 10),
                _label(lang == 'si' ? 'ඉදිකළ ස්ථාන' : lang == 'ta' ? 'நினைவுச்சின்னங்கள்' : 'MONUMENTS'),
                Wrap(spacing: 6, runSpacing: 5, children: monuments.map((m) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.gold.withOpacity(0.25))),
                  child: Text(m, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                )).toList()),
              ],
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _btn(lang == 'si' ? '📖 කතාව' : lang == 'ta' ? '📖 கதை' : '📖 Story', const Color(0xFF0D1F38), const Color(0x4033A0D4), () => context.go('/king-story/${king['id']}')),
                _btn(lang == 'si' ? '🎯 ප්‍රශ්නාවලිය' : lang == 'ta' ? '🎯 வினாடி வினா' : '🎯 Quiz', const Color(0xFF0A2218), const Color(0x4027AE60), () => context.go('/quiz/kings')),
                _btn(lang == 'si' ? '💬 කතා කරන්න' : lang == 'ta' ? '💬 உரையாடுக' : '💬 Chat', const Color(0xFF1A1230), const Color(0x408E44AD), () {
                  showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: AppColors.navy2,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => _KingChatPanel(king: king, localData: t, lang: lang),
                  );
                }),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
  );

  Widget _btn(String label, Color bg, Color border, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ),
  );
}

// ══════════════════════════════════════════════════════
class _KingChatPanel extends StatefulWidget {
  final Map<String, dynamic> king;
  final Map<String, dynamic> localData;
  final String lang;
  const _KingChatPanel({required this.king, required this.localData, required this.lang});
  @override
  State<_KingChatPanel> createState() => _KingChatPanelState();
}

class _KingChatPanelState extends State<_KingChatPanel> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String, String>> _messages = [];
  final List<Map<String, String>> _history = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final name = widget.localData['name'] ?? '';
    final kingdom = widget.localData['kingdom'] ?? '';
    final greeting = widget.lang == 'si'
        ? 'මමe $name! $kingdom රාජධානියට සාදරයෙන් පිළිගනිමි!'
        : widget.lang == 'ta'
        ? 'நான் $name! $kingdom இராச்சியத்திற்கு வரவேற்கிறேன்!'
        : 'I am $name, ruler of $kingdom. Welcome, young learner!';
    _messages.add({'role': 'king', 'text': greeting});
  }

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty || _loading) return;
    _ctrl.clear();
    setState(() { _messages.add({'role': 'user', 'text': msg}); _loading = true; });
    _scroll();
    try {
      final reply = await ApiService().sendKingChat(kingId: widget.king['id'] as int, message: msg, language: widget.lang, history: _history);
      _history.addAll([{'role': 'user', 'content': msg}, {'role': 'assistant', 'content': reply}]);
      if (mounted) setState(() { _messages.add({'role': 'king', 'text': reply}); _loading = false; });
    } catch (_) {
      final c = List<String>.from(widget.localData['contributions'] ?? []);
      if (mounted) setState(() { _messages.add({'role': 'king', 'text': c.isNotEmpty ? c.first : '...'}); _loading = false; });
    }
    _scroll();
  }

  void _scroll() => Future.delayed(const Duration(milliseconds: 150), () {
    if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  @override
  Widget build(BuildContext context) {
    final icon = widget.king['icon'] as String;
    final name = widget.localData['name'] ?? '';
    final period = widget.localData['period'] ?? '';
    final quickQ = widget.lang == 'si'
        ? ['ඔබේ කතාව?', 'ඔබ ඉදිකළේ?', 'ඔබේ ජය?', 'ඔබගේ රාජ්‍යය?']
        : widget.lang == 'ta'
        ? ['உங்கள் கதை?', 'நீங்கள் கட்டியது?', 'உங்கள் வெற்றி?', 'உங்கள் இராச்சியம்?']
        : ['Your story?', 'What did you build?', 'Greatest achievement?', 'About your kingdom?'];
    final hint = widget.lang == 'si' ? 'රජතුමාට ප්‍රශ්නයක් ඇසීමට...' : widget.lang == 'ta' ? 'மன்னனிடம் கேளுங்கள்...' : 'Ask the king a question...';

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.gold.withOpacity(0.15), AppColors.gold.withOpacity(0.05)]), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 15)),
              Text('$period · AI Character', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ])),
            IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.textMuted), onPressed: () => Navigator.pop(context)),
          ]),
        ),
        // Messages
        Expanded(child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          itemCount: _messages.length + (_loading ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _messages.length) return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Text(icon, style: const TextStyle(fontSize: 20)), const SizedBox(width: 8), const Text('• • •', style: TextStyle(color: AppColors.gold, fontSize: 18, letterSpacing: 4))]));
            final msg = _messages[i];
            final isKing = msg['role'] == 'king';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(mainAxisAlignment: isKing ? MainAxisAlignment.start : MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (isKing) ...[Text(icon, style: const TextStyle(fontSize: 22)), const SizedBox(width: 6)],
                Flexible(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isKing ? AppColors.gold.withOpacity(0.1) : AppColors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isKing ? 4 : 16), bottomRight: Radius.circular(isKing ? 16 : 4)),
                    border: Border.all(color: isKing ? AppColors.gold.withOpacity(0.25) : AppColors.blue.withOpacity(0.3)),
                  ),
                  child: Text(msg['text'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.6)),
                )),
                if (!isKing) ...[const SizedBox(width: 6), const CircleAvatar(radius: 14, backgroundColor: Color(0x252980B9), child: Text('🧒', style: TextStyle(fontSize: 14)))],
              ]),
            );
          },
        )),
        // Quick questions
        SizedBox(height: 38, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: quickQ.map((q) => GestureDetector(
          onTap: () { _ctrl.text = q; _send(); },
          child: Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))), child: Text(q, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600))),
        )).toList())),
        const SizedBox(height: 8),
        // Input
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).viewInsets.bottom + 12),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12), filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              onSubmitted: (_) => _send(),
            )),
            const SizedBox(width: 8),
            GestureDetector(onTap: _send, child: Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.gold, AppColors.goldLight])), child: const Icon(Icons.send_rounded, color: AppColors.navy, size: 18))),
          ]),
        ),
      ]),
    );
  }
}
