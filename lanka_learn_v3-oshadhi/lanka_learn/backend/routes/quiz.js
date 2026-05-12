const express = require('express');
const router = express.Router();

const QUIZ_DATA = {
  en: {
    kings: [
      { id: 0, q: "Who is the first recorded king of Sri Lanka?", opts: ['Dutugamunu','Vijaya','Devanampiya Tissa','Kashyapa'], a: 1, e: 'Prince Vijaya is the first recorded king.', diff: 'easy', topic: 'kings' },
      { id: 1, q: 'Who built Sigiriya?', opts: ['Mahasena','Dutugamunu','Kashyapa','Parakramabahu'], a: 2, e: 'King Kashyapa built Sigiriya (477–495 AD).', diff: 'easy', topic: 'kings' },
      { id: 2, q: 'Which king is the "Great Tank Builder"?', opts: ['Vijaya','Devanampiya Tissa','Kashyapa','Mahasena'], a: 3, e: 'King Mahasena built 16 major tanks.', diff: 'easy', topic: 'kings' },
      { id: 3, q: 'Who built Ruwanwelisaya?', opts: ['Vijaya','Devanampiya Tissa','Dutugamunu','Mahasena'], a: 2, e: 'King Dutugamunu built Ruwanwelisaya.', diff: 'medium', topic: 'kings' },
      { id: 4, q: "During whose reign was Sri Maha Bodhi brought to Lanka?", opts: ['Kashyapa','Parakramabahu','Devanampiya Tissa','Vijaya'], a: 2, e: "During King Devanampiya Tissa's reign.", diff: 'medium', topic: 'kings' },
      { id: 5, q: 'Who built Parakrama Samudraya?', opts: ['Mahasena','Devanampiya Tissa','Dutugamunu','Parakramabahu'], a: 3, e: 'King Parakramabahu I.', diff: 'medium', topic: 'kings' },
      { id: 6, q: "What was King Dutugamunu's war elephant called?", opts: ['Gaja','Kandula','Raja','Dhanaya'], a: 1, e: "Kandula was his legendary war elephant.", diff: 'hard', topic: 'kings' },
      { id: 7, q: 'Who commissioned the Gal Viharaya sculptures?', opts: ['Devanampiya Tissa','Kashyapa','Mahasena','Parakramabahu'], a: 3, e: 'King Parakramabahu I commissioned Gal Viharaya.', diff: 'hard', topic: 'kings' }
    ],
    provinces: [
      { id: 8, q: 'How many provinces does Sri Lanka have?', opts: ['7','8','9','10'], a: 2, e: 'Sri Lanka has 9 provinces.', diff: 'easy', topic: 'provinces' },
      { id: 9, q: 'Which province is famous for gem mining?', opts: ['Southern','Western','Sabaragamuwa','Uva'], a: 2, e: 'Sabaragamuwa Province (Ratnapura).', diff: 'easy', topic: 'provinces' },
      { id: 10, q: "Where is the Temple of the Sacred Tooth Relic?", opts: ['Galle','Colombo','Kandy','Anuradhapura'], a: 2, e: 'Temple of the Tooth is in Kandy.', diff: 'easy', topic: 'provinces' },
      { id: 11, q: "Sri Lanka's economic hub province?", opts: ['Southern','Central','Western','Northern'], a: 2, e: 'Western Province.', diff: 'medium', topic: 'provinces' },
      { id: 12, q: "Adam's Peak is in which province?", opts: ['Uva','Central','Sabaragamuwa','Southern'], a: 2, e: "Adam's Peak is in Sabaragamuwa.", diff: 'medium', topic: 'provinces' },
      { id: 13, q: 'Galle Fort is in which province?', opts: ['Eastern','Western','Southern','Sabaragamuwa'], a: 2, e: 'Southern Province.', diff: 'hard', topic: 'provinces' },
      { id: 14, q: 'Arugam Bay is famous for?', opts: ['Gems','Surfing','Tea','Spices'], a: 1, e: 'Arugam Bay is world-famous for surfing.', diff: 'hard', topic: 'provinces' }
    ],
    monuments: [
      { id: 15, q: 'Is Sigiriya a UNESCO World Heritage Site?', opts: ['Yes','No'], a: 0, e: 'Yes! Sigiriya is a UNESCO World Heritage Site.', diff: 'easy', topic: 'monuments' },
      { id: 16, q: 'Who built Minneriya Tank?', opts: ['Dutugamunu','Devanampiya Tissa','Mahasena','Kashyapa'], a: 2, e: 'King Mahasena.', diff: 'medium', topic: 'monuments' },
      { id: 17, q: 'Where is Gal Viharaya?', opts: ['Anuradhapura','Polonnaruwa','Kandy','Galle'], a: 1, e: 'Polonnaruwa.', diff: 'medium', topic: 'monuments' },
      { id: 18, q: 'Sigiriya is called the?', opts: ['7th Wonder','8th Wonder','9th Wonder','10th Wonder'], a: 1, e: 'Sigiriya is the "Eighth Wonder of the World."', diff: 'easy', topic: 'monuments' },
      { id: 19, q: "Sri Maha Bodhi is the world's oldest?", opts: ['Building','Temple','Documented living tree','Canal'], a: 2, e: 'Oldest documented living tree.', diff: 'hard', topic: 'monuments' }
    ]
  }
};

function shuffle(arr) {
  return arr.slice().sort(() => Math.random() - 0.5);
}

// GET /api/quiz?category=kings&lang=en&count=5
router.get('/', (req, res) => {
  const { category = 'all', lang = 'en', count = 5 } = req.query;
  const data = QUIZ_DATA[lang] || QUIZ_DATA.en;
  let questions = [];

  if (category === 'all' || category === 'daily') {
    questions = [...data.kings, ...data.provinces, ...data.monuments];
  } else if (data[category]) {
    questions = data[category];
  } else {
    return res.status(400).json({ error: 'Invalid category' });
  }

  const selected = shuffle(questions).slice(0, parseInt(count));
  res.json({ questions: selected, total: selected.length });
});

// GET /api/quiz/categories
router.get('/categories', (req, res) => {
  res.json({
    categories: [
      { id: 'kings', name: 'Kings', icon: '👑', count: 8 },
      { id: 'provinces', name: 'Provinces', icon: '🗺️', count: 7 },
      { id: 'monuments', name: 'Monuments', icon: '🏛️', count: 5 },
      { id: 'ai', name: 'AI Quiz', icon: '🤖', count: 5 },
      { id: 'all', name: 'All Topics', icon: '🎲', count: 20 }
    ]
  });
});

module.exports = router;
