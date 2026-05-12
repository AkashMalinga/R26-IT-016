// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/api_service.dart';
// import '../services/stroke_analyzer.dart';
// import '../constants/app_constants.dart';

// // ═══════════════════════════════════════════════════════════════════════════════
// //  HANDWRITING SCREEN
// //  Research features:
// //   • Bezier-smooth stroke rendering
// //   • Guide lines (baseline, midline, topline)
// //   • Real-time boundary detection → vibration warning
// //   • After submission: vibration pattern based on result
// //   • AI score + contextual text feedback
// //   • Confetti on excellent (≥85)
// // ═══════════════════════════════════════════════════════════════════════════════

// class HandwritingScreen extends StatefulWidget {
//   const HandwritingScreen({super.key});
//   @override State<HandwritingScreen> createState() => _HandwritingScreenState();
// }

// class _HandwritingScreenState extends State<HandwritingScreen>
//     with TickerProviderStateMixin {

//   // ── Data ────────────────────────────────────────────────────────────────────
//   String _corpus = 'Latin Uppercase';
//   int    _letterIdx = 0;
//   final  List<List<StrokePoint>> _strokes = [];
//   List<StrokePoint> _current = [];
//   bool   _submitting = false;
//   StrokeAnalysisResult? _result;

//   // ── Animation ────────────────────────────────────────────────────────────────
//   late AnimationController _feedbackCtrl;
//   late Animation<double>   _feedbackAnim;
//   late AnimationController _shakeCtrl;
//   late Animation<Offset>   _shakeAnim;

//   // Canvas key for size measurement
//   final _canvasKey = GlobalKey();
//   Size _canvasSize = const Size(300, 300);

//   List<String> get _letters => AppCorpora.letters[_corpus]!;
//   String       get _letter  => _letters[_letterIdx];
//   Color        get _color   => AppCorpora.corpusColors[_corpus]!;

//   @override
//   void initState() {
//     super.initState();
//     _feedbackCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
//     _feedbackAnim = Tween(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _feedbackCtrl, curve: Curves.elasticOut));
//     _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
//     _shakeAnim = Tween(begin: Offset.zero, end: const Offset(0.02, 0))
//         .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final args = ModalRoute.of(context)?.settings.arguments as Map?;
//     if (args?['corpus'] != null) {
//       setState(() { _corpus = args!['corpus']; _letterIdx = 0; });
//     }
//   }

//   @override
//   void dispose() { _feedbackCtrl.dispose(); _shakeCtrl.dispose(); super.dispose(); }

//   // ── Stroke handlers ──────────────────────────────────────────────────────────
//   void _onPanStart(DragStartDetails d) {
//     HapticFeedbackService.penDown();
//     final p = d.localPosition;
//     _current = [StrokePoint(p.dx, p.dy, DateTime.now().millisecondsSinceEpoch)];
//     setState(() {});
//   }

//   void _onPanUpdate(DragUpdateDetails d) {
//     final p = d.localPosition;

//     // Boundary check → vibrate if going out of canvas
//     final pad = 8.0;
//     if (p.dx < pad || p.dx > _canvasSize.width - pad ||
//         p.dy < pad || p.dy > _canvasSize.height - pad) {
//       HapticFeedbackService.outOfBounds();
//     }

//     setState(() {
//       _current.add(StrokePoint(
//           p.dx.clamp(0, _canvasSize.width),
//           p.dy.clamp(0, _canvasSize.height),
//           DateTime.now().millisecondsSinceEpoch));
//     });
//   }

//   void _onPanEnd(DragEndDetails _) {
//     setState(() {
//       if (_current.isNotEmpty) _strokes.add(List.from(_current));
//       _current = [];
//     });
//   }

//   void _clear() {
//     setState(() { _strokes.clear(); _current = []; _result = null; });
//     _feedbackCtrl.reset();
//   }

//   void _nextLetter() {
//     setState(() {
//       _letterIdx = (_letterIdx + 1) % _letters.length;
//       _clear();
//     });
//   }

//   void _prevLetter() {
//     setState(() {
//       _letterIdx = (_letterIdx - 1 + _letters.length) % _letters.length;
//       _clear();
//     });
//   }

//   Future<void> _submit() async {
//     if (_strokes.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Please write the letter first! ✏️'),
//         behavior: SnackBarBehavior.floating,
//       ));
//       return;
//     }

//     setState(() { _submitting = true; _result = null; });
//     _feedbackCtrl.reset();

//     // Local ML analysis
//     final localResult = StrokeAnalyzer.analyze(
//       strokes: _strokes, corpus: _corpus,
//       letter: _letter, canvasSize: _canvasSize,
//     );

//     // Vibration feedback based on result ← KEY FEATURE
//     if (localResult.passed) {
//       if (localResult.score >= 85) {
//         await HapticFeedbackService.excellent();
//       } else {
//         await HapticFeedbackService.correctStroke();
//       }
//     } else {
//       // Wrong/low score → alert child with distinctive buzz
//       await HapticFeedbackService.wrongStroke();
//       _shakeCtrl.forward(from: 0).then((_) => _shakeCtrl.reverse());
//     }

//     // Try backend submission (non-blocking)
//     try {
//       final api = context.read<ApiService>();
//       final strokeData = _strokes.map((s) => s.map((p) => p.toJson()).toList()).toList();
//       await api.submitAttempt({
//         'corpus': _corpus, 'letter': _letter,
//         'strokes': _strokes.length, 'strokeData': strokeData,
//         'score': localResult.score.round(),
//       });
//     } catch (_) { /* offline mode ok */ }

//     setState(() { _submitting = false; _result = localResult; });
//     _feedbackCtrl.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('✏️ Write Letters'),
//         backgroundColor: _color,
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.language, color: Colors.white),
//             onSelected: (v) => setState(() {
//               _corpus = v; _letterIdx = 0; _clear();
//             }),
//             itemBuilder: (_) => AppCorpora.letters.keys.map((c) =>
//               PopupMenuItem(value: c,
//                 child: Row(children: [
//                   Text(AppCorpora.corpusEmojis[c]!),
//                   const SizedBox(width: 8),
//                   Text(AppCorpora.corpusNames[c]!),
//                 ]))).toList(),
//           ),
//         ],
//       ),
//       body: Column(children: [
//         // ── Letter navigation bar ─────────────────────────────────────────────
//         Container(
//           color: _color,
//           padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
//                   onPressed: _prevLetter),
//               Column(children: [
//                 Text(AppCorpora.corpusNames[_corpus]!,
//                     style: const TextStyle(color: Colors.white70, fontSize: 11)),
//                 SlideTransition(
//                   position: _shakeAnim,
//                   child: Text(_letter, style: const TextStyle(
//                       color: Colors.white, fontSize: 72,
//                       fontWeight: FontWeight.w900, height: 1.1)),
//                 ),
//                 Text('${_letterIdx + 1} / ${_letters.length}',
//                     style: const TextStyle(color: Colors.white60, fontSize: 11)),
//               ]),
//               IconButton(icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
//                   onPressed: _nextLetter),
//             ],
//           ),
//         ),

//         // ── Drawing canvas ────────────────────────────────────────────────────
//         Expanded(
//           child: LayoutBuilder(builder: (ctx, box) {
//             _canvasSize = Size(box.maxWidth, box.maxHeight);
//             return Stack(children: [
//               // Background
//               Container(color: Colors.white),
//               // Guide lines painter
//               CustomPaint(painter: _GuideLinesPainter(color: _color),
//                   child: const SizedBox.expand()),
//               // Ghost letter (tracing guide)
//               Center(child: Text(_letter, style: TextStyle(
//                   fontSize: 180, color: _color.withOpacity(0.05),
//                   fontWeight: FontWeight.w900))),
//               // Stroke canvas
//               GestureDetector(
//                 key: _canvasKey,
//                 onPanStart: _onPanStart,
//                 onPanUpdate: _onPanUpdate,
//                 onPanEnd: _onPanEnd,
//                 child: CustomPaint(
//                   painter: _StrokePainter(
//                     strokes: [..._strokes, if (_current.isNotEmpty) _current],
//                     color: _color,
//                   ),
//                   child: const SizedBox.expand(),
//                 ),
//               ),
//               // Stroke count badge
//               Positioned(top: 10, right: 10,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _color.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text('Strokes: ${_strokes.length}',
//                       style: TextStyle(fontSize: 12, color: _color,
//                           fontWeight: FontWeight.w700)),
//                 ),
//               ),
//             ]);
//           }),
//         ),

//         // ── Feedback panel ────────────────────────────────────────────────────
//         if (_result != null)
//           ScaleTransition(
//             scale: _feedbackAnim,
//             child: _FeedbackPanel(result: _result!, color: _color),
//           ),

//         // ── Action buttons ────────────────────────────────────────────────────
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
//           child: Row(children: [
//             // Clear
//             _ActionBtn(icon: Icons.refresh_rounded, label: 'Clear',
//                 color: Colors.grey.shade600, onTap: _clear, flex: 1),
//             const SizedBox(width: 10),
//             // Check
//             _ActionBtn(
//               icon: _submitting ? null : Icons.check_circle_outline,
//               label: _submitting ? 'Checking...' : 'Check ✓',
//               color: _color, onTap: _submitting ? null : _submit, flex: 2,
//               isLoading: _submitting,
//             ),
//             const SizedBox(width: 10),
//             // Next
//             _ActionBtn(icon: Icons.skip_next_rounded, label: 'Next',
//                 color: AppColors.success, onTap: _nextLetter, flex: 1),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// // ── Painters ──────────────────────────────────────────────────────────────────

// class _GuideLinesPainter extends CustomPainter {
//   final Color color;
//   const _GuideLinesPainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color.withOpacity(0.12)
//       ..strokeWidth = 1;
//     // Baseline, midline, topline
//     for (final ratio in [0.25, 0.5, 0.75]) {
//       final y = size.height * ratio;
//       // Dashed line
//       double x = 0;
//       while (x < size.width) {
//         canvas.drawLine(Offset(x, y), Offset(x + 8, y), paint);
//         x += 16;
//       }
//     }
//   }

//   @override bool shouldRepaint(_) => false;
// }

// class _StrokePainter extends CustomPainter {
//   final List<List<StrokePoint>> strokes;
//   final Color color;
//   const _StrokePainter({required this.strokes, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color.withOpacity(0.88)
//       ..strokeWidth = 5.5
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round
//       ..style = PaintingStyle.stroke;

//     for (final stroke in strokes) {
//       if (stroke.isEmpty) continue;
//       final path = Path();
//       path.moveTo(stroke.first.x, stroke.first.y);
//       for (int i = 1; i < stroke.length; i++) {
//         if (i < stroke.length - 1) {
//           final mx = (stroke[i].x + stroke[i+1].x) / 2;
//           final my = (stroke[i].y + stroke[i+1].y) / 2;
//           path.quadraticBezierTo(stroke[i].x, stroke[i].y, mx, my);
//         } else {
//           path.lineTo(stroke[i].x, stroke[i].y);
//         }
//       }
//       canvas.drawPath(path, paint);
//       // Dot at start of each stroke
//       canvas.drawCircle(Offset(stroke.first.x, stroke.first.y),
//           3, paint..style = PaintingStyle.fill);
//       paint.style = PaintingStyle.stroke;
//     }
//   }

//   @override bool shouldRepaint(_StrokePainter old) => old.strokes != strokes;
// }

// // ── Feedback Panel ────────────────────────────────────────────────────────────
// class _FeedbackPanel extends StatelessWidget {
//   final StrokeAnalysisResult result;
//   final Color color;
//   const _FeedbackPanel({required this.result, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     final passed = result.passed;
//     final score  = result.score;
//     final bgColor = passed
//         ? (score >= 85 ? const Color(0xFFE8F5E9) : const Color(0xFFF1F8E9))
//         : const Color(0xFFFFF3E0);
//     final bdColor = passed ? AppColors.success : AppColors.warning;
//     final emoji   = score >= 85 ? '🌟' : score >= 60 ? '😊' : '💪';

//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: bdColor.withOpacity(0.5), width: 1.5),
//       ),
//       child: Row(children: [
//         Text(emoji, style: const TextStyle(fontSize: 30)),
//         const SizedBox(width: 12),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             Text('Score: ${score.toStringAsFixed(0)}%',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
//                     color: passed ? AppColors.success : AppColors.warning)),
//             const SizedBox(width: 8),
//             // Score bar
//             Expanded(child: ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: LinearProgressIndicator(
//                 value: score / 100,
//                 backgroundColor: Colors.grey.shade200,
//                 color: passed ? AppColors.success : AppColors.warning,
//                 minHeight: 6,
//               ),
//             )),
//           ]),
//           const SizedBox(height: 4),
//           Text(result.feedback,
//               style: const TextStyle(fontSize: 12, color: Colors.black87)),
//         ])),
//       ]),
//     );
//   }
// }

// class _ActionBtn extends StatelessWidget {
//   final IconData? icon;
//   final String label;
//   final Color color;
//   final VoidCallback? onTap;
//   final int flex;
//   final bool isLoading;
//   const _ActionBtn({required this.label, required this.color,
//       required this.onTap, required this.flex, this.icon, this.isLoading = false});

//   @override
//   Widget build(BuildContext context) => Expanded(
//     flex: flex,
//     child: GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         height: 52,
//         decoration: BoxDecoration(
//           color: onTap == null ? Colors.grey.shade200 : color.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: onTap == null ? Colors.grey.shade300 : color, width: 1.5),
//         ),
//         child: Center(child: isLoading
//             ? SizedBox(width: 20, height: 20,
//                 child: CircularProgressIndicator(color: color, strokeWidth: 2))
//             : Row(mainAxisSize: MainAxisSize.min, children: [
//                 if (icon != null) ...[
//                   Icon(icon, color: color, size: 18),
//                   const SizedBox(width: 4),
//                 ],
//                 Text(label, style: TextStyle(color: color,
//                     fontWeight: FontWeight.w700, fontSize: 13)),
//               ])),
//       ),
//     ),
//   );
// }


import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/stroke_analyzer.dart';
import '../constants/app_constants.dart';

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});
  @override State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen>
    with TickerProviderStateMixin {

  String _corpus    = 'Latin Uppercase';
  int    _letterIdx = 0;
  final  List<List<StrokePoint>> _strokes = [];
  List<StrokePoint> _current = [];
  bool   _submitting  = false;
  bool   _showGuide   = false;
  bool   _isAnimating = false;
  StrokeAnalysisResult? _result;

  late AnimationController _feedbackCtrl;
  late Animation<double>   _feedbackAnim;
  late AnimationController _shakeCtrl;
  late Animation<Offset>   _shakeAnim;
  late AnimationController _traceCtrl;
  late AnimationController _dotCtrl;
  late Animation<double>   _dotAnim;

  final _canvasKey  = GlobalKey();
  Size  _canvasSize = const Size(300, 300);

  List<String> get _letters => AppCorpora.letters[_corpus]!;
  String       get _letter  => _letters[_letterIdx];
  Color        get _color   => AppCorpora.corpusColors[_corpus]!;

  // ── Stroke guides (normalized 0..1) ──────────────────────────────────────────
  static const Map<String, List<List<Offset>>> _strokeGuides = {
    'A': [[Offset(0.5,0.1),Offset(0.15,0.9)],[Offset(0.5,0.1),Offset(0.85,0.9)],[Offset(0.25,0.55),Offset(0.75,0.55)]],
    'B': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.25,0.1),Offset(0.65,0.2),Offset(0.7,0.35),Offset(0.65,0.48),Offset(0.25,0.5)],[Offset(0.25,0.5),Offset(0.7,0.6),Offset(0.75,0.72),Offset(0.7,0.85),Offset(0.25,0.9)]],
    'C': [[Offset(0.8,0.25),Offset(0.5,0.1),Offset(0.2,0.3),Offset(0.15,0.5),Offset(0.2,0.7),Offset(0.5,0.9),Offset(0.8,0.75)]],
    'D': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.25,0.1),Offset(0.6,0.2),Offset(0.78,0.4),Offset(0.78,0.6),Offset(0.6,0.8),Offset(0.25,0.9)]],
    'E': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.25,0.1),Offset(0.75,0.1)],[Offset(0.25,0.5),Offset(0.65,0.5)],[Offset(0.25,0.9),Offset(0.75,0.9)]],
    'F': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.25,0.1),Offset(0.75,0.1)],[Offset(0.25,0.5),Offset(0.65,0.5)]],
    'G': [[Offset(0.8,0.25),Offset(0.5,0.1),Offset(0.2,0.3),Offset(0.15,0.5),Offset(0.2,0.7),Offset(0.5,0.9),Offset(0.8,0.75),Offset(0.8,0.5),Offset(0.55,0.5)]],
    'H': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.75,0.1),Offset(0.75,0.9)],[Offset(0.25,0.5),Offset(0.75,0.5)]],
    'I': [[Offset(0.3,0.1),Offset(0.7,0.1)],[Offset(0.5,0.1),Offset(0.5,0.9)],[Offset(0.3,0.9),Offset(0.7,0.9)]],
    'J': [[Offset(0.3,0.1),Offset(0.7,0.1)],[Offset(0.6,0.1),Offset(0.6,0.75),Offset(0.45,0.9),Offset(0.3,0.8)]],
    'K': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.75,0.1),Offset(0.25,0.5)],[Offset(0.35,0.55),Offset(0.75,0.9)]],
    'L': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.25,0.9),Offset(0.75,0.9)]],
    'M': [[Offset(0.15,0.9),Offset(0.15,0.1)],[Offset(0.15,0.1),Offset(0.5,0.55)],[Offset(0.5,0.55),Offset(0.85,0.1)],[Offset(0.85,0.1),Offset(0.85,0.9)]],
    'N': [[Offset(0.2,0.9),Offset(0.2,0.1)],[Offset(0.2,0.1),Offset(0.8,0.9)],[Offset(0.8,0.9),Offset(0.8,0.1)]],
    'O': [[Offset(0.5,0.1),Offset(0.2,0.3),Offset(0.15,0.5),Offset(0.2,0.7),Offset(0.5,0.9),Offset(0.8,0.7),Offset(0.85,0.5),Offset(0.8,0.3),Offset(0.5,0.1)]],
    'P': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.25,0.1),Offset(0.65,0.2),Offset(0.72,0.35),Offset(0.65,0.5),Offset(0.25,0.5)]],
    'Q': [[Offset(0.5,0.1),Offset(0.2,0.3),Offset(0.15,0.5),Offset(0.2,0.7),Offset(0.5,0.9),Offset(0.8,0.7),Offset(0.85,0.5),Offset(0.8,0.3),Offset(0.5,0.1)],[Offset(0.6,0.7),Offset(0.82,0.92)]],
    'R': [[Offset(0.25,0.1),Offset(0.25,0.9)],[Offset(0.25,0.1),Offset(0.65,0.2),Offset(0.72,0.35),Offset(0.65,0.5),Offset(0.25,0.5)],[Offset(0.4,0.5),Offset(0.75,0.9)]],
    'S': [[Offset(0.75,0.2),Offset(0.5,0.1),Offset(0.25,0.2),Offset(0.25,0.4),Offset(0.5,0.5),Offset(0.75,0.6),Offset(0.75,0.8),Offset(0.5,0.9),Offset(0.25,0.8)]],
    'T': [[Offset(0.2,0.1),Offset(0.8,0.1)],[Offset(0.5,0.1),Offset(0.5,0.9)]],
    'U': [[Offset(0.2,0.1),Offset(0.2,0.75),Offset(0.35,0.9),Offset(0.65,0.9),Offset(0.8,0.75),Offset(0.8,0.1)]],
    'V': [[Offset(0.2,0.1),Offset(0.5,0.9)],[Offset(0.5,0.9),Offset(0.8,0.1)]],
    'W': [[Offset(0.1,0.1),Offset(0.28,0.9)],[Offset(0.28,0.9),Offset(0.5,0.5)],[Offset(0.5,0.5),Offset(0.72,0.9)],[Offset(0.72,0.9),Offset(0.9,0.1)]],
    'X': [[Offset(0.2,0.1),Offset(0.8,0.9)],[Offset(0.8,0.1),Offset(0.2,0.9)]],
    'Y': [[Offset(0.2,0.1),Offset(0.5,0.5)],[Offset(0.8,0.1),Offset(0.5,0.5)],[Offset(0.5,0.5),Offset(0.5,0.9)]],
    'Z': [[Offset(0.2,0.1),Offset(0.8,0.1)],[Offset(0.8,0.1),Offset(0.2,0.9)],[Offset(0.2,0.9),Offset(0.8,0.9)]],
    'a': [[Offset(0.7,0.35),Offset(0.5,0.25),Offset(0.3,0.35),Offset(0.25,0.5),Offset(0.3,0.65),Offset(0.5,0.75),Offset(0.7,0.65),Offset(0.7,0.35)],[Offset(0.7,0.35),Offset(0.7,0.75)]],
    'b': [[Offset(0.3,0.1),Offset(0.3,0.9)],[Offset(0.3,0.55),Offset(0.6,0.42),Offset(0.75,0.55),Offset(0.75,0.65),Offset(0.6,0.78),Offset(0.3,0.78)]],
    'c': [[Offset(0.72,0.38),Offset(0.5,0.25),Offset(0.28,0.38),Offset(0.24,0.55),Offset(0.28,0.68),Offset(0.5,0.78),Offset(0.72,0.68)]],
    'd': [[Offset(0.7,0.1),Offset(0.7,0.9)],[Offset(0.7,0.55),Offset(0.45,0.42),Offset(0.28,0.5),Offset(0.25,0.62),Offset(0.32,0.75),Offset(0.5,0.8),Offset(0.7,0.75)]],
    'e': [[Offset(0.25,0.52),Offset(0.75,0.52),Offset(0.75,0.4),Offset(0.55,0.28),Offset(0.32,0.38),Offset(0.25,0.52),Offset(0.28,0.66),Offset(0.5,0.78),Offset(0.72,0.68)]],
    'i': [[Offset(0.5,0.32),Offset(0.5,0.78)],[Offset(0.5,0.18),Offset(0.5,0.22)]],
    'l': [[Offset(0.5,0.1),Offset(0.5,0.9)]],
    'o': [[Offset(0.5,0.28),Offset(0.28,0.38),Offset(0.22,0.52),Offset(0.28,0.66),Offset(0.5,0.78),Offset(0.72,0.66),Offset(0.78,0.52),Offset(0.72,0.38),Offset(0.5,0.28)]],
    't': [[Offset(0.5,0.15),Offset(0.5,0.88)],[Offset(0.28,0.38),Offset(0.72,0.38)]],
    'v': [[Offset(0.2,0.3),Offset(0.5,0.82)],[Offset(0.5,0.82),Offset(0.8,0.3)]],
    'x': [[Offset(0.25,0.3),Offset(0.75,0.8)],[Offset(0.75,0.3),Offset(0.25,0.8)]],

    // ── Sinhala Vowels ────────────────────────────────────────────────────────
    'අ': [[Offset(0.5,0.15),Offset(0.5,0.5),Offset(0.35,0.65),Offset(0.25,0.55),Offset(0.3,0.42),Offset(0.5,0.5)],[Offset(0.5,0.5),Offset(0.65,0.75),Offset(0.5,0.88),Offset(0.35,0.75)]],
    'ආ': [[Offset(0.5,0.15),Offset(0.5,0.5),Offset(0.35,0.65),Offset(0.25,0.55),Offset(0.3,0.42),Offset(0.5,0.5)],[Offset(0.5,0.5),Offset(0.65,0.75),Offset(0.5,0.88),Offset(0.35,0.75)],[Offset(0.72,0.15),Offset(0.72,0.88)]],
    'ඇ': [[Offset(0.45,0.15),Offset(0.45,0.5),Offset(0.3,0.65),Offset(0.2,0.55),Offset(0.25,0.42),Offset(0.45,0.5)],[Offset(0.45,0.5),Offset(0.6,0.75),Offset(0.45,0.88),Offset(0.3,0.75)],[Offset(0.72,0.25),Offset(0.65,0.38),Offset(0.72,0.5),Offset(0.8,0.38)]],
    'ඈ': [[Offset(0.38,0.15),Offset(0.38,0.5),Offset(0.25,0.65),Offset(0.15,0.55),Offset(0.2,0.42),Offset(0.38,0.5)],[Offset(0.38,0.5),Offset(0.52,0.75),Offset(0.38,0.88),Offset(0.25,0.75)],[Offset(0.65,0.25),Offset(0.58,0.38),Offset(0.65,0.5),Offset(0.73,0.38)],[Offset(0.8,0.15),Offset(0.8,0.88)]],
    'ඉ': [[Offset(0.5,0.15),Offset(0.38,0.35),Offset(0.3,0.55),Offset(0.38,0.72),Offset(0.55,0.82),Offset(0.68,0.72),Offset(0.72,0.55),Offset(0.65,0.35),Offset(0.5,0.15)]],
    'ඊ': [[Offset(0.42,0.15),Offset(0.3,0.35),Offset(0.22,0.55),Offset(0.3,0.72),Offset(0.48,0.82),Offset(0.62,0.72),Offset(0.65,0.55),Offset(0.58,0.35),Offset(0.42,0.15)],[Offset(0.72,0.15),Offset(0.72,0.85)]],
    'උ': [[Offset(0.35,0.2),Offset(0.5,0.15),Offset(0.65,0.2),Offset(0.72,0.38),Offset(0.68,0.55),Offset(0.55,0.7),Offset(0.38,0.72),Offset(0.25,0.62),Offset(0.22,0.45)]],
    'ඌ': [[Offset(0.28,0.2),Offset(0.42,0.15),Offset(0.58,0.2),Offset(0.65,0.38),Offset(0.6,0.55),Offset(0.48,0.7),Offset(0.32,0.72),Offset(0.2,0.62),Offset(0.18,0.45)],[Offset(0.72,0.15),Offset(0.72,0.85)]],
    'එ': [[Offset(0.75,0.35),Offset(0.55,0.2),Offset(0.35,0.28),Offset(0.25,0.45),Offset(0.28,0.62),Offset(0.45,0.75),Offset(0.65,0.72),Offset(0.75,0.58)]],
    'ඒ': [[Offset(0.68,0.35),Offset(0.48,0.2),Offset(0.28,0.28),Offset(0.18,0.45),Offset(0.22,0.62),Offset(0.38,0.75),Offset(0.58,0.72),Offset(0.68,0.58)],[Offset(0.75,0.15),Offset(0.75,0.85)]],
    'ඔ': [[Offset(0.5,0.15),Offset(0.3,0.25),Offset(0.2,0.45),Offset(0.25,0.65),Offset(0.45,0.78),Offset(0.65,0.72),Offset(0.75,0.52),Offset(0.68,0.32),Offset(0.5,0.15)],[Offset(0.5,0.78),Offset(0.5,0.88)]],
    'ඕ': [[Offset(0.42,0.15),Offset(0.22,0.25),Offset(0.12,0.45),Offset(0.18,0.65),Offset(0.38,0.78),Offset(0.58,0.72),Offset(0.68,0.52),Offset(0.6,0.32),Offset(0.42,0.15)],[Offset(0.42,0.78),Offset(0.42,0.88)],[Offset(0.75,0.15),Offset(0.75,0.85)]],
    // ── Sinhala Consonants ────────────────────────────────────────────────────
    'ක': [[Offset(0.5,0.15),Offset(0.35,0.35),Offset(0.3,0.55),Offset(0.4,0.72),Offset(0.55,0.78),Offset(0.68,0.68),Offset(0.72,0.5),Offset(0.65,0.32),Offset(0.5,0.15)],[Offset(0.55,0.78),Offset(0.5,0.92)]],
    'ඛ': [[Offset(0.45,0.15),Offset(0.3,0.35),Offset(0.25,0.55),Offset(0.35,0.72),Offset(0.5,0.78),Offset(0.63,0.68),Offset(0.67,0.5),Offset(0.6,0.32),Offset(0.45,0.15)],[Offset(0.5,0.78),Offset(0.45,0.92)],[Offset(0.72,0.2),Offset(0.72,0.55)]],
    'ග': [[Offset(0.5,0.15),Offset(0.32,0.3),Offset(0.22,0.5),Offset(0.28,0.68),Offset(0.48,0.8),Offset(0.68,0.72),Offset(0.75,0.52),Offset(0.65,0.32),Offset(0.5,0.15)],[Offset(0.5,0.8),Offset(0.45,0.92)]],
    'ඝ': [[Offset(0.42,0.15),Offset(0.25,0.3),Offset(0.15,0.5),Offset(0.22,0.68),Offset(0.42,0.8),Offset(0.62,0.72),Offset(0.68,0.52),Offset(0.58,0.32),Offset(0.42,0.15)],[Offset(0.42,0.8),Offset(0.38,0.92)],[Offset(0.75,0.2),Offset(0.75,0.6)]],
    'ච': [[Offset(0.72,0.3),Offset(0.52,0.18),Offset(0.32,0.28),Offset(0.22,0.48),Offset(0.25,0.68),Offset(0.42,0.82),Offset(0.62,0.78),Offset(0.72,0.6)],[Offset(0.62,0.78),Offset(0.58,0.92)]],
    'ජ': [[Offset(0.65,0.3),Offset(0.45,0.18),Offset(0.25,0.28),Offset(0.15,0.48),Offset(0.18,0.68),Offset(0.35,0.82),Offset(0.55,0.78),Offset(0.65,0.6)],[Offset(0.55,0.78),Offset(0.52,0.92)],[Offset(0.75,0.15),Offset(0.72,0.5)]],
    'ට': [[Offset(0.2,0.38),Offset(0.5,0.28),Offset(0.78,0.38)],[Offset(0.5,0.28),Offset(0.5,0.72),Offset(0.38,0.85),Offset(0.28,0.78)]],
    'ඩ': [[Offset(0.22,0.38),Offset(0.5,0.28),Offset(0.78,0.38)],[Offset(0.5,0.28),Offset(0.5,0.72),Offset(0.38,0.85),Offset(0.28,0.78)],[Offset(0.68,0.5),Offset(0.78,0.72),Offset(0.68,0.85)]],
    'ත': [[Offset(0.5,0.15),Offset(0.5,0.55)],[Offset(0.28,0.35),Offset(0.72,0.35)],[Offset(0.5,0.55),Offset(0.38,0.72),Offset(0.28,0.65),Offset(0.3,0.52)]],
    'ද': [[Offset(0.5,0.15),Offset(0.5,0.55)],[Offset(0.28,0.35),Offset(0.72,0.35)],[Offset(0.5,0.55),Offset(0.38,0.72),Offset(0.28,0.65),Offset(0.3,0.52)],[Offset(0.62,0.55),Offset(0.72,0.75),Offset(0.62,0.88)]],
    'න': [[Offset(0.25,0.35),Offset(0.5,0.22),Offset(0.75,0.35)],[Offset(0.5,0.22),Offset(0.5,0.65),Offset(0.38,0.82),Offset(0.25,0.72)]],
    'ප': [[Offset(0.5,0.15),Offset(0.32,0.28),Offset(0.22,0.48),Offset(0.28,0.65),Offset(0.45,0.75),Offset(0.62,0.68),Offset(0.68,0.5),Offset(0.62,0.32),Offset(0.5,0.15)],[Offset(0.5,0.75),Offset(0.5,0.92)]],
    'බ': [[Offset(0.5,0.15),Offset(0.32,0.28),Offset(0.22,0.48),Offset(0.28,0.65),Offset(0.45,0.75),Offset(0.62,0.68),Offset(0.68,0.5),Offset(0.62,0.32),Offset(0.5,0.15)],[Offset(0.5,0.75),Offset(0.5,0.92)],[Offset(0.25,0.15),Offset(0.25,0.5)]],
    'ම': [[Offset(0.2,0.3),Offset(0.5,0.2),Offset(0.78,0.3),Offset(0.72,0.55),Offset(0.5,0.68),Offset(0.28,0.58)],[Offset(0.5,0.68),Offset(0.5,0.88)]],
    'ය': [[Offset(0.5,0.15),Offset(0.32,0.32),Offset(0.25,0.52),Offset(0.32,0.68),Offset(0.5,0.75),Offset(0.68,0.65),Offset(0.72,0.45)],[Offset(0.5,0.75),Offset(0.45,0.92)]],
    'ර': [[Offset(0.25,0.35),Offset(0.5,0.25),Offset(0.72,0.32),Offset(0.78,0.5),Offset(0.68,0.68),Offset(0.48,0.78)],[Offset(0.48,0.78),Offset(0.42,0.92)]],
    'ල': [[Offset(0.5,0.15),Offset(0.5,0.65),Offset(0.35,0.82),Offset(0.22,0.72)],[Offset(0.28,0.42),Offset(0.72,0.42)]],
    'ව': [[Offset(0.25,0.28),Offset(0.5,0.18),Offset(0.72,0.28),Offset(0.78,0.5),Offset(0.65,0.68),Offset(0.45,0.78),Offset(0.28,0.68),Offset(0.22,0.48)]],
    'ස': [[Offset(0.72,0.28),Offset(0.5,0.18),Offset(0.28,0.28),Offset(0.22,0.45),Offset(0.32,0.55),Offset(0.55,0.55),Offset(0.68,0.65),Offset(0.62,0.78),Offset(0.42,0.85),Offset(0.25,0.78)]],
    'හ': [[Offset(0.28,0.2),Offset(0.28,0.78)],[Offset(0.72,0.2),Offset(0.72,0.78)],[Offset(0.28,0.48),Offset(0.5,0.38),Offset(0.72,0.48)]],
    'ළ': [[Offset(0.5,0.15),Offset(0.5,0.65),Offset(0.35,0.82),Offset(0.22,0.72)],[Offset(0.28,0.42),Offset(0.72,0.42)],[Offset(0.62,0.62),Offset(0.72,0.78),Offset(0.62,0.88)]],
    // ── Tamil Vowels ──────────────────────────────────────────────────────────
    'அ': [[Offset(0.5,0.15),Offset(0.32,0.32),Offset(0.25,0.52),Offset(0.32,0.7),Offset(0.5,0.78),Offset(0.68,0.7),Offset(0.75,0.52),Offset(0.68,0.32),Offset(0.5,0.15)],[Offset(0.5,0.78),Offset(0.5,0.92)]],
    'ஆ': [[Offset(0.38,0.15),Offset(0.22,0.32),Offset(0.15,0.52),Offset(0.22,0.7),Offset(0.38,0.78),Offset(0.55,0.7),Offset(0.62,0.52),Offset(0.55,0.32),Offset(0.38,0.15)],[Offset(0.38,0.78),Offset(0.38,0.92)],[Offset(0.72,0.15),Offset(0.72,0.92)]],
    'இ': [[Offset(0.5,0.15),Offset(0.35,0.35),Offset(0.28,0.55),Offset(0.35,0.72),Offset(0.52,0.82),Offset(0.68,0.72),Offset(0.72,0.52),Offset(0.65,0.35),Offset(0.5,0.15)]],
    'ஈ': [[Offset(0.42,0.15),Offset(0.28,0.35),Offset(0.2,0.55),Offset(0.28,0.72),Offset(0.45,0.82),Offset(0.62,0.72),Offset(0.65,0.52),Offset(0.58,0.35),Offset(0.42,0.15)],[Offset(0.72,0.15),Offset(0.72,0.92)]],
    'உ': [[Offset(0.5,0.2),Offset(0.35,0.38),Offset(0.28,0.58),Offset(0.35,0.75),Offset(0.52,0.85),Offset(0.68,0.75),Offset(0.72,0.55)]],
    'ஊ': [[Offset(0.38,0.2),Offset(0.25,0.38),Offset(0.18,0.58),Offset(0.25,0.75),Offset(0.42,0.85),Offset(0.58,0.75),Offset(0.62,0.55)],[Offset(0.72,0.2),Offset(0.72,0.85)]],
    'எ': [[Offset(0.75,0.38),Offset(0.55,0.22),Offset(0.32,0.3),Offset(0.22,0.5),Offset(0.28,0.68),Offset(0.48,0.8),Offset(0.68,0.72)]],
    'ஏ': [[Offset(0.68,0.38),Offset(0.48,0.22),Offset(0.25,0.3),Offset(0.15,0.5),Offset(0.22,0.68),Offset(0.42,0.8),Offset(0.62,0.72)],[Offset(0.75,0.15),Offset(0.75,0.88)]],
    'ஐ': [[Offset(0.32,0.2),Offset(0.22,0.42),Offset(0.28,0.62),Offset(0.45,0.75),Offset(0.62,0.65),Offset(0.65,0.45),Offset(0.55,0.28),Offset(0.38,0.2)],[Offset(0.72,0.2),Offset(0.72,0.88)]],
    'ஒ': [[Offset(0.5,0.18),Offset(0.3,0.3),Offset(0.2,0.5),Offset(0.28,0.68),Offset(0.48,0.8),Offset(0.68,0.72),Offset(0.75,0.52),Offset(0.65,0.32),Offset(0.5,0.18)],[Offset(0.5,0.55),Offset(0.42,0.75),Offset(0.3,0.68)]],
    'ஓ': [[Offset(0.42,0.18),Offset(0.22,0.3),Offset(0.12,0.5),Offset(0.2,0.68),Offset(0.4,0.8),Offset(0.6,0.72),Offset(0.68,0.52),Offset(0.58,0.32),Offset(0.42,0.18)],[Offset(0.42,0.55),Offset(0.35,0.75),Offset(0.22,0.68)],[Offset(0.75,0.15),Offset(0.75,0.88)]],
    'ஔ': [[Offset(0.35,0.18),Offset(0.18,0.32),Offset(0.1,0.52),Offset(0.18,0.68),Offset(0.35,0.8),Offset(0.52,0.72),Offset(0.6,0.52),Offset(0.5,0.32),Offset(0.35,0.18)],[Offset(0.35,0.55),Offset(0.28,0.75),Offset(0.15,0.68)],[Offset(0.68,0.2),Offset(0.68,0.85)],[Offset(0.8,0.2),Offset(0.8,0.85)]],
    // ── Tamil Consonants ──────────────────────────────────────────────────────
    'க': [[Offset(0.25,0.3),Offset(0.5,0.18),Offset(0.75,0.3),Offset(0.72,0.55),Offset(0.55,0.72),Offset(0.35,0.68),Offset(0.25,0.52)],[Offset(0.5,0.72),Offset(0.45,0.88)]],
    'ச': [[Offset(0.72,0.32),Offset(0.5,0.18),Offset(0.28,0.3),Offset(0.2,0.52),Offset(0.28,0.7),Offset(0.5,0.82),Offset(0.7,0.72),Offset(0.75,0.52)],[Offset(0.5,0.82),Offset(0.45,0.92)]],
    'ட': [[Offset(0.22,0.38),Offset(0.5,0.25),Offset(0.78,0.38)],[Offset(0.5,0.25),Offset(0.5,0.7),Offset(0.38,0.85),Offset(0.25,0.78)]],
    'த': [[Offset(0.28,0.28),Offset(0.5,0.18),Offset(0.72,0.28)],[Offset(0.5,0.18),Offset(0.5,0.55)],[Offset(0.28,0.55),Offset(0.72,0.55)],[Offset(0.5,0.55),Offset(0.5,0.88)]],
    'ப': [[Offset(0.28,0.2),Offset(0.28,0.88)],[Offset(0.28,0.2),Offset(0.62,0.2),Offset(0.72,0.35),Offset(0.65,0.52),Offset(0.28,0.52)]],
    'ம': [[Offset(0.22,0.22),Offset(0.22,0.88)],[Offset(0.72,0.22),Offset(0.72,0.88)],[Offset(0.22,0.22),Offset(0.72,0.22)],[Offset(0.22,0.52),Offset(0.72,0.52)]],
    'ய': [[Offset(0.28,0.22),Offset(0.5,0.15),Offset(0.72,0.22),Offset(0.65,0.48),Offset(0.5,0.62),Offset(0.35,0.55)],[Offset(0.5,0.62),Offset(0.5,0.88)]],
    'ர': [[Offset(0.22,0.38),Offset(0.5,0.25),Offset(0.75,0.35),Offset(0.8,0.55),Offset(0.68,0.72),Offset(0.45,0.82)],[Offset(0.45,0.82),Offset(0.4,0.92)]],
    'ல': [[Offset(0.5,0.15),Offset(0.5,0.68),Offset(0.38,0.82),Offset(0.25,0.75)],[Offset(0.28,0.45),Offset(0.72,0.45)]],
    'வ': [[Offset(0.22,0.32),Offset(0.5,0.2),Offset(0.75,0.32),Offset(0.8,0.55),Offset(0.65,0.72),Offset(0.45,0.8),Offset(0.28,0.72),Offset(0.2,0.5)]],
    'ழ': [[Offset(0.5,0.18),Offset(0.3,0.32),Offset(0.22,0.52),Offset(0.3,0.7),Offset(0.5,0.8),Offset(0.7,0.7),Offset(0.75,0.5)],[Offset(0.75,0.5),Offset(0.72,0.72),Offset(0.58,0.88),Offset(0.4,0.88)]],
    'ள': [[Offset(0.5,0.15),Offset(0.5,0.68),Offset(0.38,0.82),Offset(0.25,0.75)],[Offset(0.28,0.45),Offset(0.72,0.45)],[Offset(0.65,0.65),Offset(0.75,0.8),Offset(0.65,0.9)]],
    'ற': [[Offset(0.22,0.38),Offset(0.5,0.25),Offset(0.75,0.35),Offset(0.8,0.55),Offset(0.68,0.72),Offset(0.45,0.82)],[Offset(0.45,0.82),Offset(0.4,0.92)],[Offset(0.22,0.38),Offset(0.22,0.72)]],
    'ன': [[Offset(0.22,0.35),Offset(0.5,0.22),Offset(0.75,0.35)],[Offset(0.5,0.22),Offset(0.5,0.68),Offset(0.38,0.85),Offset(0.25,0.75)],[Offset(0.55,0.52),Offset(0.75,0.52)]],
  };

  List<List<Offset>> get _currentGuide {
    final g = _strokeGuides[_letter];
    if (g != null) return g;
    return [[Offset(0.5,0.15),Offset(0.5,0.85)],[Offset(0.15,0.5),Offset(0.85,0.5)]];
  }

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _feedbackAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _feedbackCtrl, curve: Curves.elasticOut));
    _shakeCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim    = Tween(begin: Offset.zero, end: const Offset(0.02, 0)).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _traceCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _dotCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _dotAnim      = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _dotCtrl, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      setState(() {
        _corpus    = args['corpus']    ?? _corpus;
        _letterIdx = args['letterIdx'] ?? _letterIdx;
      });
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose(); _shakeCtrl.dispose();
    _traceCtrl.dispose();    _dotCtrl.dispose();
    super.dispose();
  }

  Future<void> _startTraceAnimation() async {
    setState(() { _isAnimating = true; _showGuide = false; });
    _traceCtrl.reset();
    await _traceCtrl.forward();
    if (mounted) setState(() => _isAnimating = false);
  }

  void _onPanStart(DragStartDetails d) {
    if (_isAnimating) return;
    HapticFeedbackService.penDown();
    final p = d.localPosition;
    _current = [StrokePoint(p.dx, p.dy, DateTime.now().millisecondsSinceEpoch)];
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isAnimating) return;
    final p = d.localPosition;
    const pad = 8.0;
    if (p.dx < pad || p.dx > _canvasSize.width - pad ||
        p.dy < pad || p.dy > _canvasSize.height - pad) {
      HapticFeedbackService.outOfBounds();
    }
    setState(() {
      _current.add(StrokePoint(
        p.dx.clamp(0, _canvasSize.width),
        p.dy.clamp(0, _canvasSize.height),
        DateTime.now().millisecondsSinceEpoch));
    });
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() {
      if (_current.isNotEmpty) _strokes.add(List.from(_current));
      _current = [];
    });
  }

  void _clear() {
    setState(() { _strokes.clear(); _current = []; _result = null; _showGuide = false; _isAnimating = false; });
    _feedbackCtrl.reset(); _traceCtrl.reset();
  }

  void _nextLetter() { setState(() { _letterIdx = (_letterIdx + 1) % _letters.length; _clear(); }); }
  void _prevLetter() { setState(() { _letterIdx = (_letterIdx - 1 + _letters.length) % _letters.length; _clear(); }); }

  Future<void> _submit() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please write the letter first! ✏️'), behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() { _submitting = true; _result = null; });
    _feedbackCtrl.reset();

    final localResult = StrokeAnalyzer.analyze(
      strokes: _strokes, corpus: _corpus, letter: _letter, canvasSize: _canvasSize);

    if (localResult.passed) {
      if (localResult.score >= 85) await HapticFeedbackService.excellent();
      else await HapticFeedbackService.correctStroke();
    } else {
      await HapticFeedbackService.wrongStroke();
      _shakeCtrl.forward(from: 0).then((_) => _shakeCtrl.reverse());
    }

    try {
      final api = context.read<ApiService>();
      await api.submitAttempt({
        'corpus': _corpus, 'letter': _letter,
        'strokes': _strokes.length, 'score': localResult.score.round(), 'passed': localResult.passed,
      });
    } catch (_) {}

    setState(() { _submitting = false; _result = localResult; });
    _feedbackCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('✏️ Write Letters'),
        backgroundColor: _color,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (v) => setState(() { _corpus = v; _letterIdx = 0; _clear(); }),
            itemBuilder: (_) => AppCorpora.letters.keys.map((c) =>
              PopupMenuItem(value: c, child: Row(children: [
                Text(AppCorpora.corpusEmojis[c]!), const SizedBox(width: 8),
                Text(AppCorpora.corpusNames[c]!),
              ]))).toList(),
          ),
        ],
      ),
      body: Column(children: [

        // Letter nav bar
        Container(
          color: _color,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: _prevLetter),
            Column(children: [
              Text(AppCorpora.corpusNames[_corpus]!, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              SlideTransition(position: _shakeAnim,
                child: Text(_letter, style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w900, height: 1.1))),
              Text('${_letterIdx + 1} / ${_letters.length}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
            IconButton(icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20), onPressed: _nextLetter),
          ]),
        ),

        // ── Guide buttons ─────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(child: _GuideBtn(
              icon: Icons.play_circle_outline_rounded, label: 'Trace\nGuide',
              color: _color, active: _isAnimating,
              onTap: _isAnimating ? null : _startTraceAnimation,
            )),
            const SizedBox(width: 8),
            Expanded(child: _GuideBtn(
              icon: Icons.format_list_numbered_rounded, label: 'Stroke\nOrder',
              color: AppColors.secondary, active: _showGuide,
              onTap: () => setState(() { _showGuide = !_showGuide; _isAnimating = false; _traceCtrl.reset(); }),
            )),
            const SizedBox(width: 8),
            Expanded(child: _GuideBtn(
              icon: Icons.blur_on_rounded, label: 'Dot\nGuide',
              color: AppColors.success, active: false,
              onTap: () {
                setState(() { _showGuide = true; });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Follow the dots! 🔵'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 1)));
              },
            )),
          ]),
        ),

        // ── Canvas ────────────────────────────────────────────────────────────
        Expanded(child: LayoutBuilder(builder: (ctx, box) {
          _canvasSize = Size(box.maxWidth, box.maxHeight);
          return Stack(children: [
            Container(color: Colors.white),
            CustomPaint(painter: _GuideLinesPainter(color: _color), child: const SizedBox.expand()),
            Center(child: Text(_letter, style: TextStyle(fontSize: 180, color: _color.withOpacity(0.05), fontWeight: FontWeight.w900))),

            // Dot-to-dot
            if (_showGuide)
              AnimatedBuilder(animation: _dotAnim, builder: (_, __) => CustomPaint(
                painter: _DotToDotPainter(guide: _currentGuide, canvasSize: _canvasSize, color: _color, dotScale: _dotAnim.value),
                child: const SizedBox.expand())),

            // Stroke order arrows
            if (_showGuide)
              CustomPaint(painter: _StrokeOrderPainter(guide: _currentGuide, canvasSize: _canvasSize, color: _color),
                child: const SizedBox.expand()),

            // Trace animation
            if (_isAnimating)
              AnimatedBuilder(animation: _traceCtrl, builder: (_, __) => CustomPaint(
                painter: _TraceAnimationPainter(guide: _currentGuide, canvasSize: _canvasSize, color: _color, progress: _traceCtrl.value),
                child: const SizedBox.expand())),

            // User strokes
            GestureDetector(key: _canvasKey,
              onPanStart: _onPanStart, onPanUpdate: _onPanUpdate, onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: _StrokePainter(strokes: [..._strokes, if (_current.isNotEmpty) _current], color: _color),
                child: const SizedBox.expand())),

            Positioned(top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Text('Strokes: ${_strokes.length}',
                  style: TextStyle(fontSize: 12, color: _color, fontWeight: FontWeight.w700)))),

            if (_isAnimating)
              Positioned(bottom: 10, left: 0, right: 0,
                child: Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Watch & Learn! 👀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))))),
          ]);
        })),

        if (_result != null)
          ScaleTransition(scale: _feedbackAnim, child: _FeedbackPanel(result: _result!, color: _color)),

        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(children: [
            _ActionBtn(icon: Icons.refresh_rounded, label: 'Clear', color: Colors.grey.shade600, onTap: _clear, flex: 1),
            const SizedBox(width: 10),
            _ActionBtn(icon: _submitting ? null : Icons.check_circle_outline,
              label: _submitting ? 'Checking...' : 'Check ✓',
              color: _color, onTap: _submitting ? null : _submit, flex: 2, isLoading: _submitting),
            const SizedBox(width: 10),
            _ActionBtn(icon: Icons.skip_next_rounded, label: 'Next', color: AppColors.success, onTap: _nextLetter, flex: 1),
          ]),
        ),
      ]),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _TraceAnimationPainter extends CustomPainter {
  final List<List<Offset>> guide;
  final Size canvasSize;
  final Color color;
  final double progress;
  const _TraceAnimationPainter({required this.guide, required this.canvasSize, required this.color, required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    if (guide.isEmpty) return;
    final total = guide.fold<int>(0, (s, g) => s + g.length);
    if (total < 2) return;
    final paint = Paint()..color = color.withOpacity(0.85)..strokeWidth = 7..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    double globalProg = progress * total;
    int drawn = 0;
    for (int si = 0; si < guide.length; si++) {
      final stroke = guide[si];
      if (stroke.length < 2) continue;
      final path = Path();
      bool started = false; Offset? last;
      for (int pi = 0; pi < stroke.length; pi++) {
        if (drawn + pi > globalProg) break;
        final pt = Offset(stroke[pi].dx * canvasSize.width, stroke[pi].dy * canvasSize.height);
        if (!started) { path.moveTo(pt.dx, pt.dy); started = true; } else path.lineTo(pt.dx, pt.dy);
        last = pt;
      }
      canvas.drawPath(path, paint);
      if (last != null && drawn + stroke.length > globalProg) {
        canvas.drawCircle(last, 14, Paint()..color = color..style = PaintingStyle.fill);
        canvas.drawCircle(last, 8, dotPaint);
      }
      drawn += stroke.length;
      if (drawn > globalProg) break;
    }
  }
  @override bool shouldRepaint(_TraceAnimationPainter old) => old.progress != progress;
}

class _StrokeOrderPainter extends CustomPainter {
  final List<List<Offset>> guide;
  final Size canvasSize;
  final Color color;
  const _StrokeOrderPainter({required this.guide, required this.canvasSize, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.red];
    for (int si = 0; si < guide.length; si++) {
      final stroke = guide[si];
      if (stroke.length < 2) continue;
      final c = colors[si % colors.length];
      final paint = Paint()..color = c.withOpacity(0.55)..strokeWidth = 2.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      final path = Path();
      for (int pi = 0; pi < stroke.length; pi++) {
        final pt = Offset(stroke[pi].dx * canvasSize.width, stroke[pi].dy * canvasSize.height);
        if (pi == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
      }
      _drawDashed(canvas, path, paint);
      if (stroke.length >= 2) {
        final last = Offset(stroke.last.dx * canvasSize.width, stroke.last.dy * canvasSize.height);
        final prev = Offset(stroke[stroke.length-2].dx * canvasSize.width, stroke[stroke.length-2].dy * canvasSize.height);
        _arrowHead(canvas, prev, last, c);
      }
      final start = Offset(stroke.first.dx * canvasSize.width, stroke.first.dy * canvasSize.height);
      canvas.drawCircle(start, 13, Paint()..color = c..style = PaintingStyle.fill);
      canvas.drawCircle(start, 13, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      final tp = TextPainter(text: TextSpan(text: '${si+1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, start - Offset(tp.width/2, tp.height/2));
    }
  }
  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final m in path.computeMetrics()) {
      double d = 0; bool draw = true;
      while (d < m.length) {
        final end = (d + (draw ? 8.0 : 5.0)).clamp(0.0, m.length);
        if (draw) canvas.drawPath(m.extractPath(d, end), paint);
        d = end; draw = !draw;
      }
    }
  }
  void _arrowHead(Canvas canvas, Offset from, Offset to, Color c) {
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    const s = 12.0;
    final p = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - s*cos(angle-0.4), to.dy - s*sin(angle-0.4))
      ..lineTo(to.dx - s*cos(angle+0.4), to.dy - s*sin(angle+0.4))
      ..close();
    canvas.drawPath(p, Paint()..color = c..style = PaintingStyle.fill);
  }
  @override bool shouldRepaint(_) => false;
}

class _DotToDotPainter extends CustomPainter {
  final List<List<Offset>> guide;
  final Size canvasSize;
  final Color color;
  final double dotScale;
  const _DotToDotPainter({required this.guide, required this.canvasSize, required this.color, required this.dotScale});
  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in guide) {
      for (int pi = 0; pi < stroke.length; pi++) {
        final pt = Offset(stroke[pi].dx * canvasSize.width, stroke[pi].dy * canvasSize.height);
        final isFirst = pi == 0; final isLast = pi == stroke.length - 1;
        final r = (isFirst ? 10.0 : isLast ? 8.0 : 5.0) * dotScale;
        canvas.drawCircle(pt, r+2, Paint()..color = color.withOpacity(0.15)..style = PaintingStyle.fill);
        canvas.drawCircle(pt, r, Paint()..color = (isFirst ? color : color.withOpacity(0.6))..style = PaintingStyle.fill);
        if (isFirst) canvas.drawCircle(pt, r*0.45, Paint()..color = Colors.white..style = PaintingStyle.fill);
      }
    }
  }
  @override bool shouldRepaint(_DotToDotPainter old) => old.dotScale != dotScale;
}

class _GuideLinesPainter extends CustomPainter {
  final Color color;
  const _GuideLinesPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(0.12)..strokeWidth = 1;
    for (final r in [0.25, 0.5, 0.75]) {
      final y = size.height * r; double x = 0;
      while (x < size.width) { canvas.drawLine(Offset(x,y), Offset(x+8,y), p); x+=16; }
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _StrokePainter extends CustomPainter {
  final List<List<StrokePoint>> strokes;
  final Color color;
  const _StrokePainter({required this.strokes, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.88)..strokeWidth = 5.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path();
      path.moveTo(stroke.first.x, stroke.first.y);
      for (int i = 1; i < stroke.length; i++) {
        if (i < stroke.length - 1) {
          final mx = (stroke[i].x + stroke[i+1].x) / 2;
          final my = (stroke[i].y + stroke[i+1].y) / 2;
          path.quadraticBezierTo(stroke[i].x, stroke[i].y, mx, my);
        } else path.lineTo(stroke[i].x, stroke[i].y);
      }
      canvas.drawPath(path, paint);
      canvas.drawCircle(Offset(stroke.first.x, stroke.first.y), 3, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }
  @override bool shouldRepaint(_StrokePainter old) => old.strokes != strokes;
}

// ── UI Widgets ────────────────────────────────────────────────────────────────

class _GuideBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color; final bool active; final VoidCallback? onTap;
  const _GuideBtn({required this.icon, required this.label, required this.color, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: active ? color : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: active ? Colors.white : color, size: 20),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: active ? Colors.white : color), textAlign: TextAlign.center),
      ])));
}

class _FeedbackPanel extends StatelessWidget {
  final StrokeAnalysisResult result; final Color color;
  const _FeedbackPanel({required this.result, required this.color});
  @override
  Widget build(BuildContext context) {
    final passed = result.passed; final score = result.score;
    final bg = passed ? (score>=85 ? const Color(0xFFE8F5E9) : const Color(0xFFF1F8E9)) : const Color(0xFFFFF3E0);
    final bd = passed ? AppColors.success : AppColors.warning;
    return Container(
      margin: const EdgeInsets.fromLTRB(16,0,16,8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: bd.withOpacity(0.5), width: 1.5)),
      child: Row(children: [
        Text(score>=85?'🌟':score>=60?'😊':'💪', style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Score: ${score.toStringAsFixed(0)}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: passed?AppColors.success:AppColors.warning)),
            const SizedBox(width: 8),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: score/100, backgroundColor: Colors.grey.shade200, color: passed?AppColors.success:AppColors.warning, minHeight: 6))),
          ]),
          const SizedBox(height: 4),
          Text(result.feedback, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ])),
      ]));
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData? icon; final String label; final Color color; final VoidCallback? onTap; final int flex; final bool isLoading;
  const _ActionBtn({required this.label, required this.color, required this.onTap, required this.flex, this.icon, this.isLoading=false});
  @override
  Widget build(BuildContext context) => Expanded(flex: flex,
    child: GestureDetector(onTap: onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 150), height: 52,
        decoration: BoxDecoration(
          color: onTap==null ? Colors.grey.shade200 : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: onTap==null ? Colors.grey.shade300 : color, width: 1.5)),
        child: Center(child: isLoading
          ? SizedBox(width:20, height:20, child: CircularProgressIndicator(color: color, strokeWidth: 2))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, color: color, size: 18), const SizedBox(width: 4)],
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ])))));
}

