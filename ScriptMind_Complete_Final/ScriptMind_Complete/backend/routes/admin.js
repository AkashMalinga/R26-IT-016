const express  = require('express');
const mongoose = require('mongoose');
const User     = require('../models/User');
const Attempt  = require('../models/Attempt');
const Session  = require('../models/Session');
const { protect, adminOnly } = require('../middleware/auth');

const router = express.Router();

// GET /api/admin/overview — all children with summary stats
router.get('/overview', protect, adminOnly, async (req, res) => {
  try {
    const children = await User.find({ role: 'child', isActive: true }).select('-password').lean();

    const childIds = children.map(c => c._id);

    // Bulk aggregate across all children
    const allStats = await Attempt.aggregate([
      { $match: { childId: { $in: childIds } } },
      {
        $group: {
          _id:           '$childId',
          totalAttempts: { $sum: 1 },
          avgScore:      { $avg: '$score' },
          totalPassed:   { $sum: { $cond: ['$passed', 1, 0] } },
          corpora:       { $addToSet: '$corpus' }
        }
      }
    ]);

    // Bulk letter-level grouping (for mastered count)
    const masteredStats = await Attempt.aggregate([
      { $match: { childId: { $in: childIds }, passed: true } },
      {
        $group: {
          _id: { childId: '$childId', corpus: '$corpus', letter: '$letter' }
        }
      },
      {
        $group: {
          _id:     '$_id.childId',
          mastered: { $sum: 1 }
        }
      }
    ]);

    // Sessions per child
    const sessionStats = await Session.aggregate([
      { $match: { childId: { $in: childIds } } },
      { $group: { _id: '$childId', sessions: { $sum: 1 }, totalTime: { $sum: '$durationSeconds' } } }
    ]);

    // Build lookup maps
    const statsMap    = Object.fromEntries(allStats.map(s    => [s._id.toString(), s]));
    const masteredMap = Object.fromEntries(masteredStats.map(s => [s._id.toString(), s.mastered]));
    const sessMap     = Object.fromEntries(sessionStats.map(s  => [s._id.toString(), s]));

    const enriched = children.map(c => {
      const id   = c._id.toString();
      const stat = statsMap[id]    || { totalAttempts: 0, avgScore: 0, totalPassed: 0 };
      const sess = sessMap[id]     || { sessions: 0, totalTime: 0 };
      return {
        ...c,
        totalAttempts: stat.totalAttempts,
        avgScore:      Math.round(stat.avgScore || 0),
        totalPassed:   masteredMap[id] || 0,
        sessions:      sess.sessions,
        totalTimeSec:  sess.totalTime
      };
    });

    const totalAttempts = enriched.reduce((s, c) => s + c.totalAttempts, 0);
    const totalPassed   = enriched.reduce((s, c) => s + c.totalPassed,   0);
    const avgAll        = enriched.length
      ? Math.round(enriched.reduce((s, c) => s + c.avgScore, 0) / enriched.length) : 0;

    res.json({ totalChildren: children.length, totalAttempts, totalPassed, avgScore: avgAll, children: enriched });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /api/admin/analytics — aggregate charts data
router.get('/analytics', protect, adminOnly, async (req, res) => {
  try {
    // Score distribution bands
    const scoreDist = await Attempt.aggregate([
      {
        $bucket: {
          groupBy: '$score',
          boundaries: [0, 20, 40, 60, 80, 101],
          default: 'other',
          output: { count: { $sum: 1 } }
        }
      }
    ]);

    // Attempts per corpus
    const corpusDist = await Attempt.aggregate([
      { $group: { _id: '$corpus', attempts: { $sum: 1 }, passed: { $sum: { $cond: ['$passed', 1, 0] } } } },
      { $sort: { _id: 1 } }
    ]);

    // Daily attempts over last 30 days
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const dailyActivity = await Attempt.aggregate([
      { $match: { createdAt: { $gte: thirtyDaysAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          attempts: { $sum: 1 },
          passed:   { $sum: { $cond: ['$passed', 1, 0] } }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    res.json({ scoreDist, corpusDist, dailyActivity });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
