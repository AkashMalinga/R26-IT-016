const express = require('express');
const Attempt = require('../models/Attempt');
const User    = require('../models/User');
const Badge   = require('../models/Badge');
const { protect } = require('../middleware/auth');
const router = express.Router();

const BADGE_RULES = [
  { id: 'first_attempt',  name: 'First Step! 🐾',      emoji: '🐾', desc: 'Completed your first attempt',       check: s => s.totalAttempts === 1 },
  { id: 'pass_10',        name: 'Rising Star ⭐',       emoji: '⭐', desc: 'Passed 10 letters',                  check: s => s.totalPassed >= 10 },
  { id: 'pass_25',        name: 'Champion 🏆',          emoji: '🏆', desc: 'Passed 25 letters',                  check: s => s.totalPassed >= 25 },
  { id: 'pass_50',        name: 'Legend 🌟',            emoji: '🌟', desc: 'Passed 50 letters',                  check: s => s.totalPassed >= 50 },
  { id: 'perfect_score',  name: 'Perfect! 💯',          emoji: '💯', desc: 'Got 100% on an attempt',             check: s => s.latestScore === 100 },
  { id: 'streak_3',       name: '3-Day Streak 🔥',      emoji: '🔥', desc: 'Practiced 3 days in a row',         check: s => s.streak >= 3 },
  { id: 'streak_7',       name: 'Week Warrior 🗓️',     emoji: '🗓️',desc: 'Practiced 7 days in a row',         check: s => s.streak >= 7 },
  { id: 'sinhala_master', name: 'Sinhala Master 🇱🇰', emoji: '🇱🇰',desc: 'Passed 10 Sinhala letters',         check: s => s.sinhalaPass >= 10 },
  { id: 'tamil_master',   name: 'Tamil Master 🌺',      emoji: '🌺', desc: 'Passed 10 Tamil letters',           check: s => s.tamilPass >= 10 },
  { id: 'english_master', name: 'English Master 🔤',    emoji: '🔤', desc: 'Passed 10 English letters',         check: s => s.englishPass >= 10 },
  { id: 'multilingual',   name: 'Multilingual 🌍',      emoji: '🌍', desc: 'Passed letters in all 3 languages', check: s => s.sinhalaPass > 0 && s.tamilPass > 0 && s.englishPass > 0 },
];

async function awardBadges(userId, stats) {
  const newBadges = [];
  for (const rule of BADGE_RULES) {
    if (!rule.check(stats)) continue;
    try {
      const b = await Badge.create({ childId: userId, badgeId: rule.id, name: rule.name, description: rule.desc, emoji: rule.emoji });
      newBadges.push(b);
    } catch (_) {}
  }
  return newBadges;
}

// POST /api/attempts
router.post('/', protect, async (req, res) => {
  try {
    const { corpus, letter, score, passed, strokes, metrics, aiFeedback, timeTakenMs } = req.body;
    if (!corpus || !letter || score === undefined || passed === undefined)
      return res.status(400).json({ error: 'corpus, letter, score, passed are required' });

    const xpEarned = passed ? Math.round(10 + (score / 10)) : Math.round(score / 10);
    const attempt  = await Attempt.create({ childId: req.user._id, corpus, letter, score, passed, strokes: strokes || 0, metrics: { ...metrics, timeTakenMs }, aiFeedback: aiFeedback || null, xpEarned });

    const user = await User.findById(req.user._id);
    user.totalXP += xpEarned;
    user.level    = Math.floor(user.totalXP / 100) + 1;
    await user.save();

    const [totalAttempts, totalPassed] = await Promise.all([
      Attempt.countDocuments({ childId: user._id }),
      Attempt.countDocuments({ childId: user._id, passed: true }),
    ]);
    const corpusPassed = await Attempt.aggregate([
      { $match: { childId: user._id, passed: true } },
      { $group: { _id: { corpus: '$corpus', letter: '$letter' } } },
      { $group: { _id: '$_id.corpus', count: { $sum: 1 } } },
    ]);
    const cp = Object.fromEntries(corpusPassed.map(c => [c._id, c.count]));

    const newBadges = await awardBadges(user._id, {
      totalAttempts, totalPassed, latestScore: score, streak: user.streak,
      sinhalaPass: cp['Sinhala'] || 0, tamilPass: cp['Tamil'] || 0,
      englishPass: (cp['Latin Uppercase'] || 0) + (cp['Latin Lowercase'] || 0),
    });

    res.status(201).json({ attempt, xpEarned, newBadges, totalXP: user.totalXP, level: user.level });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /api/attempts/best
router.get('/best', protect, async (req, res) => {
  try {
    const best = await Attempt.aggregate([
      { $match: { childId: req.user._id } },
      { $group: { _id: { corpus: '$corpus', letter: '$letter' }, bestScore: { $max: '$score' }, passed: { $max: { $cond: ['$passed', 1, 0] } }, attempts: { $sum: 1 } } },
    ]);
    res.json(best);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /api/attempts/stats
router.get('/stats', protect, async (req, res) => {
  try {
    const stats = await Attempt.aggregate([
      { $match: { childId: req.user._id } },
      { $group: { _id: null, totalAttempts: { $sum: 1 }, avgScore: { $avg: '$score' }, totalPassed: { $sum: { $cond: ['$passed', 1, 0] } } } },
    ]);
    res.json(stats[0] || {});
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /api/attempts/mine
router.get('/mine', protect, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const filter = { childId: req.user._id };
    if (req.query.corpus) filter.corpus = req.query.corpus;
    if (req.query.letter) filter.letter = req.query.letter;
    const [attempts, total] = await Promise.all([
      Attempt.find(filter).sort({ createdAt: -1 }).skip((page-1)*limit).limit(limit),
      Attempt.countDocuments(filter),
    ]);
    res.json({ attempts, total, page, pages: Math.ceil(total / limit) });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /api/attempts/child/:id
router.get('/child/:id', protect, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user._id.toString() !== req.params.id)
      return res.status(403).json({ error: 'Forbidden' });
    const attempts = await Attempt.find({ childId: req.params.id }).sort({ createdAt: -1 }).limit(200);
    res.json(attempts);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
