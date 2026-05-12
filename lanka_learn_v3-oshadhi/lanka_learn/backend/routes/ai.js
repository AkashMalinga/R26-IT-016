const express = require('express');
const router = express.Router();
const Anthropic = require('@anthropic-ai/sdk');
const { protect } = require('../middleware/auth');
const { body, validationResult } = require('express-validator');

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// POST /api/ai/quiz — generate AI quiz questions
router.post('/quiz', protect, [
  body('level').isInt({ min: 1, max: 5 }),
  body('accuracy').isInt({ min: 0, max: 100 }),
  body('language').isIn(['si', 'ta', 'en']),
  body('weakTopics').optional().isArray()
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { level, accuracy, language, weakTopics = [] } = req.body;
    const diffHint = accuracy < 50 ? 'easy' : accuracy < 75 ? 'medium' : 'hard';
    const langFull = language === 'si' ? 'Sinhala' : language === 'ta' ? 'Tamil' : 'English';

    const prompt = `You are an educational quiz generator for a Sri Lankan history learning app for children.
Student profile: Level ${level}/5, Accuracy ${accuracy}%, Difficulty: ${diffHint}, Language: ${langFull}${weakTopics.length ? ', Weak topics: ' + weakTopics.join(', ') : ''}
Generate exactly 5 quiz questions about Sri Lankan history (kings, provinces, monuments) in ${langFull}.
Questions should be ${diffHint} difficulty, age-appropriate for primary school students.
Respond ONLY with a valid JSON array, no markdown, no explanation:
[{"q":"Question text","opts":["A","B","C","D"],"a":0,"e":"Brief explanation","diff":"easy","topic":"kings"}]`;

    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1000,
      messages: [{ role: 'user', content: prompt }]
    });

    let text = message.content.map(c => c.text || '').join('');
    text = text.replace(/```json|```/g, '').trim();
    const match = text.match(/\[[\s\S]*\]/);
    if (!match) throw new Error('Invalid AI response format');

    const questions = JSON.parse(match[0]);
    res.json({ questions, aiGenerated: true });
  } catch (err) {
    console.error('AI Quiz Error:', err.message);
    res.status(500).json({ error: 'AI quiz generation failed', message: err.message });
  }
});

// POST /api/ai/king-chat — chat with AI king
router.post('/king-chat', protect, [
  body('kingId').isInt({ min: 0, max: 5 }),
  body('message').trim().isLength({ min: 1, max: 500 }),
  body('language').isIn(['si', 'ta', 'en']),
  body('history').optional().isArray()
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const KINGS = {
    0: { name: 'Prince Vijaya', period: '543 BC', kingdom: 'Tambapanni', story: "First recorded king of Sri Lanka who sailed from India.", contributions: ['Founded Tambapanni','Began Sinhala civilization'] },
    1: { name: 'King Devanampiya Tissa', period: '247–207 BC', kingdom: 'Anuradhapura', story: "Accepted Buddhism and brought Sri Maha Bodhi tree.", contributions: ['Buddhism became state religion','Built Mahavihara'] },
    2: { name: 'King Dutugamunu', period: '161–137 BC', kingdom: 'Anuradhapura', story: "Unified Sri Lanka by defeating King Elara.", contributions: ['Unified Sri Lanka','Built Ruwanwelisaya'] },
    3: { name: 'King Mahasena', period: '276–303 AD', kingdom: 'Anuradhapura', story: "Built 16 major irrigation tanks.", contributions: ['Built 16 tanks','Advanced agriculture'] },
    4: { name: 'King Kashyapa', period: '477–495 AD', kingdom: 'Sigiriya', story: "Built the magnificent Sigiriya rock fortress.", contributions: ['Built Sigiriya','Created water gardens'] },
    5: { name: 'King Parakramabahu I', period: '1153–1186 AD', kingdom: 'Polonnaruwa', story: "Unified three kingdoms and built Parakrama Samudraya.", contributions: ['Unified three kingdoms','Built Parakrama Samudraya'] }
  };

  try {
    const { kingId, message, language, history = [] } = req.body;
    const k = KINGS[kingId];
    if (!k) return res.status(400).json({ error: 'Invalid king ID' });

    const langFull = language === 'si' ? 'Sinhala' : language === 'ta' ? 'Tamil' : 'English';
    const systemPrompt = `You are ${k.name}, the historical king of Sri Lanka (${k.period}), ruler of the ${k.kingdom}. 
Answer questions AS the king, speaking in first person, in a regal but friendly and educational tone appropriate for young children aged 6-12. 
Your story: ${k.story} 
Your achievements: ${k.contributions.join(', ')}.
Respond ONLY in ${langFull}. Keep answers to 2-3 short sentences max. Be encouraging and educational.`;

    const messages = [
      ...history.slice(-6).map(h => ({ role: h.role, content: h.content })),
      { role: 'user', content: message }
    ];

    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 300,
      system: systemPrompt,
      messages
    });

    const reply = response.content.map(c => c.text || '').join('');
    res.json({ reply, kingName: k.name });
  } catch (err) {
    console.error('King Chat Error:', err.message);
    res.status(500).json({ error: 'AI chat failed', message: err.message });
  }
});

module.exports = router;
