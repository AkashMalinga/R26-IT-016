const express = require('express');
const jwt     = require('jsonwebtoken');
const User    = require('../models/User');
const Session = require('../models/Session');
const { protect } = require('../middleware/auth');
const router = express.Router();

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, username, password, age, grade, avatar, email } = req.body;
    if (!name || !username || !password)
      return res.status(400).json({ error: 'name, username and password are required' });
    const exists = await User.findOne({ username: username.toLowerCase() });
    if (exists) return res.status(409).json({ error: 'Username already taken' });
    const user  = await User.create({ name, username, password, age, grade, avatar, email });
    const token = jwt.sign({ userId: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '7d' });
    res.status(201).json({ token, user });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) return res.status(400).json({ error: 'Username and password required' });
    const user = await User.findOne({ username: username.toLowerCase() });
    if (!user || !(await user.comparePassword(password))) return res.status(401).json({ error: 'Invalid credentials' });
    if (!user.isActive) return res.status(403).json({ error: 'Account is disabled' });

    // Streak logic
    const today     = new Date().toDateString();
    const lastActive = user.lastActiveDate ? new Date(user.lastActiveDate).toDateString() : null;
    if (lastActive !== today) {
      const yesterday = new Date(Date.now() - 86400000).toDateString();
      user.streak = lastActive === yesterday ? user.streak + 1 : 1;
      user.lastActiveDate = new Date();
      await user.save();
    }

    const token = jwt.sign({ userId: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '7d' });
    await Session.create({ childId: user._id });
    res.json({ token, user });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /api/auth/me
router.get('/me', protect, (req, res) => res.json(req.user));

// PUT /api/auth/session/end
router.put('/session/end', protect, async (req, res) => {
  try {
    const { durationSeconds } = req.body;
    const session = await Session.findOne({ childId: req.user._id, endedAt: null }).sort({ createdAt: -1 });
    if (session) { session.durationSeconds = durationSeconds || 0; session.endedAt = new Date(); await session.save(); }
    res.json({ ok: true });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
