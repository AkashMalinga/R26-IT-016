import 'package:flutter/material.dart';

// ── Brand Colors ──────────────────────────────────────────────────────────────
class AppColors {
  static const primary      = Color(0xFF5C6BC0);  // Indigo
  static const primaryDark  = Color(0xFF3949AB);
  static const secondary    = Color(0xFFFF7043);  // Deep Orange (warm)
  static const accent       = Color(0xFF26C6DA);  // Cyan
  static const success      = Color(0xFF66BB6A);
  static const warning      = Color(0xFFFFCA28);
  static const error        = Color(0xFFEF5350);
  static const background   = Color(0xFFF3F4FF);
  static const surface      = Colors.white;
  static const cardShadow   = Color(0x1A5C6BC0);

  // Language Colors
  static const sinhala      = Color(0xFF8D6E63);   // warm brown
  static const tamil        = Color(0xFF43A047);   // green
  static const english      = Color(0xFF1E88E5);   // blue

  // Vibration Colors (feedback)
  static const vibWrong     = Color(0xFFFF5252);
  static const vibCorrect   = Color(0xFF69F0AE);
}

// ── App Theme ─────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary:   AppColors.primary,
      secondary: AppColors.secondary,
      surface:   AppColors.background,
    ),
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
        elevation: 4,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      shadowColor: AppColors.cardShadow,
    ),
  );
}

// ── Corpus Data ───────────────────────────────────────────────────────────────
class AppCorpora {
  static const Map<String, List<String>> letters = {
    'Latin Uppercase': [
      'A','B','C','D','E','F','G','H','I','J','K','L','M',
      'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
    ],
    'Latin Lowercase': [
      'a','b','c','d','e','f','g','h','i','j','k','l','m',
      'n','o','p','q','r','s','t','u','v','w','x','y','z'
    ],
    'Sinhala': [
      'අ','ආ','ඇ','ඈ','ඉ','ඊ','උ','ඌ','එ','ඒ','ඔ','ඕ',
      'ක','ඛ','ග','ඝ','ච','ජ','ට','ඩ','ත','ද','න',
      'ප','බ','ම','ය','ර','ල','ව','ස','හ','ළ',
    ],
    'Tamil': [
      'அ','ஆ','இ','ஈ','உ','ஊ','எ','ஏ','ஐ','ஒ','ஓ','ஔ',
      'க','ச','ட','த','ப','ம','ய','ர','ல','வ','ழ','ள','ற','ன',
    ],
  };

  static const Map<String, Color> corpusColors = {
    'Latin Uppercase': AppColors.english,
    'Latin Lowercase': Color(0xFF42A5F5),
    'Sinhala':         AppColors.sinhala,
    'Tamil':           AppColors.tamil,
  };

  static const Map<String, String> corpusEmojis = {
    'Latin Uppercase': '🔤',
    'Latin Lowercase': '🔡',
    'Sinhala':         '🇱🇰',
    'Tamil':           '🌺',
  };

  static const Map<String, String> corpusNames = {
    'Latin Uppercase': 'English (BIG)',
    'Latin Lowercase': 'English (small)',
    'Sinhala':         'සිංහල',
    'Tamil':           'தமிழ்',
  };
}

// ── Stories ───────────────────────────────────────────────────────────────────
class AppStories {
  static const List<Map<String, dynamic>> stories = [
    {
      'id': 'sharing',
      'titleEn': 'Sharing is Caring',
      'titleSi': 'බෙදා හදා ගැනීම',
      'titleTa': 'பகிர்வு அன்பு',
      'moral':   'Always share with friends 🤝',
      'emoji':   '🍎',
      'color':   0xFFFF7043,
      'pages': [
        {'en':'Amal had a big red apple.','si':'අමල් ළඟ විශාල රතු ඇපල් ගෙඩියක් තිබුණා.','ta':'அமலிடம் பெரிய சிவப்பு ஆப்பிள் இருந்தது.','emoji':'🍎'},
        {'en':'His friend Nimal was hungry.','si':'ඔහුගේ යාළුවා නිමල් බඩගිනි හිටියා.','ta':'நண்பன் நிமல் பசியாக இருந்தான்.','emoji':'😔'},
        {'en':'Amal shared the apple with Nimal.','si':'අමල් ඇපල් ගෙඩිය බෙදා ගත්තා.','ta':'அமல் ஆப்பிளை பகிர்ந்தான்.','emoji':'🤝'},
        {'en':'Both friends were happy!','si':'යාළුවෝ දෙදෙනාම සතුටු වුණා!','ta':'இருவரும் மகிழ்ச்சியாக இருந்தனர்!','emoji':'😊'},
      ],
    },
    {
      'id': 'kindness',
      'titleEn': 'Be Kind to Everyone',
      'titleSi': 'හැමෝටම හොඳට ඉන්න',
      'titleTa': 'அனைவரிடமும் கனிவாக இரு',
      'moral':   'Kindness makes the world beautiful 🌸',
      'emoji':   '❤️',
      'color':   0xFFE91E63,
      'pages': [
        {'en':'Sita found a baby bird fallen from its nest.','si':'සීතා කූඩුවෙන් වැටුණු කුඩා කුරුල්ලෙකු සොයා ගත්තා.','ta':'சீதா கூட்டிலிருந்து விழுந்த குஞ்சை கண்டாள்.','emoji':'🐦'},
        {'en':'She gently picked it up and kept it safe.','si':'ඇය මෘදුවෙන් එය ඔසවා ආරක්ෂා කළා.','ta':'மெதுவாக எடுத்து பாதுகாப்பாக வைத்தாள்.','emoji':'❤️'},
        {'en':'The bird grew strong and flew away happily!','si':'කුරුල්ලා ශක්තිමත් වී සතුටෙන් පියාඹා ගියා!','ta':'பறவை வலிமையாகி மகிழ்ச்சியாக பறந்தது!','emoji':'🦅'},
      ],
    },
    {
      'id': 'hardwork',
      'titleEn': 'The Hardworking Rabbit',
      'titleSi': 'වෙහෙස නොවී වැඩකළ හාවා',
      'titleTa': 'கடினமாக உழைத்த முயல்',
      'moral':   'Hard work always pays off 💪',
      'emoji':   '🐰',
      'color':   0xFF9C27B0,
      'pages': [
        {'en':'Every day Bunny practiced writing all letters.','si':'හාවා සෑම දිනකම සියලු අකුරු ලිවීම පුහුණු වුණා.','ta':'ஒவ்வொரு நாளும் முயல் எழுத்து பயிற்சி செய்தது.','emoji':'🐰'},
        {'en':'Even when it was hard, Bunny never gave up!','si':'අමාරු වුනත් හාවා කිසිදා නතර කළේ නැහැ!','ta':'கஷ்டமாக இருந்தாலும் விடவில்லை!','emoji':'💪'},
        {'en':'Bunny became the best writer in the forest!','si':'හාවා වනාන්තරයේ හොඳම ලේඛකයා බවට පත් වුණා!','ta':'காட்டிலேயே சிறந்த எழுத்தாளன் ஆனது!','emoji':'🏆'},
      ],
    },
    {
      'id': 'environment',
      'titleEn': 'Keep Our World Clean',
      'titleSi': 'පරිසරය පිරිසිදුව රකිමු',
      'titleTa': 'உலகை சுத்தமாக வைப்போம்',
      'moral':   'Keep your environment clean 🌳',
      'emoji':   '🌿',
      'color':   0xFF4CAF50,
      'pages': [
        {'en':'Mala saw litter in the park.','si':'මාලා උද්‍යානයේ කසළ දුටුවා.','ta':'மாலா பூங்காவில் குப்பையை பார்த்தாள்.','emoji':'🌳'},
        {'en':'She picked it up and put it in the bin.','si':'ඇය එය ගෙන කූඩයට දැම්මා.','ta':'எடுத்து குப்பைத்தொட்டியில் போட்டாள்.','emoji':'🗑️'},
        {'en':'The park became beautiful again!','si':'උද්‍යානය ලස්සන වුණා!','ta':'பூங்கா அழகாக ஆனது!','emoji':'🌈'},
      ],
    },
  ];
}
