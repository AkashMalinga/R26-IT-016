const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const Progress = require('../models/Progress');

// GET /api/progress — get my progress
router.get('/', protect, async (req, res) => {
  try {
    let progress = await Progress.findOne({ userId: req.user._id });
    if (!progress) {
      progress = await Progress.create({ userId: req.user._id });
    }
    res.json({ progress });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/progress/xp — add XP and coins
router.post('/xp', protect, async (req, res) => {
  try {
    const { xp = 0, coins = 0 } = req.body;
    const progress = await Progress.findOneAndUpdate(
      { userId: req.user._id },
      { $inc: { xp, coins } },
      { new: true, upsert: true }
    );
    // Auto-level
    const levels = [0, 50, 150, 350, 700];
    let level = 1;
    for (let i = levels.length - 1; i >= 0; i--) {
      if (progress.xp >= levels[i]) { level = i + 1; break; }
    }
    if (progress.level !== level) {
      progress.level = level;
      await progress.save();
    }
    res.json({ progress });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/progress/quiz — save quiz result
router.post('/quiz', protect, async (req, res) => {
  try {
    const { score, total, topic, percentage } = req.body;
    const update = {
      $inc: { totalAnswered: total, totalCorrect: score },
      $push: { quizHistory: { $each: [percentage], $slice: -7 } }
    };
    if (topic && topic !== 'all') {
      update.$inc[`topicCorrect.${topic}`] = score;
      update.$inc[`topicWrong.${topic}`] = total - score;
    }
    const progress = await Progress.findOneAndUpdate(
      { userId: req.user._id },
      update,
      { new: true, upsert: true }
    );
    res.json({ progress });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/progress/province — mark province visited
router.post('/province', protect, async (req, res) => {
  try {
    const { provinceId } = req.body;
    const progress = await Progress.findOneAndUpdate(
      { userId: req.user._id },
      { $addToSet: { provincesVisited: provinceId } },
      { new: true, upsert: true }
    );
    res.json({ progress });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/progress/king — mark king viewed
router.post('/king', protect, async (req, res) => {
  try {
    const { kingId } = req.body;
    const progress = await Progress.findOneAndUpdate(
      { userId: req.user._id },
      { $addToSet: { kingsViewed: kingId } },
      { new: true, upsert: true }
    );
    res.json({ progress });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/progress/avatar — update avatar
router.put('/avatar', protect, async (req, res) => {
  try {
    const { avatarIndex } = req.body;
    const progress = await Progress.findOneAndUpdate(
      { userId: req.user._id },
      { selectedAvatar: avatarIndex, $addToSet: { unlockedAvatars: avatarIndex } },
      { new: true, upsert: true }
    );
    res.json({ progress });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/progress/mission — update daily mission
router.post('/mission', protect, async (req, res) => {
  try {
    const { type } = req.body;
    const update = {};
    if (type === 'explore') update['$inc'] = { 'missionsToday.explore': 1 };
    if (type === 'quiz') update['$set'] = { 'missionsToday.quiz': true };
    if (type === 'king') update['$set'] = { 'missionsToday.king': true };
    const progress = await Progress.findOneAndUpdate(
      { userId: req.user._id }, update, { new: true, upsert: true }
    );
    res.json({ progress });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
