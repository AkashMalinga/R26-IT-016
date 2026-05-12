const express = require('express');
const router = express.Router();
const { protect, teacherOnly } = require('../middleware/auth');
const Progress = require('../models/Progress');
const User = require('../models/User');

// GET /api/analytics/overview — teacher dashboard (teacher only)
router.get('/overview', protect, teacherOnly, async (req, res) => {
  try {
    const totalStudents = await User.countDocuments({ role: 'student' });
    const allProgress = await Progress.find().populate('userId', 'name email language');

    const totalXP = allProgress.reduce((s, p) => s + p.xp, 0);
    const avgAccuracy = allProgress.length > 0
      ? Math.round(allProgress.reduce((s, p) => s + (p.totalAnswered > 0 ? p.totalCorrect / p.totalAnswered * 100 : 0), 0) / allProgress.length)
      : 0;

    const topStudents = allProgress
      .sort((a, b) => b.xp - a.xp)
      .slice(0, 10)
      .map(p => ({
        name: p.userId?.name || 'Unknown',
        xp: p.xp,
        level: p.level,
        accuracy: p.totalAnswered > 0 ? Math.round(p.totalCorrect / p.totalAnswered * 100) : 0
      }));

    res.json({
      totalStudents,
      totalXP,
      avgAccuracy,
      topStudents,
      totalProgressRecords: allProgress.length
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/analytics/leaderboard — public leaderboard
router.get('/leaderboard', protect, async (req, res) => {
  try {
    const topProgress = await Progress.find()
      .sort({ xp: -1 })
      .limit(20)
      .populate('userId', 'name language selectedAvatar');

    const leaderboard = topProgress.map((p, i) => ({
      rank: i + 1,
      name: p.userId?.name || 'Unknown',
      xp: p.xp,
      level: p.level,
      coins: p.coins,
      accuracy: p.totalAnswered > 0 ? Math.round(p.totalCorrect / p.totalAnswered * 100) : 0
    }));

    res.json({ leaderboard });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
