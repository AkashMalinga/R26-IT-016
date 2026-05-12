require('dotenv').config();
const express    = require('express');
const mongoose   = require('mongoose');
const cors       = require('cors');

const authRoutes     = require('./routes/auth');
const userRoutes     = require('./routes/users');
const attemptRoutes  = require('./routes/attempts');
const progressRoutes = require('./routes/progress');
const adminRoutes    = require('./routes/admin');
const badgeRoutes    = require('./routes/badges');
const storyRoutes    = require('./routes/stories');
const analyticsRoutes= require('./routes/analytics');

const app  = express();
const PORT = process.env.PORT || 3001;

// ── MIDDLEWARE ────────────────────────────────────────────────────────────────
app.use(cors({ origin: '*', methods: ['GET','POST','PUT','DELETE','OPTIONS'], allowedHeaders: ['Content-Type','Authorization'] }));
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));

// ── API ROUTES ────────────────────────────────────────────────────────────────
app.use('/api/auth',      authRoutes);
app.use('/api/users',     userRoutes);
app.use('/api/attempts',  attemptRoutes);
app.use('/api/progress',  progressRoutes);
app.use('/api/admin',     adminRoutes);
app.use('/api/badges',    badgeRoutes);
app.use('/api/stories',   storyRoutes);
app.use('/api/analytics', analyticsRoutes);

// ── HEALTH CHECK ──────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ status: 'ok', db: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected', ts: new Date().toISOString() });
});

// ── CONNECT MONGODB & START ───────────────────────────────────────────────────
mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB Atlas connected');
    await seedDefaults();
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 ScriptMind backend running on http://localhost:${PORT}`);
      console.log(`\n  Default logins:`);
      console.log(`   Admin → admin / admin123`);
      console.log(`   Child → ravi  / ravi123`);
      console.log(`   Child → suri  / suri123\n`);
    });
  })
  .catch(err => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  });

// ── SEED DEFAULT USERS ────────────────────────────────────────────────────────
async function seedDefaults() {
  const User   = require('./models/User');
  const bcrypt = require('bcryptjs');
  const count  = await User.countDocuments();
  if (count > 0) return;
  const salt = await bcrypt.genSalt(10);
  await User.insertMany([
    { name: 'Administrator', username: 'admin', password: await bcrypt.hash('admin123', salt), role: 'admin', email: 'admin@scriptmind.edu', avatar: '🎓' },
    { name: 'Ravi Perera',   username: 'ravi',  password: await bcrypt.hash('ravi123',  salt), role: 'child', age: 8, grade: 'Grade 3', avatar: '🧒' },
    { name: 'Suri Silva',    username: 'suri',  password: await bcrypt.hash('suri123',  salt), role: 'child', age: 7, grade: 'Grade 2', avatar: '👧' },
  ]);
  console.log('🌱 Default users seeded.');
}
