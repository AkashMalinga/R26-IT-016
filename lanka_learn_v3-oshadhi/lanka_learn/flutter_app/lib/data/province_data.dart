// Province model and data for Sri Lanka map

class AppLabels {
  static const Map<String, Map<String, String>> labels = {
    'en': {
      'tapProvince': 'Tap on a province to learn more',
      'capital': 'Capital',
      'districts': 'DISTRICTS',
      'tags': 'TAGS',
      'places': 'FAMOUS PLACES',
      'industries': 'INDUSTRIES',
      'provinces': 'PROVINCES',
    },
    'si': {
      'tapProvince': 'ප්‍රාන්තයක් තෝරා ගැනීමට තට්ටු කරන්න',
      'capital': 'ප්‍රධාන නගරය',
      'districts': 'දිස්ත්‍රික්ක',
      'tags': 'ලක්ෂණ',
      'places': 'ප්‍රසිද්ධ ස්ථාන',
      'industries': 'කර්මාන්ත',
      'provinces': 'පළාත්',
    },
    'ta': {
      'tapProvince': 'மாகாணத்தைத் தேர்ந்தெடுக்க கிளிக் செய்யவும்',
      'capital': 'தலைநகரம்',
      'districts': 'மாவட்டங்கள்',
      'tags': 'குறிகள்',
      'places': 'பிரசித்த இடங்கள்',
      'industries': 'தொழில்கள்',
      'provinces': 'மாகாணங்கள்',
    },
  };

  static String getLabel(String key, String language) {
    return labels[language]?[key] ?? labels['en']![key]!;
  }
}

class ProvinceTranslation {
  final String name;
  final String districts;
  final List<String> tags;
  final List<String> places;
  final String industries;

  ProvinceTranslation({
    required this.name,
    required this.districts,
    required this.tags,
    required this.places,
    required this.industries,
  });
}

class Province {
  final String id;
  final Map<String, ProvinceTranslation> translations; // 'en', 'si', 'ta'
  final String capital;
  final String description;
  final String colorHex;

  Province({
    required this.id,
    required this.translations,
    required this.capital,
    required this.description,
    required this.colorHex,
  });

  ProvinceTranslation getTranslation(String language) {
    return translations[language] ?? translations['en']!;
  }

  String getName(String language) => getTranslation(language).name;
  String getDistricts(String language) => getTranslation(language).districts;
  List<String> getTags(String language) => getTranslation(language).tags;
  List<String> getPlaces(String language) => getTranslation(language).places;
  String getIndustries(String language) => getTranslation(language).industries;
}

class ProvinceDataManager {
  static final Map<String, Province> provinces = {
    'western': Province(
      id: 'western',
      capital: 'Colombo',
      description: 'The most urbanized province in Sri Lanka and the main economic hub.',
      colorHex: '#f0b429',
      translations: {
        'en': ProvinceTranslation(
          name: 'Western Province',
          districts: 'Colombo · Gampaha · Kalutara',
          tags: ['Economic Hub', 'Colombo Port', 'IT Industry'],
          places: ['Lotus Tower', 'Galle Face Green', 'Kelaniya Temple', 'Colombo Port'],
          industries: 'IT, Banking, Port & Shipping, Garments',
        ),
        'si': ProvinceTranslation(
          name: 'බස්නාහිර පළාත',
          districts: 'කොළඹ · ගම්පහ · කළුතර',
          tags: ['ආර්ථික මධ්‍යස්ථානය', 'කොළඹ වරාය', 'IT'],
          places: ['Lotus Tower', 'Galle Face', 'Kelaniya', 'Colombo Port'],
          industries: 'IT, බැංකු, Port, ඇඟළුම්',
        ),
        'ta': ProvinceTranslation(
          name: 'மேல் மாகாணம்',
          districts: 'கொழும்பு · கம்பஹா · களுத்துறை',
          tags: ['பொருளாதார மையம்', 'IT'],
          places: ['Lotus Tower', 'Galle Face', 'Kelaniya'],
          industries: 'IT, வணிகம், துறைமுகம்',
        ),
      },
    ),
    'central': Province(
      id: 'central',
      capital: 'Kandy',
      description: 'Known for mountains, tea estates, and cultural heritage.',
      colorHex: '#e84393',
      translations: {
        'en': ProvinceTranslation(
          name: 'Central Province',
          districts: 'Kandy · Matale · Nuwara Eliya',
          tags: ['Temple of Tooth', 'Perahera Festival', 'Tea Estates', 'Sigiriya'],
          places: ['Temple of the Tooth', 'Horton Plains', 'Sigiriya', 'Knuckles Range'],
          industries: 'Tea Industry, Spice Cultivation, Tourism',
        ),
        'si': ProvinceTranslation(
          name: 'මධ්‍යම පළාත',
          districts: 'කන්ද · මාතලේ · නුවරඑළිය',
          tags: ['දළදා මාලිගාව', 'පෙරහේරා', 'තේ', 'Sigiriya'],
          places: ['දළදා මාලිගාව', 'Horton Plains', 'Sigiriya', 'Knuckles'],
          industries: 'තේ, කුළුබඩු, සංචාරක',
        ),
        'ta': ProvinceTranslation(
          name: 'மத்திய மாகாணம்',
          districts: 'கண்டி · மாத்தலை · நுவரெலியா',
          tags: ['தலதா மாளிகை', 'தேயிலை', 'Sigiriya'],
          places: ['தலதா மாளிகை', 'Horton Plains', 'Sigiriya'],
          industries: 'தேயிலை, சுற்றுலா',
        ),
      },
    ),
    'southern': Province(
      id: 'southern',
      capital: 'Galle',
      description: 'Famous for coastal tourism, historical cities, and beaches.',
      colorHex: '#e74c3c',
      translations: {
        'en': ProvinceTranslation(
          name: 'Southern Province',
          districts: 'Galle · Matara · Hambantota',
          tags: ['Galle Fort', 'Mirissa Beach', 'Yala Wildlife'],
          places: ['Galle Fort', 'Mirissa Beach', 'Yala National Park', 'Hambantota Port'],
          industries: 'Fisheries, Tourism, Salt Production',
        ),
        'si': ProvinceTranslation(
          name: 'දකුණු පළාත',
          districts: 'ගාල්ල · මාතර · හම්බන්තොට',
          tags: ['Galle Fort', 'Mirissa', 'Yala'],
          places: ['Galle Fort', 'Mirissa Beach', 'Yala National Park'],
          industries: 'ධීවර, සංචාරක, ලුණු',
        ),
        'ta': ProvinceTranslation(
          name: 'தென் மாகாணம்',
          districts: 'காலி · மாத்தறை · ஹம்பாந்தோட்டை',
          tags: ['காலி கோட்டை', 'Yala'],
          places: ['Galle Fort', 'Mirissa', 'Yala'],
          industries: 'மீன்பிடி, சுற்றுலா',
        ),
      },
    ),
    'northern': Province(
      id: 'northern',
      capital: 'Jaffna',
      description: 'Known for Tamil culture, coastal areas, and historical significance.',
      colorHex: '#4a9eff',
      translations: {
        'en': ProvinceTranslation(
          name: 'Northern Province',
          districts: 'Jaffna · Kilinochchi · Mannar · Mullaitivu · Vavuniya',
          tags: ['Tamil Culture', 'Fisheries', 'Hindu Temples', 'Palmyrah'],
          places: ['Nallur Kovil', 'Jaffna Fort', 'Nagadeepa Vihara', 'Point Pedro'],
          industries: 'Fisheries, Agriculture, Palmyrah Products',
        ),
        'si': ProvinceTranslation(
          name: 'උතුරු පළාත',
          districts: 'ජාෆ්නා · කිලිනොච්චි · මන්නාරම · මුලතිව් · වව්නියා',
          tags: ['දෙමළ සංස්කෘතිය', 'ධීවර', 'හින්දු කෝවිල්', 'පල්මිරා'],
          places: ['Nallur Kovil', 'ජාෆ්නා කොටුව', 'Nagadeepa', 'Point Pedro'],
          industries: 'ධීවර, වේළාශ, පල්මිරා කර්මාන්ත',
        ),
        'ta': ProvinceTranslation(
          name: 'வட மாகாணம்',
          districts: 'யாழ்ப்பாணம் · கிளிநொச்சி · மன்னார்',
          tags: ['தமிழ் கலாசாரம்', 'மீன்பிடி', 'இந்து கோவில்'],
          places: ['Nallur Kovil', 'யாழ் கோட்டை', 'Nagadeepa'],
          industries: 'மீன்பிடி, விவசாயம், பனை',
        ),
      },
    ),
    'eastern': Province(
      id: 'eastern',
      capital: 'Trincomalee',
      description: 'Known for beaches, lagoons, and cultural diversity.',
      colorHex: '#ff8c42',
      translations: {
        'en': ProvinceTranslation(
          name: 'Eastern Province',
          districts: 'Trincomalee · Batticaloa · Ampara',
          tags: ['Natural Harbor', 'World-class Surfing', 'Rice Farming'],
          places: ['Koneswaram Temple', 'Pasikuda Beach', 'Arugam Bay', 'Fort Frederick'],
          industries: 'Fisheries, Paddy Cultivation, Tourism, Salt',
        ),
        'si': ProvinceTranslation(
          name: 'නැගෙනහිර පළාත',
          districts: 'ත්‍රිකුණාමලය · බදුල්ල · අම්පාර',
          tags: ['ස්වාභාවික වරාය', 'World-class Surfing', 'වී වගාව'],
          places: ['Koneswaram', 'Pasikuda Beach', 'Arugam Bay', 'Fort Frederick'],
          industries: 'ධීවර, ගොවිතැන, සංචාරක, ලුණු',
        ),
        'ta': ProvinceTranslation(
          name: 'கிழக்கு மாகாணம்',
          districts: 'திரிகோணமலை · மட்டக்களப்பு · அம்பாறை',
          tags: ['இயற்கை துறைமுகம்', 'Surfing'],
          places: ['Koneswaram', 'Pasikuda', 'Arugam Bay'],
          industries: 'மீன்பிடி, சுற்றுலா, உப்பு',
        ),
      },
    ),
    'north_western': Province(
      id: 'north_western',
      capital: 'Kurunegala',
      description: 'Known for agriculture, coconut plantations, and historical sites.',
      colorHex: '#2ecc71',
      translations: {
        'en': ProvinceTranslation(
          name: 'North Western Province',
          districts: 'Kurunegala · Puttalam',
          tags: ['Coconut Triangle', 'Salt Production', 'Lagoons'],
          places: ['Wilpattu National Park', 'Ridi Viharaya', 'Kurunegala Rock'],
          industries: 'Coconut Industry, Fisheries, Salt, Garments',
        ),
        'si': ProvinceTranslation(
          name: 'වයඹ පළාත',
          districts: 'කුරුණෑගල · පුත්තලම',
          tags: ['පොල් ත්‍රිකෝණය', 'ලුණු ලේවා'],
          places: ['Wilpattu', 'Ridi Viharaya', 'Kurunegala Rock'],
          industries: 'පොල්, ධීවර, ලුණු, ඇඟළුම්',
        ),
        'ta': ProvinceTranslation(
          name: 'வட மேற்கு மாகாணம்',
          districts: 'குருணாகல் · புத்தளம்',
          tags: ['தேங்காய்', 'உப்பு'],
          places: ['Wilpattu', 'Ridi Viharaya'],
          industries: 'தேங்காய், மீன்பிடி',
        ),
      },
    ),
    'north_central': Province(
      id: 'north_central',
      capital: 'Anuradhapura',
      description: 'Famous for ancient kingdoms, irrigation systems, and heritage sites.',
      colorHex: '#9a4aff',
      translations: {
        'en': ProvinceTranslation(
          name: 'North Central Province',
          districts: 'Anuradhapura · Polonnaruwa',
          tags: ['Ancient Capitals', 'Buddhist Heritage', 'Irrigation', 'UNESCO'],
          places: ['Sri Maha Bodhi', 'Ruwanwelisaya', 'Gal Viharaya', 'Parakrama Samudraya'],
          industries: 'Agriculture, Irrigation Farming, Cultural Tourism',
        ),
        'si': ProvinceTranslation(
          name: 'උතුරු මැද පළාත',
          districts: 'අනුරාධපුර · පොළොන්නරුව',
          tags: ['පුරාණ රාජධානි', 'බෞද්ධ', 'UNESCO'],
          places: ['ශ්‍රී මහා බෝධිය', 'රුවන්වැලිසෑය', 'Gal Viharaya', 'Parakrama Samudraya'],
          industries: 'ගොවිතැන, සංචාරක, වාරිමාර්ග',
        ),
        'ta': ProvinceTranslation(
          name: 'வட மத்திய மாகாணம்',
          districts: 'அனுராதபுரம் · பொலன்னறுவை',
          tags: ['பண்டைய நகரங்கள்', 'யுனெஸ்கோ'],
          places: ['ஸ்ரீ மகா போதி', 'Ruwanwelisaya', 'Gal Viharaya'],
          industries: 'விவசாயம், சுற்றுலா',
        ),
      },
    ),
    'uva': Province(
      id: 'uva',
      capital: 'Badulla',
      description: 'Known for waterfalls, tea estates, and natural landscapes.',
      colorHex: '#1abc9c',
      translations: {
        'en': ProvinceTranslation(
          name: 'Uva Province',
          districts: 'Badulla · Monaragala',
          tags: ['Nine Arches Bridge', 'Ella Rock', 'Waterfalls'],
          places: ['Nine Arches Bridge', 'Ella Rock', 'Dunhinda Falls', 'Horton Plains'],
          industries: 'Tea Industry, Agriculture, Eco Tourism',
        ),
        'si': ProvinceTranslation(
          name: 'ඌව පළාත',
          districts: 'බදුල්ල · මොණරාගල',
          tags: ['Nine Arches', 'Ella Rock', 'දිය ඇල්ල'],
          places: ['Nine Arches Bridge', 'Ella Rock', 'Dunhinda Falls'],
          industries: 'තේ, ගොවිතැන, Eco Tourism',
        ),
        'ta': ProvinceTranslation(
          name: 'ஊவா மாகாணம்',
          districts: 'பதுள்ளை · மொனராகலை',
          tags: ['தேயிலை', 'அருவிகள்'],
          places: ['Nine Arches', 'Ella Rock', 'Dunhinda'],
          industries: 'தேயிலை, சுற்றுலா',
        ),
      },
    ),
    'sabaragamuwa': Province(
      id: 'sabaragamuwa',
      capital: 'Ratnapura',
      description: 'Famous for gem mining, mountains, and natural beauty.',
      colorHex: '#7cb342',
      translations: {
        'en': ProvinceTranslation(
          name: 'Sabaragamuwa Province',
          districts: 'Ratnapura · Kegalle',
          tags: ['Gem Industry', 'Rubber', "Adam's Peak", 'Sinharaja'],
          places: ["Adam's Peak", "Sinharaja Forest", "Pinnawala Elephant Orphanage"],
          industries: 'Gem Mining, Rubber Industry, Eco Tourism',
        ),
        'si': ProvinceTranslation(
          name: 'සබරගමුව පළාත',
          districts: 'රත්නපුර · කෑගල්ල',
          tags: ['මැණික්', 'රබර්', 'ශ්‍රී පාදය'],
          places: ["Adam's Peak", "Sinharaja", "Pinnawala"],
          industries: 'මැණික්, රබර්, Eco Tourism',
        ),
        'ta': ProvinceTranslation(
          name: 'சபரகமுவ மாகாணம்',
          districts: 'இரத்தினபுரி · கேகாலை',
          tags: ['ரத்தினம்', 'ரப்பர்'],
          places: ["Adam's Peak", "Sinharaja", "Pinnawala"],
          industries: 'ரத்தினம், ரப்பர்',
        ),
      },
    ),
  };

  static Province? getProvinceById(String id) {
    return provinces[id];
  }

  static List<Province> getAllProvinces() {
    return provinces.values.toList();
  }

  static List<String> getProvinceNames() {
    return provinces.values.map((p) => p.translations['en']!.name).toList();
  }

  static Province? getProvinceByName(String name) {
    try {
      return provinces.values.firstWhere((p) => p.translations['en']!.name == name);
    } catch (e) {
      return null;
    }
  }
}
