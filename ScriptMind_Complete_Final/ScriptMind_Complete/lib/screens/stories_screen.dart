import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = AppStories.stories;
    return Scaffold(
      appBar: AppBar(title: const Text('📖 Stories'), backgroundColor: AppColors.secondary),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stories.length,
        itemBuilder: (_, i) {
          final s = stories[i];
          final col = Color(s['color'] as int);
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => StoryReaderScreen(story: s))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: col.withOpacity(0.18),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.12), shape: BoxShape.circle),
                  child: Center(child: Text(s['emoji'] as String,
                      style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['titleEn'] as String, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: col)),
                  Text(s['titleSi'] as String,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.lightbulb_outline, size: 13, color: col),
                    const SizedBox(width: 4),
                    Expanded(child: Text(s['moral'] as String,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ])),
                Icon(Icons.arrow_forward_ios, color: col, size: 14),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── Story Reader ──────────────────────────────────────────────────────────────
class StoryReaderScreen extends StatefulWidget {
  final Map<String, dynamic> story;
  const StoryReaderScreen({super.key, required this.story});
  @override State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen>
    with SingleTickerProviderStateMixin {
  int    _page = 0;
  String _lang = 'en';
  late AnimationController _pageCtrl;
  late Animation<double>   _pageFade;

  List<dynamic> get pages => widget.story['pages'] as List;
  Color get color => Color(widget.story['color'] as int);

  @override
  void initState() {
    super.initState();
    _pageCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _pageFade = Tween(begin: 0.0, end: 1.0).animate(_pageCtrl);
    _pageCtrl.forward();
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _goPage(int p) {
    _pageCtrl.reverse().then((_) {
      setState(() => _page = p);
      _pageCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = pages[_page] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story['titleEn'] as String),
        backgroundColor: color,
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: Column(children: [
        // Language selector
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _LangBtn('EN', 'en', _lang, () => setState(() => _lang = 'en'), color),
            const SizedBox(width: 8),
            _LangBtn('සිං', 'si', _lang, () => setState(() => _lang = 'si'), color),
            const SizedBox(width: 8),
            _LangBtn('த', 'ta', _lang, () => setState(() => _lang = 'ta'), color),
          ]),
        ),

        // Page content
        Expanded(
          child: FadeTransition(
            opacity: _pageFade,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: color.withOpacity(0.15),
                    blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(p['emoji'] as String, style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                Text(p[_lang] as String? ?? p['en'] as String,
                    style: const TextStyle(fontSize: 21, height: 1.6,
                        color: Color(0xFF2D2B55), fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('${_page + 1} / ${pages.length}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ]),
            ),
          ),
        ),

        // Dots
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
            pages.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == _page ? 20 : 8, height: 8,
              decoration: BoxDecoration(
                color: i == _page ? color : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )),
        ),

        // Navigation
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(children: [
            if (_page > 0) ...[
              Expanded(child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _goPage(_page - 1),
                child: Text('← Back', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _page < pages.length - 1
                    ? () => _goPage(_page + 1)
                    : () {
                        showDialog(context: context, builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('🎉 The End!'),
                          content: Text('💡 Moral: ${widget.story['moral']}'),
                          actions: [
                            TextButton(onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }, child: const Text('Done')),
                          ],
                        ));
                      },
                child: Text(_page < pages.length - 1 ? 'Next →' : 'Finish 🎉',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label, code, selected;
  final VoidCallback onTap;
  final Color color;
  const _LangBtn(this.label, this.code, this.selected, this.onTap, this.color);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: code == selected ? color : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(
        color: code == selected ? Colors.white : Colors.grey,
        fontWeight: FontWeight.w800, fontSize: 14)),
    ),
  );
}
