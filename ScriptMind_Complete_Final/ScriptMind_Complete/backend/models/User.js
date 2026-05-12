const mongoose = require('mongoose');
const bcrypt   = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name:      { type: String, required: true, trim: true },
  username:  { type: String, required: true, unique: true, lowercase: true, trim: true },
  password:  { type: String, required: true, minlength: 6 },
  role:      { type: String, enum: ['admin', 'child'], default: 'child' },
  email:     { type: String, lowercase: true, trim: true, default: null },
  age:       { type: Number, min: 3, max: 18, default: null },
  grade:     { type: String, trim: true, default: null },
  avatar:    { type: String, default: '🧒' },
  parentId:  { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  isActive:  { type: Boolean, default: true },
  totalXP:   { type: Number, default: 0 },
  level:     { type: Number, default: 1 },
  streak:    { type: Number, default: 0 },
  lastActiveDate: { type: Date, default: null },
}, { timestamps: true });

userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});
userSchema.methods.comparePassword = function(candidate) {
  return bcrypt.compare(candidate, this.password);
};
userSchema.methods.toJSON = function() {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
