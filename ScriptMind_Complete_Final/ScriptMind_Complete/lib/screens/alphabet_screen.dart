import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../constants/app_constants.dart';

class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});
  @override State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen>
    with SingleTickerProviderStateMixin {
  String _corpus   = 'Latin Uppercase';
  int    _selected = 0;
  bool   _speaking = false;

  late AnimationController _bounce;
  late Animation<double>   _bounceAnim;
  final AudioPlayer _player = AudioPlayer();

  List<String> get letters => AppCorpora.letters[_corpus]!;
  Color        get color   => AppCorpora.corpusColors[_corpus]!;

  // ── MP3 asset path helpers ────────────────────────────────────────────────

  static String _englishAsset(String letter) =>
      'assets/sounds/english/${letter.toUpperCase()}.mp3';

  static const _sinhalaHex = {
    'අ':'0d85','ආ':'0d86','ඇ':'0d87','ඈ':'0d88','ඉ':'0d89','ඊ':'0d8a',
    'උ':'0d8b','ඌ':'0d8c','එ':'0d91','ඒ':'0d92','ඔ':'0d94','ඕ':'0d95',
    'ක':'0d9a','ග':'0d9c','ච':'0da0','ජ':'0da2','ට':'0da7','ඩ':'0da9',
    'ත':'0dad','ද':'0daf','න':'0db1','ප':'0db4','බ':'0db6','ම':'0db8',
    'ය':'0dba','ර':'0dbb','ල':'0dbd','ව':'0dc0','ස':'0dc3','හ':'0dc4',
  };
  static String? _sinhalaAsset(String letter) {
    final hex = _sinhalaHex[letter];
    return hex != null ? 'assets/sounds/sinhala/si_$hex.mp3' : null;
  }

  static const _tamilHex = {
    'அ':'0b85','ஆ':'0b86','இ':'0b87','ஈ':'0b88','உ':'0b89','ஊ':'0b8a',
    'எ':'0b8e','ஏ':'0b8f','க':'0b95','த':'0ba4','ம':'0bae','ன':'0ba9',
    'ப':'0baa','வ':'0bb5','ர':'0bb0','ல':'0bb2','ண':'0ba3','ழ':'0bb4',
  };
  static String? _tamilAsset(String letter) {
    final hex = _tamilHex[letter];
    return hex != null ? 'assets/sounds/tamil/ta_$hex.mp3' : null;
  }

  // ── Audio playback ────────────────────────────────────────────────────────
  Future<void> _playAsset(String? assetPath) async {
    if (assetPath == null) return;
    try {
      setState(() => _speaking = true);
      await _player.stop();
      await _player.setAsset(assetPath);
      await _player.play();
      if (mounted) setState(() => _speaking = false);
    } catch (_) {
      if (mounted) setState(() => _speaking = false);
    }
  }

  Future<void> _playCurrentLetter() async {
    final letter = letters[_selected];
    if (_corpus == 'Latin Uppercase' || _corpus == 'Latin Lowercase') {
      await _playAsset(_englishAsset(letter));
    } else if (_corpus == 'Sinhala') {
      await _playAsset(_sinhalaAsset(letter));
    } else {
      await _playAsset(_tamilAsset(letter));
    }
  }

  // ── Init & dispose ────────────────────────────────────────────────────────
  @override
void initState() {
  super.initState();
  _bounce = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800))
    ..repeat(reverse: true);
  _bounceAnim = Tween(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));

  // ── Audio test ──────────────────────────────────
  Future.delayed(const Duration(seconds: 2), () {
    _playAsset('assets/sounds/english/A.mp3');
  });
}

  @override
  void dispose() {
    _bounce.dispose();
    _player.dispose();
    super.dispose();
  }

  void _select(int i) {
    HapticFeedback.selectionClick();
    setState(() { _selected = i; _speaking = false; });
    _player.stop();
    _bounce.forward(from: 0);
  }

  // Phonetic label for Sinhala/Tamil letters shown under circle
  static const _sinhalaPhonetics = {
    'අ':'a','ආ':'aa','ඇ':'ae','ඈ':'aee','ඉ':'i','ඊ':'ee','උ':'u','ඌ':'oo',
    'එ':'e','ඒ':'ay','ඔ':'o','ඕ':'oh','ක':'ka','ග':'ga','ච':'cha','ජ':'ja',
    'ට':'ta','ඩ':'da','ත':'tha','ද':'dha','න':'na','ප':'pa','බ':'ba','ම':'ma',
    'ය':'ya','ර':'ra','ල':'la','ව':'va','ස':'sa','හ':'ha',
  };
  static const _tamilPhonetics = {
    'அ':'a','ஆ':'aa','இ':'i','ஈ':'ee','உ':'u','ஊ':'oo','எ':'e','ஏ':'ay',
    'க':'ka','த':'tha','ம':'ma','ன':'na','ப':'pa','வ':'va','ர':'ra',
    'ல':'la','ண':'na','ழ':'zha',
  };

  String get _phoneticLabel {
    final l = letters[_selected];
    if (_corpus == 'Sinhala') return _sinhalaPhonetics[l] ?? '';
    if (_corpus == 'Tamil')   return _tamilPhonetics[l]   ?? '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final letter = letters[_selected];
    return Scaffold(
      appBar: AppBar(title: const Text('🔤 Alphabet'), backgroundColor: color),
      backgroundColor: AppColors.background,
      body: Column(children: [

        // ── Language tabs ─────────────────────────────────────────────────────
        Container(
          color: color,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(children: AppCorpora.letters.keys.map<Widget>((c) {
            return Expanded(child: GestureDetector(
              onTap: () => setState(() {
                _corpus = c; _selected = 0; _speaking = false; _player.stop();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _corpus == c ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Text(AppCorpora.corpusEmojis[c]!, style: const TextStyle(fontSize: 16)),
                  Text(AppCorpora.corpusNames[c]!,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: _corpus == c ? AppCorpora.corpusColors[c]! : Colors.white),
                    textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ));
          }).toList()),
        ),

        // ── Big letter + speaker ──────────────────────────────────────────────
        Expanded(flex: 3, child: AnimatedBuilder(
          animation: _bounceAnim,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _bounceAnim.value),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [

              Stack(alignment: Alignment.center, children: [
                GestureDetector(
                  onTap: _playCurrentLetter,
                  child: Container(
                    width: 170, height: 170,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1), shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.4), width: 3),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 20, spreadRadius: 4)]),
                    child: Center(child: Text(letter,
                      style: TextStyle(fontSize: 90, color: color, fontWeight: FontWeight.w900))),
                  ),
                ),
                // Speaker button
                Positioned(top: 6, right: 6,
                  child: GestureDetector(
                    onTap: _playCurrentLetter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _speaking ? color : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)]),
                      child: Icon(
                        _speaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                        color: _speaking ? Colors.white : color, size: 20),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 8),

              // Phonetic hint label
              if (_phoneticLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3))),
                  child: Text('🔊 "$_phoneticLabel"',
                    style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
                ),

              const SizedBox(height: 12),

              // ── 3 Language pronunciation buttons ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [

                  Expanded(child: _PronounceBtn(
                    flag: '🔤', label: 'English', color: AppColors.english,
                    onTap: () => _playAsset(_englishAsset(letter)),
                  )),
                  const SizedBox(width: 8),

                  Expanded(child: _PronounceBtn(
                    flag: '🇱🇰', label: 'සිංහල', color: AppColors.sinhala,
                    onTap: () {
                      // Play current letter if Sinhala corpus, else play 'අ' as demo
                      final asset = _corpus == 'Sinhala'
                          ? _sinhalaAsset(letter)
                          : _sinhalaAsset('අ');
                      _playAsset(asset);
                    },
                  )),
                  const SizedBox(width: 8),

                  Expanded(child: _PronounceBtn(
                    flag: '🌺', label: 'தமிழ்', color: AppColors.tamil,
                    onTap: () {
                      final asset = _corpus == 'Tamil'
                          ? _tamilAsset(letter)
                          : _tamilAsset('அ');
                      _playAsset(asset);
                    },
                  )),

                ]),
              ),

              const SizedBox(height: 14),

              // Navigation arrows
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded, color: color), iconSize: 32,
                  onPressed: _selected > 0 ? () => _select(_selected - 1) : null),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('${_selected + 1} / ${letters.length}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14))),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded, color: color), iconSize: 32,
                  onPressed: _selected < letters.length - 1 ? () => _select(_selected + 1) : null),
              ]),
            ])),
          ),
        )),

        // ── Practice button ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: color, minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.edit_rounded),
            label: Text('Practice "$letter"'),
            onPressed: () => Navigator.pushNamed(context, '/handwriting',
                arguments: {'corpus': _corpus, 'letterIdx': _selected}),
          ),
        ),

        // ── Mini letter grid ──────────────────────────────────────────────────
        SizedBox(
          height: 100,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: letters.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _select(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: i == _selected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: i == _selected ? color : Colors.transparent)),
                child: Center(child: Text(letters[i],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: i == _selected ? Colors.white : color))),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Pronunciation button ──────────────────────────────────────────────────────
class _PronounceBtn extends StatelessWidget {
  final String flag, label;
  final Color color;
  final VoidCallback onTap;
  const _PronounceBtn({required this.flag, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(flag, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Icon(Icons.volume_up_rounded, size: 14, color: color),
      ]),
    ),
  );
}
