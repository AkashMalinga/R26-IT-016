const express = require('express');
const Attempt = require('../models/Attempt');
const User    = require('../models/User');
const { protect } = require('../middleware/auth');
const router = express.Router();

router.get('/leaderboard', protect, async (req, res) => {
  try {
    const top = await User.find({ role: 'child', isActive: true })
      .select('name avatar totalXP level streak')
      .sort({ totalXP: -1 }).limit(20);
    res.json(top);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/dashboard', protect, async (req, res) => {
  try {
    const weekAgo = new Date(Date.now() - 7 * 86400000);
    const [recentAttempts, corpusBreakdown] = await Promise.all([
      Attempt.find({ childId: req.user._id, createdAt: { $gte: weekAgo } }).sort({ createdAt: -1 }),
      Attempt.aggregate([
        { $match: { childId: req.user._id } },
        { $group: { _id: '$corpus', attempts: { $sum: 1 }, passed: { $sum: { $cond: ['$passed', 1, 0] } }, avgScore: { $avg: '$score' } } },
      ]),
    ]);
    res.json({ recentAttempts, corpusBreakdown });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
