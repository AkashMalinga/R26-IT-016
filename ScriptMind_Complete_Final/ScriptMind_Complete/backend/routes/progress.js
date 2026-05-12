const express  = require('express');
const mongoose = require('mongoose');
const Attempt  = require('../models/Attempt');
const Session  = require('../models/Session');
const User     = require('../models/User');
const { protect } = require('../middleware/auth');
const router = express.Router();

async function buildProgress(childId) {
  const oid = new mongoose.Types.ObjectId(childId);
  const letterStats = await Attempt.aggregate([
    { $match: { childId: oid } }, { $sort: { createdAt: 1 } },
    { $group: { _id: { corpus: '$corpus', letter: '$letter' }, attempts: { $sum: 1 }, bestScore: { $max: '$score' }, avgScore: { $avg: '$score' }, passed: { $max: { $cond: ['$passed', 1, 0] } }, lastAttempt: { $last: '$createdAt' }, history: { $push: { score: '$score', passed: '$passed', ts: '$createdAt' } } } },
    { $project: { _id: 0, corpus: '$_id.corpus', letter: '$_id.letter', attempts: 1, bestScore: 1, avgScore: { $round: ['$avgScore', 1] }, passed: { $eq: ['$passed', 1] }, lastAttempt: 1, history: 1 } },
    { $sort: { corpus: 1, letter: 1 } }
  ]);
  const totals = await Attempt.aggregate([
    { $match: { childId: oid } },
    { $group: { _id: null, totalAttempts: { $sum: 1 }, avgScore: { $avg: '$score' }, totalPassed: { $sum: { $cond: ['$passed', 1, 0] } }, totalXP: { $sum: '$xpEarned' } } }
  ]);
  const thirtyDaysAgo = new Date(Date.now() - 30 * 86400000);
  const dailyActivity = await Attempt.aggregate([
    { $match: { childId: oid, createdAt: { $gte: thirtyDaysAgo } } },
    { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }, attempts: { $sum: 1 }, passed: { $sum: { $cond: ['$passed', 1, 0] } }, avgScore: { $avg: '$score' } } },
    { $sort: { _id: 1 } }
  ]);
  const sessionCount = await Session.countDocuments({ childId: oid });
  const totalTimeSec = await Session.aggregate([{ $match: { childId: oid } }, { $group: { _id: null, total: { $sum: '$durationSeconds' } } }]);
  const t = totals[0] || { totalAttempts: 0, avgScore: 0, totalPassed: 0, totalXP: 0 };
  return { letters: letterStats, totalAttempts: t.totalAttempts, totalPassed: t.totalPassed, avgScore: Math.round(t.avgScore || 0), totalXP: t.totalXP, sessions: sessionCount, totalTimeSec: totalTimeSec[0]?.total || 0, dailyActivity };
}

router.get('/', protect, async (req, res) => {
  try { res.json(await buildProgress(req.user._id)); }
  catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/:childId', protect, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user._id.toString() !== req.params.childId)
      return res.status(403).json({ error: 'Forbidden' });
    const child = await User.findById(req.params.childId).select('-password');
    if (!child) return res.status(404).json({ error: 'Child not found' });
    res.json({ child, ...await buildProgress(req.params.childId) });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
