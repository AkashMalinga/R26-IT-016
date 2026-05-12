const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const provincesRoutes = require('./routes/provinces');
const kingsRoutes = require('./routes/kings');
const quizRoutes = require('./routes/quiz');
const progressRoutes = require('./routes/progress');
const analyticsRoutes = require('./routes/analytics');
const aiRoutes = require('./routes/ai');

const app = express();

// ── Security Middleware (helmet + cors) ──
app.use(helmet());
app.use(cors({
  origin: ['http://localhost:3000', 'http://10.0.2.2:3000', '*'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// ── Rate Limiting ──
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 200,
  message: { error: 'Too many requests, please try again later.' }
});
app.use('/api/', limiter);

// ── Logging + Body Parser ──
app.use(morgan('dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Routes ──
app.use('/api/auth', authRoutes);
app.use('/api/provinces', provincesRoutes);
app.use('/api/kings', kingsRoutes);
app.use('/api/quiz', quizRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/ai', aiRoutes);

// ── Health Check ──
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'Lanka Learn API', version: '3.0' });
});

app.get('/', (req, res) => {
  res.json({ message: '🦁 Lanka Learn API v3.0 — AI Intelligent Learning System' });
});

// ── 404 Handler ──
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ── Global Error Handler ──
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error'
  });
});

// ── MongoDB Connection ──
mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB Connected — schoolDB');

    // Drop stale username_1 index if it exists (leftover from old schema)
    try {
      await mongoose.connection.collection('users').dropIndex('username_1');
      console.log('🧹 Dropped stale username_1 index');
    } catch (e) {
      // Index doesn't exist — that's fine, ignore
    }

    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => {
      console.log(`🚀 Lanka Learn Server running on http://localhost:${PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ MongoDB Connection Error:', err.message);
    process.exit(1);
  });

module.exports = app;
