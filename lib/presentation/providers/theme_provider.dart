import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const String _themePrefsKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePrefsKey);
    if (themeIndex != null) {
      state = ThemeMode.values[themeIndex];
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefsKey, mode.index);
    state = mode;
  }
}

// Provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// Available color schemes
enum AppColorScheme {
  blue, // Default
  green,
  purple,
  orange,
  pink,
}

// Color scheme state notifier
class ColorSchemeNotifier extends StateNotifier<AppColorScheme> {
  ColorSchemeNotifier() : super(AppColorScheme.blue) {
    _loadColorScheme();
  }

  static const String _colorSchemePrefsKey = 'color_scheme';

  Future<void> _loadColorScheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorSchemeIndex = prefs.getInt(_colorSchemePrefsKey);
    if (colorSchemeIndex != null) {
      state = AppColorScheme.values[colorSchemeIndex];
    }
  }

  Future<void> setColorScheme(AppColorScheme colorScheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorSchemePrefsKey, colorScheme.index);
    state = colorScheme;
  }
}

// Provider for color scheme
final colorSchemeProvider = StateNotifierProvider<ColorSchemeNotifier, AppColorScheme>(
  (ref) => ColorSchemeNotifier(),
);

// Helper function to get color from color scheme
Color getColorFromColorScheme(AppColorScheme colorScheme) {
  switch (colorScheme) {
    case AppColorScheme.blue:
      return const Color(0xFF1565C0); // Deep Blue
    case AppColorScheme.green:
      return const Color(0xFF2E7D32); // Green
    case AppColorScheme.purple:
      return const Color(0xFF6A1B9A); // Purple
    case AppColorScheme.orange:
      return const Color(0xFFE65100); // Orange
    case AppColorScheme.pink:
      return const Color(0xFFAD1457); // Pink
  }
} 