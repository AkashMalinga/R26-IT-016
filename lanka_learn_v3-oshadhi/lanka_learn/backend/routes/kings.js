const express = require('express');
const router = express.Router();

const KINGS = {
  en: [
    { id: 0, name: 'Prince Vijaya', period: '543 BC', icon: '🤴', kingdom: 'Tambapanni', story: "Sri Lanka's recorded history begins with Prince Vijaya, who sailed from India around 543 BC. He married Kuveni and founded the Kingdom of Tambapanni.", contributions: ['Established first recorded kingdom','Founded Tambapanni','Began Sinhala civilization'], monuments: [], quote: '', xpReward: 10 },
    { id: 1, name: 'King Devanampiya Tissa', period: '247–207 BC', icon: '🙏', kingdom: 'Anuradhapura', story: "Arahat Mahinda arrived at Mihintale and converted the king to Buddhism. He brought the sacred Sri Maha Bodhi tree and established the Mahavihara monastery.", contributions: ['Accepted Buddhism as state religion','Brought Sri Maha Bodhi tree','Built Mahavihara monastery'], monuments: ['Mihintale','Sri Maha Bodhi','Mahavihara'], quote: '', xpReward: 12 },
    { id: 2, name: 'King Dutugamunu', period: '161–137 BC', icon: '⚔️', kingdom: 'Anuradhapura', story: "King Dutugamunu unified the island by defeating King Elara. His war elephant Kandula became legendary. He built the Ruwanwelisaya, Lovamahapaya, and Mirisawetiya.", contributions: ['Unified Sri Lanka','Defeated King Elara','Built Ruwanwelisaya'], monuments: ['Ruwanwelisaya','Mirisawetiya','Lovamahapaya'], quote: '', xpReward: 15 },
    { id: 3, name: 'King Mahasena', period: '276–303 AD', icon: '💧', kingdom: 'Anuradhapura', story: 'Known as the "Great Tank Builder," King Mahasena constructed 16 major reservoirs and 2 canals, making Sri Lanka one of the most advanced hydraulic civilizations.', contributions: ['Built 16 major irrigation tanks','Advanced agriculture','Built Jetavanaramaya stupa'], monuments: ['Minneriya Tank','Kaudulla Tank','Jetavanaramaya'], quote: '', xpReward: 12 },
    { id: 4, name: 'King Kashyapa', period: '477–495 AD', icon: '🏰', kingdom: 'Sigiriya', story: "King Kashyapa built one of the world's most extraordinary fortresses on a 200-meter granite monolith — Sigiriya. Now a UNESCO World Heritage Site.", contributions: ['Built UNESCO Sigiriya','Created water gardens','Cloud Maiden frescoes'], monuments: ['Sigiriya Rock Fortress','Sigiriya Water Gardens'], quote: '"The Lion Gate stood as testimony to a king\'s ambition and artistry."', xpReward: 15 },
    { id: 5, name: 'King Parakramabahu I', period: '1153–1186 AD', icon: '👑', kingdom: 'Polonnaruwa', story: "King Parakramabahu I created Sri Lanka's Golden Age. He unified three warring kingdoms and built the vast Parakrama Samudraya reservoir.", contributions: ['Unified three warring kingdoms','Built Parakrama Samudraya','Commissioned Gal Viharaya'], monuments: ['Parakrama Samudraya','Gal Viharaya','Lankathilaka'], quote: '"Not even a drop of rainwater should flow into the sea without being used for the benefit of man."', xpReward: 18 }
  ]
};

// Simple Sinhala + Tamil fallback (same structure)
KINGS.si = KINGS.en.map(k => ({ ...k }));
KINGS.ta = KINGS.en.map(k => ({ ...k }));

// GET /api/kings?lang=en
router.get('/', (req, res) => {
  const lang = req.query.lang || 'en';
  res.json({ kings: KINGS[lang] || KINGS.en });
});

// GET /api/kings/:id?lang=en
router.get('/:id', (req, res) => {
  const lang = req.query.lang || 'en';
  const id = parseInt(req.params.id);
  const king = (KINGS[lang] || KINGS.en).find(k => k.id === id);
  if (!king) return res.status(404).json({ error: 'King not found' });
  res.json({ king });
});

module.exports = router;
