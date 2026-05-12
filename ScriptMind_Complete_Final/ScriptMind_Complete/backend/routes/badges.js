const express = require('express');
const Badge   = require('../models/Badge');
const { protect } = require('../middleware/auth');
const router = express.Router();

router.get('/', protect, async (req, res) => {
  try {
    const badges = await Badge.find({ childId: req.user._id }).sort({ earnedAt: -1 });
    res.json(badges);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/:childId', protect, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user._id.toString() !== req.params.childId)
      return res.status(403).json({ error: 'Forbidden' });
    const badges = await Badge.find({ childId: req.params.childId }).sort({ earnedAt: -1 });
    res.json(badges);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
