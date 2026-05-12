const mongoose = require('mongoose');
const badgeSchema = new mongoose.Schema({
  childId:     { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  badgeId:     { type: String, required: true },
  name:        { type: String, required: true },
  description: { type: String },
  emoji:       { type: String, default: '🏅' },
  earnedAt:    { type: Date, default: Date.now },
});
badgeSchema.index({ childId: 1, badgeId: 1 }, { unique: true });
module.exports = mongoose.model('Badge', badgeSchema);
