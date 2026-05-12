import 'dart:math';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

// ── Stroke Point ──────────────────────────────────────────────────────────────
class StrokePoint {
  final double x, y;
  final int timestamp;
  const StrokePoint(this.x, this.y, this.timestamp);
  Map<String, dynamic> toJson() => {'x': x, 'y': y, 't': timestamp};
}

// ── Stroke Analysis Result ────────────────────────────────────────────────────
class StrokeAnalysisResult {
  final double score;
  final bool passed;
  final String feedback;
  final Map<String, double> metrics;
  final FeedbackType feedbackType;

  const StrokeAnalysisResult({
    required this.score,
    required this.passed,
    required this.feedback,
    required this.metrics,
    required this.feedbackType,
  });
}

enum FeedbackType { excellent, good, tryAgain, tooSmall, tooFewStrokes }

// ── Haptic Vibration Service ──────────────────────────────────────────────────
/// Research-based vibration patterns for handwriting feedback.
/// Different patterns convey different meanings to children:
/// - Wrong stroke: sharp double buzz
/// - Correct: gentle single pulse
/// - Excellent: celebration pattern
class HapticFeedbackService {
  static bool _hasVibrator = false;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      _hasVibrator = (await Vibration.hasVibrator()) ?? false;
    } catch (_) {
      _hasVibrator = false;
    }
    _initialized = true;
  }

  /// ❌ Wrong letter drawn → sharp double buzz to alert child
  static Future<void> wrongStroke() async {
    await init();
    if (_hasVibrator) {
      // Research: 2 short sharp pulses = "error" signal children recognize
      await Vibration.vibrate(pattern: [0, 120, 80, 120], intensities: [0, 200, 0, 200]);
    } else {
      // Fallback to HapticFeedback
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    }
  }

  /// ✅ Correct letter → gentle single pulse
  static Future<void> correctStroke() async {
    await init();
    if (_hasVibrator) {
      await Vibration.vibrate(duration: 80, amplitude: 100);
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  /// 🎉 Excellent (>85%) → celebration pattern
  static Future<void> excellent() async {
    await init();
    if (_hasVibrator) {
      // 3 ascending pulses = celebration
      await Vibration.vibrate(
        pattern: [0, 60, 40, 80, 40, 120],
        intensities: [0, 100, 0, 150, 0, 200],
      );
    } else {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.heavyImpact();
    }
  }

  /// 📝 Writing detected (pen down) → tiny tick
  static Future<void> penDown() async {
    if (_hasVibrator) {
      await Vibration.vibrate(duration: 20, amplitude: 50);
    } else {
      await HapticFeedback.selectionClick();
    }
  }

  /// Stroke boundary warning → subtle buzz
  static Future<void> outOfBounds() async {
    await init();
    if (_hasVibrator) {
      await Vibration.vibrate(duration: 200, amplitude: 180);
    } else {
      await HapticFeedback.heavyImpact();
    }
  }
}

// ── Research-Based Stroke Analyzer ───────────────────────────────────────────
/// Geometric stroke analysis based on research features:
/// - Stroke count heuristic
/// - Aspect ratio comparison
/// - Canvas coverage
/// - Smoothness (direction change variance)
/// - Direction consistency
/// - Writing speed
class StrokeAnalyzer {
  static StrokeAnalysisResult analyze({
    required List<List<StrokePoint>> strokes,
    required String corpus,
    required String letter,
    required Size canvasSize,
  }) {
    if (strokes.isEmpty) {
      return const StrokeAnalysisResult(
        score: 0, passed: false,
        feedback: 'Please write the letter! ✏️',
        metrics: {},
        feedbackType: FeedbackType.tryAgain,
      );
    }

    final allPoints = strokes.expand((s) => s).toList();
    if (allPoints.length < 4) {
      return const StrokeAnalysisResult(
        score: 30, passed: false,
        feedback: 'Write a bit more! Try again 💪',
        metrics: {},
        feedbackType: FeedbackType.tooFewStrokes,
      );
    }

    final xs = allPoints.map((p) => p.x).toList();
    final ys = allPoints.map((p) => p.y).toList();

    // 1. Stroke score (heuristic based on count)
    final strokeScore = _strokeScore(strokes.length);

    // 2. Aspect ratio score
    final asp = _calcAspect(xs, ys);
    final aspectScore = _aspectScore(asp, corpus, letter);

    // 3. Coverage score
    final covScore = _coverageScore(xs, ys, canvasSize);

    // 4. Smoothness
    final smoothPct = _smoothness(allPoints);

    // 5. Direction consistency
    final dirScore = _directionConsistency(allPoints);

    // 6. Speed
    final speed = _calcSpeed(allPoints);

    final metrics = {
      'strokeScore': strokeScore,
      'aspectScore': aspectScore,
      'covScore':    covScore,
      'smoothPct':   smoothPct,
      'dirScore':    dirScore,
      'speed':       speed.clamp(0.0, 1.0),
    };

    // Weighted composite (research weights)
    double score = strokeScore  * 0.25 +
                   aspectScore  * 0.25 +
                   covScore     * 0.20 +
                   smoothPct    * 0.15 +
                   dirScore     * 0.15;

    score = (score * 100).clamp(0.0, 100.0);

    // Coverage too low → penalize
    if (covScore < 0.25) score = min(score, 45);

    final passed = score >= 60;

    // Generate contextual feedback
    final feedback = _generateFeedback(metrics, corpus, letter, score);
    final fType = score >= 85 ? FeedbackType.excellent
                : score >= 60 ? FeedbackType.good
                : covScore < 0.25 ? FeedbackType.tooSmall
                : FeedbackType.tryAgain;

    return StrokeAnalysisResult(
      score: score,
      passed: passed,
      feedback: feedback,
      metrics: metrics,
      feedbackType: fType,
    );
  }

  // ── Feature Extractors ──────────────────────────────────────────────────────

  static double _strokeScore(int n) {
    if (n == 1) return 0.85;
    if (n <= 3) return 0.92;
    if (n <= 5) return 0.75;
    if (n <= 8) return 0.55;
    return 0.35;
  }

  static double _aspectScore(double asp, String corpus, String letter) {
    const ranges = <String, List<double>>{
      'Latin Uppercase': [0.4, 1.6],
      'Latin Lowercase': [0.35, 1.5],
      'Sinhala':         [0.6, 1.9],
      'Tamil':           [0.5, 1.7],
    };
    final r = ranges[corpus] ?? [0.4, 1.8];
    if (asp >= r[0] && asp <= r[1]) return 0.95;
    final diff = min((asp - r[0]).abs(), (asp - r[1]).abs());
    return max(0.2, 0.95 - diff * 0.5);
  }

  static double _coverageScore(List<double> xs, List<double> ys, Size canvas) {
    if (xs.isEmpty || ys.isEmpty) return 0.0;
    final w = xs.reduce(max) - xs.reduce(min);
    final h = ys.reduce(max) - ys.reduce(min);
    final area = w * h;
    final canvasArea = canvas.width * canvas.height;
    // Expect at least 10% coverage
    return min(1.0, area / (canvasArea * 0.1)).clamp(0.0, 1.0);
  }

  static double _smoothness(List<StrokePoint> pts) {
    if (pts.length < 3) return 0.7;
    double totalChange = 0;
    int count = 0;
    for (int i = 1; i < pts.length - 1; i++) {
      final dx1 = pts[i].x - pts[i-1].x;
      final dy1 = pts[i].y - pts[i-1].y;
      final dx2 = pts[i+1].x - pts[i].x;
      final dy2 = pts[i+1].y - pts[i].y;
      final a1 = atan2(dy1, dx1);
      final a2 = atan2(dy2, dx2);
      totalChange += (a2 - a1).abs();
      count++;
    }
    if (count == 0) return 0.7;
    final mean = totalChange / count;
    return max(0.0, 1.0 - (mean / pi)).clamp(0.0, 1.0);
  }

  static double _directionConsistency(List<StrokePoint> pts) {
    if (pts.length < 4) return 0.6;
    final angles = <double>[];
    for (int i = 0; i < pts.length - 1; i++) {
      final dx = pts[i+1].x - pts[i].x;
      final dy = pts[i+1].y - pts[i].y;
      if (dx != 0 || dy != 0) angles.add(atan2(dy, dx));
    }
    if (angles.isEmpty) return 0.6;
    final mean = angles.reduce((a, b) => a + b) / angles.length;
    final variance = angles.map((a) => (a - mean) * (a - mean)).reduce((a, b) => a + b) / angles.length;
    return max(0.2, 1.0 - sqrt(variance) / pi).clamp(0.0, 1.0);
  }

  static double _calcAspect(List<double> xs, List<double> ys) {
    if (xs.isEmpty || ys.isEmpty) return 1.0;
    final w = xs.reduce(max) - xs.reduce(min);
    final h = ys.reduce(max) - ys.reduce(min);
    return h > 0 ? w / h : 1.0;
  }

  static double _calcSpeed(List<StrokePoint> pts) {
    if (pts.length < 2) return 0.5;
    double dist = 0;
    for (int i = 0; i < pts.length - 1; i++) {
      dist += sqrt(
        pow(pts[i+1].x - pts[i].x, 2) + pow(pts[i+1].y - pts[i].y, 2)
      );
    }
    final dt = (pts.last.timestamp - pts.first.timestamp).toDouble();
    if (dt <= 0) return 0.5;
    final pxPerSec = dist / dt * 1000;
    // 100–800 px/sec is normal child writing speed
    return (pxPerSec / 500).clamp(0.0, 1.0);
  }

  // ── Feedback Generator ──────────────────────────────────────────────────────
  static String _generateFeedback(
      Map<String, double> m, String corpus, String letter, double score) {
    final parts = <String>[];

    if (score >= 85) {
      parts.add("Excellent! '$letter' is perfect! 🌟");
    } else if (score >= 70) {
      parts.add("Great job on '$letter'! 😊");
    } else if (score >= 60) {
      parts.add("Good try on '$letter'! Keep it up! 👍");
    } else {
      parts.add("Keep trying '$letter'! You can do it! 💪");
    }

    if ((m['smoothPct'] ?? 1) < 0.45) {
      parts.add("Try to write more smoothly.");
    }
    if ((m['covScore'] ?? 1) < 0.3) {
      parts.add("Write bigger to fill the canvas.");
    }
    if ((m['aspectScore'] ?? 1) < 0.55) {
      parts.add("Try to balance the width and height.");
    }

    return parts.join(' ');
  }
}
