import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/student_details_screen.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if this is the first run
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool(AppConstants.firstRunPref) ?? true;
  
  runApp(
    ProviderScope(
      child: MyApp(isFirstRun: isFirstRun),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool isFirstRun;
  
  const MyApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = ref.watch(colorSchemeProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(colorScheme),
      darkTheme: AppTheme.getDarkTheme(colorScheme),
      themeMode: themeMode,
      initialRoute: AppConstants.splashRoute,
      routes: {
        AppConstants.splashRoute: (context) => const SplashScreen(),
        AppConstants.onboardingRoute: (context) => const OnboardingScreen(),
        AppConstants.homeRoute: (context) => const MainNavigationScreen(),
        AppConstants.studentDetailsRoute: (context) => const StudentDetailsScreen(),
        AppConstants.settingsRoute: (context) => const SettingsScreen(),
      },
    );
  }
}
