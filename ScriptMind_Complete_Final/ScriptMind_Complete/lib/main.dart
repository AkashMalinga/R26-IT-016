import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/alphabet_screen.dart';
import 'screens/handwriting_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/fun_activities_screen.dart';
import 'screens/progress_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const ScriptMindApp(),
    ),
  );
}

class ScriptMindApp extends StatelessWidget {
  const ScriptMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScriptMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/':            (_) => const SplashScreen(),
        '/login':       (_) => const LoginScreen(),
        '/home':        (_) => const HomeScreen(),
        '/alphabet':    (_) => const AlphabetScreen(),
        '/handwriting': (_) => const HandwritingScreen(),
        '/stories':     (_) => const StoriesScreen(),
        '/fun':         (_) => const FunActivitiesScreen(),
        '/progress':    (_) => const ProgressScreen(),
        '/badges':      (_) => const BadgesScreen(),
      },
    );
  }
}
