const express = require('express');
const { protect } = require('../middleware/auth');
const router = express.Router();

const STORIES = [
  { id:'sharing', emoji:'🍎', color:0xFFFF7043, titleEn:'Sharing is Caring', titleSi:'බෙදා හදා ගැනීම', titleTa:'பகிர்வு அன்பு', moral:'Always share with friends 🤝',
    pages:[{en:'Amal had a big red apple.',si:'අමල් ළඟ විශාල රතු ඇපල් ගෙඩියක් තිබුණා.',ta:'அமலிடம் பெரிய சிவப்பு ஆப்பிள் இருந்தது.',emoji:'🍎'},{en:'His friend Nimal was hungry.',si:'ඔහුගේ යාළුවා නිමල් බඩගිනි හිටියා.',ta:'நண்பன் நிமல் பசியாக இருந்தான்.',emoji:'😔'},{en:'Amal shared the apple with Nimal.',si:'අමල් ඇපල් ගෙඩිය බෙදා ගත්තා.',ta:'அமல் ஆப்பிளை பகிர்ந்தான்.',emoji:'🤝'},{en:'Both friends were happy!',si:'යාළුවෝ දෙදෙනාම සතුටු වුණා!',ta:'இருவரும் மகிழ்ச்சியாக இருந்தனர்!',emoji:'😊'}]},
  { id:'kindness', emoji:'❤️', color:0xFFE91E63, titleEn:'Be Kind to Everyone', titleSi:'හැමෝටම හොඳට ඉන්න', titleTa:'அனைவரிடமும் கனிவாக இரு', moral:'Kindness makes the world beautiful 🌸',
    pages:[{en:'Sita found a baby bird fallen from its nest.',si:'සීතා කූඩුවෙන් වැටුණු කුඩා කුරුල්ලෙකු සොයා ගත්තා.',ta:'சீதா கூட்டிலிருந்து விழுந்த குஞ்சை கண்டாள்.',emoji:'🐦'},{en:'She gently picked it up and kept it safe.',si:'ඇය මෘදුවෙන් එය ඔසවා ආරක්ෂා කළා.',ta:'மெதுவாக எடுத்து பாதுகாப்பாக வைத்தாள்.',emoji:'❤️'},{en:'The bird grew strong and flew away happily!',si:'කුරුල්ලා ශක්තිමත් වී සතුටෙන් පියාඹා ගියා!',ta:'பறவை வலிமையாகி மகிழ்ச்சியாக பறந்தது!',emoji:'🦅'}]},
  { id:'hardwork', emoji:'🐰', color:0xFF9C27B0, titleEn:'The Hardworking Rabbit', titleSi:'වෙහෙස නොවී වැඩකළ හාවා', titleTa:'கடினமாக உழைத்த முயல்', moral:'Hard work always pays off 💪',
    pages:[{en:'Every day Bunny practiced writing all letters.',si:'හාවා සෑම දිනකම සියලු අකුරු ලිවීම පුහුණු වුණා.',ta:'ஒவ்வொரு நாளும் முயல் எழுத்து பயிற்சி செய்தது.',emoji:'🐰'},{en:'Even when it was hard, Bunny never gave up!',si:'අමාරු වුනත් හාවා කිසිදා නතර කළේ නැහැ!',ta:'கஷ்டமாக இருந்தாலும் விடவில்லை!',emoji:'💪'},{en:"Bunny became the best writer in the forest!",si:'හාවා වනාන්තරයේ හොඳම ලේඛකයා බවට පත් වුණා!',ta:'காட்டிலேயே சிறந்த எழுத்தாளன் ஆனது!',emoji:'🏆'}]},
  { id:'environment', emoji:'🌿', color:0xFF4CAF50, titleEn:'Keep Our World Clean', titleSi:'පරිසරය පිරිසිදුව රකිමු', titleTa:'உலகை சுத்தமாக வைப்போம்', moral:'Keep your environment clean 🌳',
    pages:[{en:'Mala saw litter in the park.',si:'මාලා උද්‍යානයේ කසළ දුටුවා.',ta:'மாலா பூங்காவில் குப்பையை பார்த்தாள்.',emoji:'🌳'},{en:'She picked it up and put it in the bin.',si:'ඇය එය ගෙන කූඩයට දැම්මා.',ta:'எடுத்து குப்பைத்தொட்டியில் போட்டாள்.',emoji:'🗑️'},{en:'The park became beautiful again!',si:'උද්‍යානය ලස්සන වුණා!',ta:'பூங்கா அழகாக ஆனது!',emoji:'🌈'}]},
];

router.get('/', protect, (req, res) => res.json(STORIES));
router.get('/:id', protect, (req, res) => {
  const story = STORIES.find(s => s.id === req.params.id);
  if (!story) return res.status(404).json({ error: 'Story not found' });
  res.json(story);
});

module.exports = router;
