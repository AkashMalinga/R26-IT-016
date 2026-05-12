const mongoose = require('mongoose');
const sessionSchema = new mongoose.Schema({
  childId:         { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  durationSeconds: { type: Number, default: 0 },
  endedAt:         { type: Date, default: null },
}, { timestamps: true });
module.exports = mongoose.model('Session', sessionSchema);
