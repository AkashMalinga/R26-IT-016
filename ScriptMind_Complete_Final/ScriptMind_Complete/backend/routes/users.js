const express = require('express');
const User    = require('../models/User');
const { protect, adminOnly } = require('../middleware/auth');

const router = express.Router();

// GET /api/users — list all users (admin)
router.get('/', protect, adminOnly, async (req, res) => {
  try {
    const users = await User.find().select('-password').sort({ createdAt: -1 });
    res.json(users);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// POST /api/users — create user (admin)
router.post('/', protect, adminOnly, async (req, res) => {
  try {
    const { name, username, password, role, age, grade, email, avatar } = req.body;
    if (!name || !username || !password)
      return res.status(400).json({ error: 'name, username and password are required' });
    if (password.length < 6)
      return res.status(400).json({ error: 'Password must be at least 6 characters' });

    const exists = await User.findOne({ username: username.toLowerCase() });
    if (exists) return res.status(409).json({ error: 'Username already taken' });

    const user = await User.create({
      name, username, password,
      role:   role   || 'child',
      age:    age    || null,
      grade:  grade  || null,
      email:  email  || null,
      avatar: avatar || '🧒',
      parentId: req.user._id
    });
    res.status(201).json(user);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /api/users/:id — get one user (admin or self)
router.get('/:id', protect, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user._id.toString() !== req.params.id)
      return res.status(403).json({ error: 'Forbidden' });
    const user = await User.findById(req.params.id).select('-password');
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /api/users/:id — update user (admin)
router.put('/:id', protect, adminOnly, async (req, res) => {
  try {
    const { name, age, grade, email, avatar, password, isActive } = req.body;
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });

    if (name     !== undefined) user.name     = name;
    if (age      !== undefined) user.age      = age;
    if (grade    !== undefined) user.grade    = grade;
    if (email    !== undefined) user.email    = email;
    if (avatar   !== undefined) user.avatar   = avatar;
    if (isActive !== undefined) user.isActive = isActive;
    if (password) {
      if (password.length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' });
      user.password = password; // pre-save hook will hash
    }

    await user.save();
    res.json(user);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// DELETE /api/users/:id — delete user (admin)
router.delete('/:id', protect, adminOnly, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    if (user.role === 'admin') return res.status(400).json({ error: 'Cannot delete admin account' });
    await user.deleteOne();
    res.json({ deleted: req.params.id });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
