# ScriptMind — Complete Project
**SLIIT Research | IT22123190 — Malinga B.G.A**

## 📁 Structure
```
ScriptMind_Complete/
├── backend/          ← Node.js + Express + MongoDB
│   ├── server.js     ← Start point
│   ├── .env
│   ├── models/       ← User, Attempt, Session, Badge
│   └── routes/       ← auth, attempts, progress, admin, badges, stories, analytics
│
├── lib/              ← Flutter app
│   ├── main.dart
│   ├── screens/
│   ├── services/
│   └── constants/
├── android/
├── assets/
└── pubspec.yaml
```

## 🚀 Step 1 — Backend Start කරන්න (VS Code)
```bash
cd backend
npm install
npm start
```
✅ Browser: http://localhost:3001/health → {"status":"ok"}

Default logins:
- Admin: admin / admin123
- Child: ravi / ravi123
- Child: suri / suri123

## 📱 Step 2 — Flutter Run කරන්න (Android Studio)
```bash
flutter pub get
flutter run
```

## ⚠️ Important
Backend start වෙලා තිද්දී Flutter run කරන්න!
