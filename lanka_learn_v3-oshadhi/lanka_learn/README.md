# 🦁 Lanka Learn v3 — AI Intelligent Learning App

Sri Lankan History & Culture learning app with **Flutter mobile frontend**, **Node.js/Express backend**, **MongoDB Atlas**, and **Claude AI** integration.

---

## 📁 Project Structure

```
lanka_learn/
├── backend/              ← Node.js + Express API Server
│   ├── server.js         ← Main entry point
│   ├── .env              ← Environment variables (API keys)
│   ├── models/
│   │   ├── User.js       ← MongoDB User model
│   │   └── Progress.js   ← XP / Coins / Stats model
│   ├── middleware/
│   │   └── auth.js       ← JWT authentication middleware
│   └── routes/
│       ├── auth.js       ← POST /register, /login, GET /me
│       ├── provinces.js  ← GET /provinces (EN/SI/TA)
│       ├── kings.js      ← GET /kings (EN/SI/TA)
│       ├── quiz.js       ← GET /quiz?category&lang
│       ├── progress.js   ← XP, coins, quiz, province tracking
│       ├── analytics.js  ← Teacher dashboard, leaderboard
│       └── ai.js         ← Claude AI quiz gen + king chat
│
└── flutter_app/          ← Flutter Mobile App
    ├── pubspec.yaml
    └── lib/
        ├── main.dart              ← App entry + GoRouter
        ├── utils/constants.dart   ← Colors, theme, API URL
        ├── services/api_service.dart  ← All API calls
        ├── providers/app_provider.dart ← State management
        └── screens/
            ├── splash_screen.dart
            ├── login_screen.dart
            ├── register_screen.dart
            ├── home_screen.dart
            ├── map_screen.dart
            ├── kings_screen.dart
            ├── quiz_category_screen.dart
            ├── quiz_screen.dart
            ├── progress_screen.dart
            ├── games_screen.dart
            └── other_screens.dart  ← Timeline, Story, Leaderboard
```

---

## ⚙️ SETUP — Step by Step

### Prerequisites
- **Node.js** v18+ — https://nodejs.org
- **Flutter** 3.x — https://flutter.dev
- **Android Studio** + Android Emulator
- **VS Code** with Flutter & Dart extensions

---

### 🔧 Step 1 — Backend Setup

```bash
cd lanka_learn/backend
npm install
```

**Edit `.env` file:**
```env
PORT=5000
MONGO_URI=mongodb+srv://Akash:Akash@cluster0.zkdc651.mongodb.net/schoolDB?appName=Cluster0
JWT_SECRET=lankalearn_secret_2024_very_secure
ANTHROPIC_API_KEY=sk-ant-XXXXXXXXXXXXXXXXXXXXXXXX   ← ADD YOUR KEY HERE
NODE_ENV=development
```

👉 Get your Anthropic API key from: https://console.anthropic.com

**Start the backend:**
```bash
npm run dev
```

You should see:
```
✅ MongoDB Connected — schoolDB
🚀 Lanka Learn Server running on http://localhost:5000
```

**Test it:**
```
http://localhost:5000/health
```

---

### 📱 Step 2 — Flutter App Setup

```bash
cd lanka_learn/flutter_app
flutter pub get
```

**Check API URL in `lib/utils/constants.dart`:**
```dart
// Android Emulator (default — use this):
static const String baseUrl = 'http://10.0.2.2:5000/api';

// iOS Simulator:
// static const String baseUrl = 'http://localhost:5000/api';

// Real device (find your PC IP via ipconfig / ifconfig):
// static const String baseUrl = 'http://192.168.1.X:5000/api';
```

**Run the app:**
```bash
flutter run
```

Or open in Android Studio → Run ▶

---

### 🔤 Step 3 — Optional: Baloo Bhai 2 Fonts

For best Sinhala/Tamil text rendering, download fonts from Google Fonts:
1. Go to https://fonts.google.com/specimen/Baloo+2
2. Download Regular (400) and Bold (700)
3. Place in `flutter_app/assets/fonts/`
4. Uncomment the fonts section in `pubspec.yaml`

---

## 🌟 Features

| Feature | Description |
|---------|-------------|
| 🗺️ **Interactive Map** | 9 Provinces with tap-to-explore |
| 👑 **Kings Section** | 6 historical kings with stories |
| 💬 **AI King Chat** | Chat with kings via Claude AI |
| 🎯 **Adaptive Quiz** | AI-generated personalized questions |
| 🎮 **Games** | Match/drag-drop learning games |
| 📜 **Timeline** | 2500+ year Sri Lanka history |
| 📊 **Progress** | XP, coins, achievements, analytics |
| 🌐 **Multilingual** | Sinhala / Tamil / English |
| 🔊 **TTS** | Text-to-speech narration |

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register user |
| POST | `/api/auth/login` | Login → JWT token |
| GET | `/api/auth/me` | Current user |
| GET | `/api/provinces?lang=en` | All provinces |
| GET | `/api/kings?lang=si` | All kings |
| GET | `/api/quiz?category=kings&lang=en` | Quiz questions |
| GET | `/api/progress` | Get progress |
| POST | `/api/progress/xp` | Add XP |
| POST | `/api/ai/quiz` | Claude AI quiz gen |
| POST | `/api/ai/king-chat` | Claude AI king chat |
| GET | `/api/analytics/leaderboard` | Leaderboard |

---

## 🛠️ Tech Stack

- **Flutter 3** + Dart — Mobile UI
- **Provider** — State management
- **GoRouter** — Navigation
- **Node.js + Express** — REST API
- **MongoDB Atlas** — Cloud database
- **Mongoose** — ODM
- **JWT + bcryptjs** — Authentication
- **Claude AI (claude-sonnet-4-20250514)** — AI features
- **flutter_tts** — Text to Speech
- **fl_chart** — Progress charts
- **flutter_animate** — Animations

---

## 🚨 Troubleshooting

**"Connection refused" on emulator:**
→ Make sure backend is running on port 5000
→ Use `10.0.2.2` not `localhost` for Android emulator

**MongoDB connection error:**
→ Check MONGO_URI in `.env`
→ Whitelist your IP in MongoDB Atlas Network Access (or use 0.0.0.0/0)

**Claude AI not working:**
→ Add valid `ANTHROPIC_API_KEY` in `.env`
→ App has offline fallback — will use local quiz data

**flutter pub get fails:**
→ Run `flutter clean` then `flutter pub get`

---

## 📄 License

Educational project — Lanka Learn v3 © 2024
