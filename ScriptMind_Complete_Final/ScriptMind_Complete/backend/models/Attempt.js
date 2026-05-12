const mongoose = require('mongoose');

const attemptSchema = new mongoose.Schema({
  childId:  { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  corpus:   { type: String, required: true, enum: ['Latin Uppercase','Latin Lowercase','Sinhala','Tamil'] },
  letter:   { type: String, required: true },
  score:    { type: Number, required: true, min: 0, max: 100 },
  passed:   { type: Boolean, required: true },
  strokes:  { type: Number, default: 0 },
  metrics: {
    strokeScore: Number, aspectScore: Number, covScore: Number,
    smoothPct: Number, dirScore: Number, asp: Number,
    speed: Number, strokeCount: Number, timeTakenMs: Number,
  },
  aiFeedback: { type: String, default: null },
  xpEarned:   { type: Number, default: 0 },
}, { timestamps: true });

attemptSchema.index({ childId: 1, corpus: 1, letter: 1 });
attemptSchema.index({ childId: 1, createdAt: -1 });

module.exports = mongoose.model('Attempt', attemptSchema);
