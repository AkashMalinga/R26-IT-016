const mongoose = require('mongoose');

const ProgressSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  xp: { type: Number, default: 0 },
  coins: { type: Number, default: 0 },
  level: { type: Number, default: 1 },
  streak: { type: Number, default: 0 },
  lastLoginDate: { type: String, default: '' },

  // Quiz stats
  totalAnswered: { type: Number, default: 0 },
  totalCorrect: { type: Number, default: 0 },
  quizHistory: [{ type: Number }], // array of percentage scores

  // Topic-level tracking
  topicCorrect: {
    kings:      { type: Number, default: 0 },
    provinces:  { type: Number, default: 0 },
    monuments:  { type: Number, default: 0 }
  },
  topicWrong: {
    kings:      { type: Number, default: 0 },
    provinces:  { type: Number, default: 0 },
    monuments:  { type: Number, default: 0 }
  },

  // Exploration
  provincesVisited: [{ type: Number }],
  kingsViewed:      [{ type: Number }],

  // Daily missions
  dailyDone: { type: Boolean, default: false },
  lastMissionDate: { type: String, default: '' },
  missionsToday: {
    explore: { type: Number, default: 0 },
    quiz:    { type: Boolean, default: false },
    king:    { type: Boolean, default: false }
  },

  // Achievements unlocked
  achievements: [{ type: String }],

  // Avatar shop
  unlockedAvatars: [{ type: Number, default: [0] }],
  selectedAvatar: { type: Number, default: 0 }

}, { timestamps: true });

// Accuracy virtual
ProgressSchema.virtual('accuracy').get(function() {
  if (this.totalAnswered === 0) return 0;
  return Math.round((this.totalCorrect / this.totalAnswered) * 100);
});

module.exports = mongoose.model('Progress', ProgressSchema);
