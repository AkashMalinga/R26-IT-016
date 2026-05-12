const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');

const PROVINCES = {
  en: [
    { id: 0, name: 'Northern Province', dist: 'Jaffna, Kilinochchi, Mannar, Mullaitivu, Vavuniya', flag: '🔵', tags: ['Tamil Culture','Fisheries','Hindu Temples','Palmyrah'], places: ['Nallur Kandaswamy Kovil','Jaffna Fort','Nagadeepa Vihara','Point Pedro'], industry: 'Fisheries, Agriculture, Palmyrah Products' },
    { id: 1, name: 'Eastern Province', dist: 'Trincomalee, Batticaloa, Ampara', flag: '🟠', tags: ['Natural Harbor','Surfing','Rice Farming'], places: ['Koneswaram Temple','Pasikuda Beach','Arugam Bay','Fort Frederick'], industry: 'Fisheries, Paddy Cultivation, Tourism, Salt' },
    { id: 2, name: 'North Central Province', dist: 'Anuradhapura, Polonnaruwa', flag: '🟣', tags: ['Ancient Capitals','Buddhist Heritage','UNESCO Sites'], places: ['Sri Maha Bodhi','Ruwanwelisaya','Gal Viharaya','Parakrama Samudraya'], industry: 'Agriculture, Irrigation Farming, Cultural Tourism' },
    { id: 3, name: 'North Western Province', dist: 'Kurunegala, Puttalam', flag: '🟢', tags: ['Coconut Triangle','Salt Production','Lagoons'], places: ['Wilpattu National Park','Ridi Viharaya','Kurunegala Rock'], industry: 'Coconut Industry, Fisheries, Salt, Garments' },
    { id: 4, name: 'Central Province', dist: 'Kandy, Matale, Nuwara Eliya', flag: '🩷', tags: ['Temple of Tooth','Perahera Festival','Tea Estates','Sigiriya'], places: ['Temple of the Tooth','Horton Plains','Sigiriya','Knuckles'], industry: 'Tea Industry, Spice Cultivation, Tourism' },
    { id: 5, name: 'Western Province', dist: 'Colombo, Gampaha, Kalutara', flag: '🟡', tags: ['Economic Hub','Colombo Port','IT Industry'], places: ['Lotus Tower','Galle Face Green','Kelaniya Temple','Colombo Port'], industry: 'IT, Banking, Port & Shipping, Garments' },
    { id: 6, name: 'Uva Province', dist: 'Badulla, Monaragala', flag: '🩵', tags: ['Nine Arches Bridge','Ella Rock','Waterfalls'], places: ['Nine Arches Bridge','Ella Rock','Dunhinda Falls','Horton Plains'], industry: 'Tea Industry, Agriculture, Eco Tourism' },
    { id: 7, name: 'Southern Province', dist: 'Galle, Matara, Hambantota', flag: '🔴', tags: ['Galle Fort','Mirissa Beach','Yala Wildlife'], places: ['Galle Fort','Mirissa Beach','Yala National Park','Hambantota Port'], industry: 'Fisheries, Tourism, Salt Production' },
    { id: 8, name: 'Sabaragamuwa Province', dist: 'Ratnapura, Kegalle', flag: '🍏', tags: ['Gem Industry','Rubber',"Adam's Peak",'Sinharaja'], places: ["Adam's Peak","Sinharaja Forest","Pinnawala Elephant Orphanage"], industry: 'Gem Mining, Rubber Industry, Eco Tourism' }
  ]
};
PROVINCES.si = [
  { id: 0, name: 'උතුරු පළාත', dist: 'ජාෆ්නා, කිලිනොච්චි, මන්නාරම', flag: '🔵', tags: ['දෙමළ සංස්කෘතිය','ධීවර','හින්දු කෝවිල්'], places: ['Nallur Kandaswamy Kovil','Jaffna Fort','Nagadeepa Vihara'], industry: 'ධීවර, වේළාශ, පල්මිරා' },
  { id: 1, name: 'නැගෙනහිර පළාත', dist: 'ත්‍රිකුණාමලය, බදුල්ල, අම්පාර', flag: '🟠', tags: ['ස්වාභාවික වරාය','Surfing'], places: ['Koneswaram Temple','Pasikuda Beach','Arugam Bay'], industry: 'ධීවර, ගොවිතැන, සංචාරක' },
  { id: 2, name: 'උතුරු මැද පළාත', dist: 'අනුරාධපුර, පොළොන්නරුව', flag: '🟣', tags: ['පුරාණ රාජධානි','බෞද්ධ උරුම','UNESCO'], places: ['Sri Maha Bodhi','Ruwanwelisaya','Gal Viharaya'], industry: 'ගොවිතැන, සංචාරක, වාරිමාර්ග' },
  { id: 3, name: 'වයඹ පළාත', dist: 'කුරුණෑගල, පුත්තලම', flag: '🟢', tags: ['පොල් ත්‍රිකෝණය','ලුණු'], places: ['Wilpattu National Park','Ridi Viharaya'], industry: 'පොල්, ධීවර, ලුණු' },
  { id: 4, name: 'මධ්‍යම පළාත', dist: 'කන්ද, මාතලේ, නුවරඑළිය', flag: '🩷', tags: ['දළදා මාලිගාව','සිගිරිය','තේ'], places: ['Temple of the Tooth','Sigiriya','Horton Plains'], industry: 'තේ, කුළුබඩු, සංචාරක' },
  { id: 5, name: 'බස්නාහිර පළාත', dist: 'කොළඹ, ගම්පහ, කළුතර', flag: '🟡', tags: ['ආර්ථික මධ්‍යස්ථානය','IT'], places: ['Lotus Tower','Galle Face Green','Kelaniya Temple'], industry: 'IT, බැංකු, ව්‍යාපාර' },
  { id: 6, name: 'ඌව පළාත', dist: 'බදුල්ල, මොණරාගල', flag: '🩵', tags: ['Nine Arches Bridge','Ella Rock'], places: ['Nine Arches Bridge','Ella Rock','Dunhinda Falls'], industry: 'තේ, ගොවිතැන, සංචාරක' },
  { id: 7, name: 'දකුණු පළාත', dist: 'ගාල්ල, මාතර, හම්බන්තොට', flag: '🔴', tags: ['Galle Fort','Mirissa Beach','Yala'], places: ['Galle Fort','Mirissa Beach','Yala National Park'], industry: 'ධීවර, සංචාරක' },
  { id: 8, name: 'සබරගමුව පළාත', dist: 'රත්නපුර, කෑගල්ල', flag: '🍏', tags: ['මැණික්','රබර්','ශ්‍රී පාදය'], places: ["Adam's Peak","Sinharaja Forest","Pinnawala"], industry: 'මැණික්, රබර්, Eco Tourism' }
];
PROVINCES.ta = [
  { id: 0, name: 'வட மாகாணம்', dist: 'யாழ்ப்பாணம், கிளிநொச்சி', flag: '🔵', tags: ['தமிழ் கலாசாரம்','மீன்பிடி'], places: ['Nallur Kandaswamy','Jaffna Fort'], industry: 'மீன்பிடி, விவசாயம்' },
  { id: 1, name: 'கிழக்கு மாகாணம்', dist: 'திரிகோணமலை, மட்டக்களப்பு', flag: '🟠', tags: ['Surfing','மீன்பிடி'], places: ['Koneswaram','Pasikuda Beach'], industry: 'மீன்பிடி, சுற்றுலா' },
  { id: 2, name: 'வட மத்திய மாகாணம்', dist: 'அனுராதபுரம், பொலன்னறுவை', flag: '🟣', tags: ['யுனெஸ்கோ'], places: ['Sri Maha Bodhi','Ruwanwelisaya'], industry: 'விவசாயம், சுற்றுலா' },
  { id: 3, name: 'வட மேற்கு மாகாணம்', dist: 'குருணாகல், புத்தளம்', flag: '🟢', tags: ['தேங்காய்'], places: ['Wilpattu'], industry: 'தேங்காய், மீன்பிடி' },
  { id: 4, name: 'மத்திய மாகாணம்', dist: 'கண்டி, மாத்தலை', flag: '🩷', tags: ['தேயிலை'], places: ['Temple of Tooth','Sigiriya'], industry: 'தேயிலை, சுற்றுலா' },
  { id: 5, name: 'மேல் மாகாணம்', dist: 'கொழும்பு, கம்பஹா', flag: '🟡', tags: ['IT'], places: ['Lotus Tower','Galle Face'], industry: 'IT, வணிகம்' },
  { id: 6, name: 'ஊவா மாகாணம்', dist: 'பதுள்ளை, மொனராகலை', flag: '🩵', tags: ['தேயிலை'], places: ['Nine Arches','Ella Rock'], industry: 'தேயிலை, சுற்றுலா' },
  { id: 7, name: 'தென் மாகாணம்', dist: 'காலி, மாத்தறை', flag: '🔴', tags: ['காலி கோட்டை'], places: ['Galle Fort','Mirissa'], industry: 'மீன்பிடி, சுற்றுலா' },
  { id: 8, name: 'சபரகமுவ மாகாணம்', dist: 'இரத்தினபுரி, கேகாலை', flag: '🍏', tags: ['ரத்தினம்'], places: ["Adam's Peak","Sinharaja"], industry: 'ரத்தினம், ரப்பர்' }
];

// GET /api/provinces?lang=en
router.get('/', (req, res) => {
  const lang = req.query.lang || 'en';
  if (!PROVINCES[lang]) return res.status(400).json({ error: 'Invalid language' });
  res.json({ provinces: PROVINCES[lang] });
});

// GET /api/provinces/:id?lang=en
router.get('/:id', (req, res) => {
  const lang = req.query.lang || 'en';
  const id = parseInt(req.params.id);
  const province = PROVINCES[lang]?.find(p => p.id === id);
  if (!province) return res.status(404).json({ error: 'Province not found' });
  res.json({ province });
});

module.exports = router;
