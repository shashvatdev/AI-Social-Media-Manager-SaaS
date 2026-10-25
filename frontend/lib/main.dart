import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/brand_provider.dart';
import 'providers/strategy_provider.dart';
import 'providers/post_provider.dart';
import 'providers/social_provider.dart';
import 'providers/analytics_provider.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BrandProvider()),
        ChangeNotifierProvider(create: (_) => StrategyProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: const SocialMediaAiApp(),
    ),
  );
}

class SocialMediaAiApp extends StatelessWidget {
  const SocialMediaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autonomous Social AI Lead',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryDarkTheme,
      home: const SplashScreen(),
    );
  }
}
