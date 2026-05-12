import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/app_provider.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/sri_lanka_map_page.dart';
import 'screens/kings_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/quiz_category_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/games_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/king_story_screen.dart';
import 'screens/leaderboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider();
  await appProvider.init();
  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const LankaLearnApp(),
    ),
  );
}

class LankaLearnApp extends StatelessWidget {
  const LankaLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',    builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',     builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register',  builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home',      builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/map',       builder: (_, __) => const SriLankaMapPage()),
    GoRoute(path: '/kings',     builder: (_, __) => const KingsScreen()),
    GoRoute(path: '/quiz-category', builder: (_, __) => const QuizCategoryScreen()),
    GoRoute(
      path: '/quiz/:category',
      builder: (context, state) => QuizScreen(category: state.pathParameters['category'] ?? 'all'),
    ),
    GoRoute(path: '/progress',  builder: (_, __) => const ProgressScreen()),
    GoRoute(path: '/games',     builder: (_, __) => const GamesScreen()),
    GoRoute(path: '/timeline',  builder: (_, __) => const TimelineScreen()),
    GoRoute(
      path: '/king-story/:id',
      builder: (context, state) => KingStoryScreen(
        kingId: int.parse(state.pathParameters['id'] ?? '0'),
      ),
    ),
    GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
  ],
);
